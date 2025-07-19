package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Songs;
import dao.SongDAO;
import org.json.JSONObject;
import com.google.gson.Gson;

import java.io.IOException;
import java.util.*;

@WebServlet("/queue")
public class QueueServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if ("get".equals(action)) {
            // Lấy danh sách bài hát tiếp theo
            List<Songs> queue = (List<Songs>) session.getAttribute("queue");
            Songs nowPlaying = (Songs) session.getAttribute("nowPlaying");
            
            List<Map<String, Object>> upNext = new ArrayList<>();
            
            if (queue != null && nowPlaying != null) {
                int index = queue.indexOf(nowPlaying);
                
                for (int i = index + 1; i < Math.min(index + 11, queue.size()); i++) {
                    Songs song = queue.get(i);
                    Map<String, Object> songMap = new HashMap<>();
                    songMap.put("title", song.getTitle());
                    songMap.put("artistName", song.getArtist());
                    songMap.put("filePath", song.getFilePath());
                    songMap.put("duration", song.getDuration());
                    songMap.put("genre", song.getGenre());
                    upNext.add(songMap);
                }
            }
            
            String json = new Gson().toJson(upNext);
            response.getWriter().write(json);
            
        } else if ("getCurrentQueue".equals(action)) {
            // Lấy toàn bộ queue hiện tại
            List<Songs> queue = (List<Songs>) session.getAttribute("queue");
            Songs nowPlaying = (Songs) session.getAttribute("nowPlaying");
            
            // Chuyển đổi Songs objects thành Map để có format nhất quán
            List<Map<String, Object>> queueList = new ArrayList<>();
            if (queue != null) {
                for (Songs song : queue) {
                    Map<String, Object> songMap = new HashMap<>();
                    songMap.put("songID", song.getSongID());
                    songMap.put("title", song.getTitle());
                    songMap.put("artist", song.getArtist()); // Sử dụng "artist" thay vì "artistName"
                    songMap.put("filePath", song.getFilePath());
                    songMap.put("duration", song.getDuration());
                    songMap.put("genre", song.getGenre());
                    queueList.add(songMap);
                }
            }
            
            Map<String, Object> nowPlayingMap = null;
            if (nowPlaying != null) {
                nowPlayingMap = new HashMap<>();
                nowPlayingMap.put("songID", nowPlaying.getSongID());
                nowPlayingMap.put("title", nowPlaying.getTitle());
                nowPlayingMap.put("artist", nowPlaying.getArtist());
                nowPlayingMap.put("filePath", nowPlaying.getFilePath());
                nowPlayingMap.put("duration", nowPlaying.getDuration());
                nowPlayingMap.put("genre", nowPlaying.getGenre());
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("queue", queueList);
            result.put("nowPlaying", nowPlayingMap);
            result.put("queueSize", queueList.size());
            
            String json = new Gson().toJson(result);
            response.getWriter().write(json);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        
                if ("setQueue".equals(action)) {
            try {
                StringBuilder sb = new StringBuilder();
                String line;
                try (java.io.BufferedReader reader = request.getReader()) {
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                
                String requestBody = sb.toString();
                
                if (requestBody.trim().isEmpty()) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("success", false);
                    result.put("message", "Request body is empty");
                    response.getWriter().write(new Gson().toJson(result));
                    return;
                }
                
                System.out.println("Setting queue with data: " + requestBody.substring(0, Math.min(100, requestBody.length())));
                
                JSONObject json = new JSONObject(requestBody);
                String songListJson = json.getString("songList");
                int startIndex = json.optInt("startIndex", 0);
                
                System.out.println("SongList JSON: " + songListJson);
                
                // Parse danh sách bài hát từ JSON
                List<Songs> songList = null;
                try {
                    songList = new Gson().fromJson(songListJson, 
                        new com.google.gson.reflect.TypeToken<List<Songs>>(){}.getType());
                } catch (Exception e) {
                    System.out.println("Error parsing songList JSON: " + e.getMessage());
                    // Fallback: try to fix common JSON issues
                    String fixedJson = songListJson.replaceAll("}}'$", "}]").replaceAll("enre", "genre");
                    System.out.println("Trying fixed JSON: " + fixedJson);
                    songList = new Gson().fromJson(fixedJson, 
                        new com.google.gson.reflect.TypeToken<List<Songs>>(){}.getType());
                }
                
                // Lưu vào session
                session.setAttribute("queue", songList);
                if (songList != null && !songList.isEmpty() && startIndex < songList.size()) {
                    session.setAttribute("nowPlaying", songList.get(startIndex));
                }
                
                System.out.println("Queue saved to session. Size: " + (songList != null ? songList.size() : 0));
                
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Queue đã được cập nhật");
                result.put("queueSize", songList != null ? songList.size() : 0);
                
                response.getWriter().write(new Gson().toJson(result));

            } catch (Exception e) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", false);
                result.put("message", "Lỗi khi cập nhật queue: " + e.getMessage());
                response.getWriter().write(new Gson().toJson(result));
            }
        } else if ("updateNowPlaying".equals(action)) {
            // Cập nhật bài hát đang phát
            try {
                StringBuilder sb = new StringBuilder();
                String line;
                try (java.io.BufferedReader reader = request.getReader()) {
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                
                JSONObject json = new JSONObject(sb.toString());
                int songId = json.getInt("songId");
                
                // Lấy queue hiện tại
                List<Songs> queue = (List<Songs>) session.getAttribute("queue");
                if (queue != null) {
                    // Tìm bài hát theo songId
                    Songs nowPlaying = queue.stream()
                        .filter(song -> song.getSongID() == songId)
                        .findFirst()
                        .orElse(null);
                    
                    if (nowPlaying != null) {
                        session.setAttribute("nowPlaying", nowPlaying);
                        
                        Map<String, Object> result = new HashMap<>();
                        result.put("success", true);
                        result.put("message", "NowPlaying đã được cập nhật");
                        
                        String resultJson = new Gson().toJson(result);
                        response.getWriter().write(resultJson);
                    } else {
                        Map<String, Object> result = new HashMap<>();
                        result.put("success", false);
                        result.put("message", "Không tìm thấy bài hát với ID: " + songId);
                        
                        String resultJson = new Gson().toJson(result);
                        response.getWriter().write(resultJson);
                    }
                } else {
                    Map<String, Object> result = new HashMap<>();
                    result.put("success", false);
                    result.put("message", "Không có queue nào");
                    
                    String resultJson = new Gson().toJson(result);
                    response.getWriter().write(resultJson);
                }
                
            } catch (Exception e) {
                Map<String, Object> result = new HashMap<>();
                result.put("success", false);
                result.put("message", "Lỗi khi cập nhật nowPlaying: " + e.getMessage());
                
                String resultJson = new Gson().toJson(result);
                response.getWriter().write(resultJson);
            }
        }
    }
}
