package controller;

import com.google.gson.Gson;
import dao.PlaylistDAO;
import dao.SongDAO;
import model.Songs;
import service.GeminiApiService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;


@WebServlet("/geminiPlaylist")
public class GeminiPlaylistServlet extends HttpServlet {
    private GeminiApiService geminiService;
    private SongDAO songDAO;
    private PlaylistDAO playlistDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        geminiService = new GeminiApiService();
        songDAO = new SongDAO();
        playlistDAO = new PlaylistDAO();
        gson = new Gson();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String description = request.getParameter("description");
        Map<String, Object> jsonResponseMap = new HashMap<>();
        // Lấy userId từ session
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        model.User user = (session != null) ? (model.User) session.getAttribute("user") : null;
        if (user == null) {
            jsonResponseMap.put("success", false);
            jsonResponseMap.put("message", "Bạn cần đăng nhập để sử dụng chức năng này.");
            response.getWriter().write(gson.toJson(jsonResponseMap));
            return;
        }
        int userId = user.getUserId();

        if (description == null || description.trim().isEmpty()) {
            jsonResponseMap.put("success", false);
            jsonResponseMap.put("message", "Mô tả/lệnh không được để trống.");
            response.getWriter().write(gson.toJson(jsonResponseMap));
            return;
        }

        String descriptionTrimmed = description.trim();
        String descriptionLower = descriptionTrimmed.toLowerCase();

        final String DELETE_ONE_PLAYLIST_CMD_VI = "xóa "; 
        final String DELETE_ALL_PLAYLISTS_CMD_VI = "xóa tất cả playlist hiện có";
        final String DELETE_ALL_PLAYLISTS_CMD_VI_SHORT = "xóa tất cả playlist";
        final String DELETE_ALL_AI_PLAYLISTS_CMD_VI = "xóa tất cả playlist ai đã tạo";

        // Ưu tiên kiểm tra lệnh "xóa tất cả playlist ai đã tạo"
        if (descriptionLower.equals(DELETE_ALL_AI_PLAYLISTS_CMD_VI)) {
            System.out.println("[GeminiPlaylistServlet] Nhận lệnh xóa TẤT CẢ playlist AI cho user ID: " + userId);
            boolean allAIPlaylistsDeleted = playlistDAO.deleteAllAIPlaylistsByUser(userId);
            if (allAIPlaylistsDeleted) {
                jsonResponseMap.put("success", true);
                jsonResponseMap.put("message", "Tất cả playlist AI đã tạo của bạn đã được xóa thành công.");
                request.getSession().setAttribute("successMessage", "Tất cả playlist AI đã tạo đã được xóa!");
            } else {
                jsonResponseMap.put("success", false);
                jsonResponseMap.put("message", "Không thể xóa tất cả playlist AI. Có lỗi xảy ra hoặc không có playlist AI nào.");
                request.getSession().setAttribute("errorMessage", "Lỗi khi xóa tất cả playlist AI.");
            }
            response.getWriter().write(gson.toJson(jsonResponseMap));
            return;
        }

        // Ưu tiên kiểm tra lệnh "xóa tất cả" trước
        if (descriptionLower.equals(DELETE_ALL_PLAYLISTS_CMD_VI) || descriptionLower.equals(DELETE_ALL_PLAYLISTS_CMD_VI_SHORT)) {
            System.out.println("[GeminiPlaylistServlet] Nhận lệnh xóa TẤT CẢ playlist cho user ID: " + userId);
            // JavaScript ở client NÊN có bước confirm("Bạn có chắc không?") trước khi gửi lệnh này
            boolean allDeleted = playlistDAO.deleteAllPlaylistsByUser(userId);
            if (allDeleted) {
                jsonResponseMap.put("success", true);
                jsonResponseMap.put("message", "Tất cả playlist của bạn đã được xóa thành công.");
                request.getSession().setAttribute("successMessage", "Tất cả playlist đã được xóa!");
            } else {
                jsonResponseMap.put("success", false);
                jsonResponseMap.put("message", "Không thể xóa tất cả playlist. Có lỗi xảy ra.");
                 request.getSession().setAttribute("errorMessage", "Lỗi khi xóa tất cả playlist.");
            }
            response.getWriter().write(gson.toJson(jsonResponseMap));
            return; 
        }

        // Kiểm tra lệnh "xóa <tên playlist>"
        if (descriptionLower.startsWith(DELETE_ONE_PLAYLIST_CMD_VI)) {
            String playlistNameToDelete = descriptionTrimmed.substring(DELETE_ONE_PLAYLIST_CMD_VI.length()).trim();
            
            if (playlistNameToDelete.isEmpty()) {
                jsonResponseMap.put("success", false);
                jsonResponseMap.put("message", "Vui lòng nhập tên playlist cần xóa sau lệnh 'xóa'. Ví dụ: xóa Tên Playlist");
            } else {
                System.out.println("[GeminiPlaylistServlet] Nhận lệnh xóa playlist: " + playlistNameToDelete);
                boolean deleted = playlistDAO.deletePlaylistByNameAndUser(playlistNameToDelete, userId);
                if (deleted) {
                    jsonResponseMap.put("success", true);
                    jsonResponseMap.put("message", "Playlist '" + playlistNameToDelete + "' đã được xóa thành công.");
                    request.getSession().setAttribute("successMessage", "Playlist '" + playlistNameToDelete + "' đã được xóa!");
                } else {
                    jsonResponseMap.put("success", false);
                    jsonResponseMap.put("message", "Không thể xóa playlist '" + playlistNameToDelete + "'. Playlist không tồn tại hoặc có lỗi xảy ra.");
                    request.getSession().setAttribute("errorMessage", "Không thể xóa playlist '" + playlistNameToDelete + "'.");
                }
            }
            response.getWriter().write(gson.toJson(jsonResponseMap));
            return; 
        }

        // NẾU KHÔNG PHẢI LỆNH XÓA, TIẾP TỤC LOGIC TẠO PLAYLIST
        String playlistName = "";
        List<Integer> songIdsForPlaylist = new ArrayList<>();
        boolean processedDirectly = false;
        String detectedArtist = null; 
        String detectedGenre = null;  

        List<String> artistsInDB = songDAO.getDistinctArtists();
        for (String artist : artistsInDB) {
            if (artist.length() > 1 && descriptionLower.contains(artist.toLowerCase())) { 
                detectedArtist = artist;
                break;
            }
        }

        if (detectedArtist != null) {
            System.out.println("[GeminiPlaylistServlet] Phát hiện nghệ sĩ: " + detectedArtist);
            List<Songs> artistSongs = songDAO.getSongsByArtist(detectedArtist);
            if (!artistSongs.isEmpty()) {
                playlistName = "Nhạc của " + detectedArtist;
                for (Songs song : artistSongs) {
                    songIdsForPlaylist.add(song.getSongID());
                }
                processedDirectly = true;
                jsonResponseMap.put("info", "Playlist tạo dựa trên nghệ sĩ: " + detectedArtist);
            }
        }

        if (!processedDirectly) {
            List<String> genresInDB = songDAO.getDistinctGenres();
            for (String genre : genresInDB) {
                if (genre.length() > 1 && descriptionLower.contains(genre.toLowerCase())) {
                     if (descriptionLower.matches(".*\\b" + Pattern.quote(genre.toLowerCase()) + "\\b.*")) {
                         detectedGenre = genre;
                         break;
                     }
                }
            }

            if (detectedGenre != null) {
                System.out.println("[GeminiPlaylistServlet] Phát hiện thể loại: " + detectedGenre);
                List<Songs> genreSongs = songDAO.getSongsByGenre(detectedGenre, 15);
                if (!genreSongs.isEmpty()) {
                    playlistName = "Playlist nhạc " + detectedGenre;
                    for (Songs song : genreSongs) {
                        songIdsForPlaylist.add(song.getSongID());
                    }
                    processedDirectly = true;
                    jsonResponseMap.put("info", "Playlist tạo dựa trên thể loại: " + detectedGenre);
                }
            }
        }

        if (!processedDirectly) {
            System.out.println("[GeminiPlaylistServlet] Không phát hiện nghệ sĩ/thể loại, sử dụng Gemini API...");
            try {
                List<Songs> allDbSongs = songDAO.getAllActiveSongs();
                if (allDbSongs.isEmpty()) {
                    jsonResponseMap.put("success", false);
                    jsonResponseMap.put("message", "Thư viện nhạc trống. Không thể tạo playlist bằng AI.");
                    response.getWriter().write(gson.toJson(jsonResponseMap));
                    return;
                }

                List<GeminiApiService.SuggestedSong> suggestedSongsFromAI = geminiService.getSongSuggestions(description, allDbSongs);
                if (suggestedSongsFromAI.isEmpty()) {
                    jsonResponseMap.put("success", false);
                    jsonResponseMap.put("message", "AI không tìm thấy gợi ý nào từ thư viện cho mô tả này.");
                    response.getWriter().write(gson.toJson(jsonResponseMap));
                    return;
                }

                List<String> foundSongTitlesForMessage = new ArrayList<>();
                List<String> aiSuggestionsNotFoundInOurParse = new ArrayList<>();

                for (GeminiApiService.SuggestedSong suggestedSongAI : suggestedSongsFromAI) {
                    Optional<Songs> matchedSongOpt = allDbSongs.stream()
                        .filter(dbSong -> dbSong.getTitle().equalsIgnoreCase(suggestedSongAI.title.trim()) &&
                                         dbSong.getArtist().equalsIgnoreCase(suggestedSongAI.artist.trim()))
                        .findFirst();

                    if (matchedSongOpt.isPresent()) {
                        Songs matchedSong = matchedSongOpt.get();
                        if (!songIdsForPlaylist.contains(matchedSong.getSongID())) {
                            songIdsForPlaylist.add(matchedSong.getSongID());
                            foundSongTitlesForMessage.add(matchedSong.getTitle() + " - " + matchedSong.getArtist());
                        }
                    } else {
                        aiSuggestionsNotFoundInOurParse.add(suggestedSongAI.title + " - " + suggestedSongAI.artist);
                    }
                }
                
                if (songIdsForPlaylist.isEmpty()) {
                     jsonResponseMap.put("success", false);
                     jsonResponseMap.put("message", "Không tìm thấy bài hát nào trong thư viện khớp với gợi ý từ AI.");
                     if(!aiSuggestionsNotFoundInOurParse.isEmpty()){
                        jsonResponseMap.put("info", "AI gợi ý (nhưng không khớp 100%): " + String.join("; ", aiSuggestionsNotFoundInOurParse));
                     }
                     response.getWriter().write(gson.toJson(jsonResponseMap));
                     return;
                }

                String[] words = descriptionTrimmed.split("\\s+");
                StringBuilder playlistNameBuilder = new StringBuilder("AI: ");
                for (int i = 0; i < Math.min(words.length, 4); i++) {
                    playlistNameBuilder.append(words[i]).append(" ");
                }
                playlistName = playlistNameBuilder.toString().trim();
                if (playlistName.length() > 50) playlistName = playlistName.substring(0, 50) + "...";
                if (playlistName.equals("AI:")) { 
                    playlistName = "AI Playlist " + (System.currentTimeMillis() % 10000);
                }
                 jsonResponseMap.put("info", "Playlist tạo từ mô tả chung bằng Gemini AI.");

            } catch (Exception e) {
                System.err.println("[GeminiPlaylistServlet] Lỗi khi gọi Gemini API: " + e.getMessage());
                e.printStackTrace();
                jsonResponseMap.put("success", false);
                jsonResponseMap.put("message", "Lỗi giao tiếp với AI: " + e.getMessage().substring(0, Math.min(e.getMessage().length(),100))+"...");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(gson.toJson(jsonResponseMap));
                return;
            }
        }

        if (songIdsForPlaylist.isEmpty() && processedDirectly) {
             jsonResponseMap.put("success", false);
             jsonResponseMap.put("message", "Đã phát hiện yêu cầu cho " + (detectedArtist != null ? detectedArtist : detectedGenre) + " nhưng không tìm thấy bài hát.");
             response.getWriter().write(gson.toJson(jsonResponseMap));
             return;
        }
        if (songIdsForPlaylist.isEmpty() && !processedDirectly && !jsonResponseMap.containsKey("message")) { 
             jsonResponseMap.put("success", false);
             jsonResponseMap.put("message", "Không có bài hát nào được chọn.");
             response.getWriter().write(gson.toJson(jsonResponseMap));
             return;
        }
        
        if (playlistName == null || playlistName.trim().isEmpty()) {
            playlistName = "Playlist Tạo Nhanh " + (System.currentTimeMillis() % 10000);
        }
        
        int newPlaylistId = playlistDAO.createPlaylistAndGetId(playlistName, userId);

        if (newPlaylistId > 0) {
            int songsAddedCount = 0;
            List<Integer> distinctSongIds = new ArrayList<>(new java.util.LinkedHashSet<>(songIdsForPlaylist));

            for (int songId : distinctSongIds) {
                if (playlistDAO.addSongToPlaylist(newPlaylistId, songId)) {
                    songsAddedCount++;
                }
            }
            jsonResponseMap.put("success", true);
            jsonResponseMap.put("message", "Playlist '" + playlistName + "' đã được tạo với " + songsAddedCount + " bài hát!");
            jsonResponseMap.put("playlistName", playlistName);
            jsonResponseMap.put("playlistId", newPlaylistId);
            request.getSession().setAttribute("successMessage", "Playlist '" + playlistName + "' đã được tạo!");
        } else {
            jsonResponseMap.put("success", false);
            jsonResponseMap.put("message", "Không thể tạo playlist (có thể tên đã tồn tại hoặc lỗi DB).");
        }
        response.getWriter().write(gson.toJson(jsonResponseMap));
    }
}