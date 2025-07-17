package service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;
import model.Songs; // Thêm import cho model Song

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GeminiApiService {

    private static final String API_KEY = "AIzaSyBR2ZCqRxKgv63azpZLI1BS4auVDFsEhy0"; // NHỚ THAY API KEY CỦA BẠN!
    private static final String MODEL_NAME = "gemini-1.5-flash";
    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1/models/" + MODEL_NAME + ":generateContent?key=" + API_KEY;

    private final HttpClient httpClient;
    private final Gson gson;

    public static class SuggestedSong {
        public String title;
        public String artist;

        public SuggestedSong(String title, String artist) {
            this.title = title;
            this.artist = artist;
        }
        @Override
        public String toString() { return "Title: " + title + ", Artist: " + artist; }
    }

    public GeminiApiService() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(20))
                .build();
        this.gson = new Gson();
    }

    /**
     * Gửi yêu cầu đến Gemini API để lấy gợi ý bài hát dựa trên mô tả
     * và danh sách các bài hát có sẵn trong cơ sở dữ liệu.
     * @param description Mô tả playlist của người dùng.
     * @param availableSongs Danh sách tất cả bài hát từ DB.
     * @return Danh sách các bài hát được Gemini gợi ý (dưới dạng SuggestedSong).
     * @throws Exception Nếu có lỗi xảy ra.
     */
    public List<SuggestedSong> getSongSuggestions(String description, List<Songs> availableSongs) throws Exception {
        if (API_KEY == null || API_KEY.isEmpty()) {
            System.err.println("LỖI: Gemini API Key chưa được cấu hình trong GeminiApiService.java");
            throw new Exception("Gemini API Key chưa được cấu hình. Vui lòng kiểm tra code và thay thế YOUR_GEMINI_API_KEY.");
        }

        if (availableSongs == null || availableSongs.isEmpty()) {
            System.out.println("[GeminiApiService] Không có bài hát nào trong cơ sở dữ liệu để cung cấp cho AI.");
             return new ArrayList<>();
        }

        StringBuilder availableSongsFormatted = new StringBuilder();
        availableSongsFormatted.append("Dưới đây là danh sách các bài hát hiện có trong thư viện:\n");
        for (int i = 0; i < availableSongs.size(); i++) {
            Songs song = availableSongs.get(i);
            availableSongsFormatted.append(String.format("%d. Tiêu đề: %s, Nghệ sĩ: %s, Thể loại: %s\n",
                    i + 1,
                    song.getTitle(),
                    song.getArtist(),
                    song.getGenre() != null ? song.getGenre() : "Không rõ"));
        }
        // Giới hạn độ dài của danh sách bài hát gửi đi nếu quá lớn (ví dụ)
        // String songsListForPrompt = availableSongsFormatted.toString();
        // if (songsListForPrompt.length() > 15000) { // Ngưỡng ví dụ, cần kiểm tra giới hạn token thực tế
        //    songsListForPrompt = songsListForPrompt.substring(0, 15000) + "\n... (và nhiều bài hát khác)";
        //    System.out.println("[GeminiApiService] CẢNH BÁO: Danh sách bài hát gửi cho AI đã được cắt bớt do quá dài.");
        // }


        // Xây dựng prompt cho Gemini
        String prompt = "Bạn là một trợ lý AI tạo hoặc xóa playlist nhạc thông minh. " +
                        "Dựa trên mô tả của người dùng: \"" + description + "\", " +
                        "hãy chọn ra từ các bài hát từ danh sách các bài hát có sẵn dưới đây. " +
                        "Hãy tập trung vào việc khớp tâm trạng, thể loại, nghệ sĩ hoặc từ khóa trong nội dung bài hát với các bài hát được cung cấp. " +
                        "Chỉ chọn bài hát từ danh sách được cung cấp. " +
                        "Trả lời của bạn CHỈ BAO GỒM danh sách các bài hát đã chọn, mỗi bài hát trên một dòng mới, theo định dạng chính xác: 'Tên Bài Hát - Tên Nghệ Sĩ'. " +
                        "Không thêm bất kỳ giải thích, tiêu đề, đánh số hay định dạng nào khác ngoài danh sách các bài hát 'Tên Bài Hát - Tên Nghệ Sĩ'.\n\n" +
                        "Danh sách bài hát có sẵn:\n" + availableSongsFormatted.toString();


        JsonObject part = new JsonObject();
        part.addProperty("text", prompt);
        JsonArray partsArray = new JsonArray();
        partsArray.add(part);
        JsonObject content = new JsonObject();
        content.add("parts", partsArray);
        JsonArray contentsArray = new JsonArray();
        contentsArray.add(content);
        JsonObject requestBodyJson = new JsonObject();
        requestBodyJson.add("contents", contentsArray);
        
        JsonObject generationConfig = new JsonObject();
        generationConfig.addProperty("temperature", 0.6); // Giảm một chút để AI bám sát danh sách hơn
        generationConfig.addProperty("maxOutputTokens", 1024); 
        requestBodyJson.add("generationConfig", generationConfig);

        String requestBody = gson.toJson(requestBodyJson);
        // System.out.println("[GeminiApiService] Prompt gửi đến Gemini: " + prompt); // Log prompt nếu cần debug kỹ
        System.out.println("[GeminiApiService] Độ dài ước tính của prompt (characters): " + prompt.length());


        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(GEMINI_API_URL))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .timeout(Duration.ofSeconds(90)) // Tăng timeout vì prompt có thể dài
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println("[GeminiApiService] Gemini API Response Code: " + response.statusCode());
        // System.out.println("[GeminiApiService] Gemini API Response Body: " + response.body()); // Log nếu cần debug kỹ

        if (response.statusCode() == 200) {
            return parseGeminiResponse(response.body());
        } else {
            // Xử lý lỗi chi tiết hơn
            String errorDetails = "Không thể lấy gợi ý từ Gemini. Status: " + response.statusCode();
            String responseBodyContent = response.body();
            try {
                JsonObject errorJson = gson.fromJson(responseBodyContent, JsonObject.class);
                if (errorJson.has("error") && errorJson.getAsJsonObject("error").has("message")) {
                    errorDetails += " - Message: " + errorJson.getAsJsonObject("error").get("message").getAsString();
                } else {
                     errorDetails += " - Body: " + responseBodyContent.substring(0, Math.min(500, responseBodyContent.length()));
                }
            } catch (JsonSyntaxException e) {
                errorDetails += " - Body (không phải JSON hoặc lỗi parse): " + responseBodyContent.substring(0, Math.min(500, responseBodyContent.length()));
            }
             System.err.println(errorDetails);
            throw new Exception(errorDetails);
        }
    }

    // Phương thức parseGeminiResponse giữ nguyên như trước
    private List<SuggestedSong> parseGeminiResponse(String responseBody) {
        List<SuggestedSong> suggestions = new ArrayList<>();
        try {
            JsonObject jsonResponse = gson.fromJson(responseBody, JsonObject.class);
            if (jsonResponse.has("candidates") && jsonResponse.get("candidates").isJsonArray()) {
                JsonArray candidates = jsonResponse.getAsJsonArray("candidates");
                if (candidates.size() > 0) {
                    JsonObject firstCandidate = candidates.get(0).getAsJsonObject();
                    if (firstCandidate.has("content") && firstCandidate.getAsJsonObject("content").has("parts") &&
                        firstCandidate.getAsJsonObject("content").getAsJsonArray("parts").size() > 0 &&
                        firstCandidate.getAsJsonObject("content").getAsJsonArray("parts").get(0).getAsJsonObject().has("text")) {
                        
                        String textResponse = firstCandidate.getAsJsonObject("content").getAsJsonArray("parts").get(0).getAsJsonObject().get("text").getAsString();
                        String[] lines = textResponse.split("\\r?\\n");
                        Pattern pattern = Pattern.compile("^(.*?)\\s*-\\s*(.*?)$");
                        for (String line : lines) {
                            if (line.trim().isEmpty()) continue;
                            String cleanLine = line.trim().replaceFirst("^\\*\\s*", "").trim(); 
                            Matcher matcher = pattern.matcher(cleanLine);
                            if (matcher.matches()) {
                                String title = matcher.group(1).trim();
                                String artist = matcher.group(2).trim();
                                if (!title.isEmpty() && !artist.isEmpty()) {
                                    suggestions.add(new SuggestedSong(title, artist));
                                }
                            } else {
                                 System.out.println("[GeminiApiService] Dòng không khớp định dạng 'Tên - Nghệ sĩ': \"" + cleanLine + "\"");
                            }
                        }
                    } else { System.err.println("[GeminiApiService] Cấu trúc 'content.parts.text' không tìm thấy trong candidate.");}
                } else { System.err.println("[GeminiApiService] Mảng 'candidates' rỗng.");}
            } else {
                System.err.println("[GeminiApiService] Phản hồi Gemini không có 'candidates' hoặc cấu trúc không mong đợi. Body: " + responseBody.substring(0, Math.min(500, responseBody.length())));
            }
        } catch (JsonSyntaxException e) {
            System.err.println("[GeminiApiService] Lỗi phân tích JSON từ Gemini: " + e.getMessage() + ". Body: " + responseBody.substring(0, Math.min(500, responseBody.length())));
        }
        return suggestions;
    }
}