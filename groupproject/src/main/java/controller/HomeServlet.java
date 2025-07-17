package controller;

import dao.FavoriteDAO;
import dao.ListeningHistoryDAO;
import dao.SongDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Songs;
import model.User;

import java.io.IOException;
import java.util.Set;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {
    private SongDAO songDAO;
    private FavoriteDAO favoriteDAO;

    @Override
    public void init() throws ServletException {
        try {
            songDAO = new SongDAO();
            favoriteDAO = new FavoriteDAO();
        } catch (Exception e) {
            throw new ServletException("Lỗi khởi tạo DAO: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;

            String title = request.getParameter("title");
            if (title != null && !title.trim().isEmpty()) {
                Songs song = songDAO.getSongByTitle(title);
                if (song != null) {
                    request.setAttribute("songToPlay", song);
                } else {
                    request.setAttribute("error", "Không tìm thấy bài hát với tiêu đề: " + title);
                }
            }

            // Dữ liệu trang chủ
            request.setAttribute("newSongs", songDAO.getNewReleasedSongs());
            request.setAttribute("allSongs", songDAO.getAllActiveSongs());

            // Dữ liệu cho người dùng đã đăng nhập
            if (user != null) {
                request.setAttribute("recommended", songDAO.getRecommendedSongs(user.getUserId()));
                request.setAttribute("recentSongs", songDAO.getRecentlyPlayedSongs(user.getUserId()));
                request.setAttribute("recentArtists", songDAO.getRecentArtists(user.getUserId()));
                request.setAttribute("favorites", favoriteDAO.getFavoriteSongs(user.getUserId()));
                // Cập nhật favoriteSongIds
                Set<Integer> favoriteSongIds = favoriteDAO.getFavoriteSongIdsByUser(user.getUserId());
                session.setAttribute("favoriteSongIds", favoriteSongIds);
                
                ListeningHistoryDAO historyDAO = new ListeningHistoryDAO();
    request.setAttribute("listeningHistory", historyDAO.getHistoryByUser(user.getUserId()));
            }

            request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải trang chủ: " + e.getMessage());
        }
    }
}