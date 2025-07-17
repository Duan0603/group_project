package controller.fav;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.FavoriteDAO;
import dao.SongDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Songs;
import model.User;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Set;

@WebServlet("/favorite")
public class FavoriteServlet extends HttpServlet {

    private FavoriteDAO favoriteDAO;
    private SongDAO songDAO;

    @Override
    public void init() throws ServletException {
        try {
            favoriteDAO = new FavoriteDAO();
            songDAO = new SongDAO();
        } catch (Exception e) {
            throw new ServletException("Lỗi khởi tạo DAO: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject json = new JsonObject();

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            json.addProperty("success", false);
            json.addProperty("redirectToLogin", true);
            out.print(json);
            out.flush();
            return;
        }

        try {
            int userId = user.getUserId();
            String songIdStr = request.getParameter("songId");
            String action = request.getParameter("action");
            String songTitle = request.getParameter("title");

            // Kiểm tra dữ liệu đầu vào
            if (songIdStr == null || action == null || songTitle == null) {
                json.addProperty("success", false);
                json.addProperty("error", "Dữ liệu yêu cầu không hợp lệ");
                out.print(json);
                out.flush();
                return;
            }

            int songId;
            try {
                songId = Integer.parseInt(songIdStr);
            } catch (NumberFormatException e) {
                json.addProperty("success", false);
                json.addProperty("error", "ID bài hát không hợp lệ");
                out.print(json);
                out.flush();
                return;
            }

            boolean success = false;
            if ("add".equalsIgnoreCase(action)) {
                success = favoriteDAO.addFavorite(userId, songId);
            } else if ("remove".equalsIgnoreCase(action)) {
                success = favoriteDAO.removeFavorite(userId, songId);
            } else {
                json.addProperty("success", false);
                json.addProperty("error", "Hành động không hợp lệ");
                out.print(json);
                out.flush();
                return;
            }

            // Cập nhật favoriteSongIds trong session
            Set<Integer> favoriteSongIds = favoriteDAO.getFavoriteSongIdsByUser(userId);
            session.setAttribute("favoriteSongIds", favoriteSongIds);

            // Cập nhật số lượng bài hát yêu thích
            int favoriteCount = favoriteDAO.getFavoriteCountByUser(userId);
            session.setAttribute("favoriteCount", favoriteCount);

            // Lấy thông tin bài hát nếu thành công
            if (success) {
                Songs song = songDAO.getSongByTitle(songTitle);
                if (song != null) {
                    JsonObject songJson = new JsonObject();
                    songJson.addProperty("title", song.getTitle());
                    songJson.addProperty("artist", song.getArtist() != null ? song.getArtist() : "");
                    songJson.addProperty("coverImage", "songImages/" + (song.getCoverImage() != null ? song.getCoverImage() : "default.jpg"));
                    json.add("song", songJson);
                }
            }

            // Trả về danh sách favoriteSongIds
            JsonArray favoriteIdsJson = new JsonArray();
            for (Integer id : favoriteSongIds) {
                favoriteIdsJson.add(id);
            }
            json.add("favoriteSongIds", favoriteIdsJson);

            json.addProperty("success", success);
            json.addProperty("likedNow", "add".equalsIgnoreCase(action));
            out.print(json);
            out.flush();

        } catch (SQLException e) {
            json.addProperty("success", false);
            json.addProperty("error", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            out.print(json);
            out.flush();
        } catch (Exception e) {
            json.addProperty("success", false);
            json.addProperty("error", "Lỗi server: " + e.getMessage());
            out.print(json);
            out.flush();
        } finally {
            out.close();
        }
    }
}