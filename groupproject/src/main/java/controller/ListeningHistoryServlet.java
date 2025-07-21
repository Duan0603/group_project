package controller;

import dao.ListeningHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Songs;
import model.User;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.util.List;

@WebServlet("/listening-history")
public class ListeningHistoryServlet extends HttpServlet {

    private ListeningHistoryDAO historyDAO = new ListeningHistoryDAO(); // Sử dụng đối tượng toàn cục

    // Xử lý lưu lịch sử nghe nhạc
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"User not logged in\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String songIdParam = request.getParameter("songId");

        if (songIdParam != null && songIdParam.matches("\\d+")) {
            int songId = Integer.parseInt(songIdParam);
            try {
                historyDAO.addHistory(user.getUserId(), songId); // Lưu lịch sử
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": true}");
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\": false, \"message\": \"Failed to save history\"}");
                e.printStackTrace();
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid song ID\"}");
        }
    }

    // Lấy lịch sử nghe nhạc của người dùng (5 bài gần nhất)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("[]");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();

        // Lấy 5 bài hát gần nhất
        List<Songs> recentSongs = historyDAO.getRecentHistory(userId, 5);

        // Chuyển danh sách bài hát thành JSON
        JSONArray jsonArray = new JSONArray();
        for (Songs song : recentSongs) {
            JSONObject obj = new JSONObject();
            obj.put("songID", song.getSongID());
            obj.put("title", song.getTitle());
            obj.put("artist", song.getArtist());
            obj.put("filePath", song.getFilePath());
            obj.put("thumbnail", song.getCoverImage()); // hoặc coverImage
            jsonArray.put(obj);
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonArray.toString());
    }
}
