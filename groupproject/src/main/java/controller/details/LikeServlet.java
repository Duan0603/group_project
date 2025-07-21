package controller.details;

import dao.LikeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "LikeServlet", urlPatterns = {"/details/like", "/details/liked-songs"})
public class LikeServlet extends HttpServlet {
    private LikeDAO likeDAO = new LikeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("likedSongs".equals(action)) {
            // Lấy userId từ session (giả sử đã lưu user khi đăng nhập)
            jakarta.servlet.http.HttpSession session = request.getSession();
            model.User user = (model.User) session.getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
                return;
            }
            int userId = user.getUserId();
            java.util.List<model.Songs> likedSongs = likeDAO.getLikedSongsByUserId(userId);
            request.setAttribute("likedSongs", likedSongs);
            request.getRequestDispatcher("/WEB-INF/views/details/likedSongs.jsp").forward(request, response);
            return;
        }
        int userId = Integer.parseInt(request.getParameter("userId"));
        int songId = Integer.parseInt(request.getParameter("songId"));
        boolean liked = likeDAO.isLiked(userId, songId);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"liked\":" + liked + "}");
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        int songId = Integer.parseInt(request.getParameter("songId"));
        boolean success = likeDAO.addLike(userId, songId);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + ",\"liked\":true}");
        out.flush();
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        int songId = Integer.parseInt(request.getParameter("songId"));
        boolean success = likeDAO.removeLike(userId, songId);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\":" + success + ",\"liked\":false}");
        out.flush();
    }
} 