package controller.fav;

import dao.FavoriteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Songs;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet("/favorites")
public class FavoriteSongsServlet extends HttpServlet {
    private FavoriteDAO favoriteDAO = new FavoriteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) return;

        try {
            List<Songs> favoriteSongs = favoriteDAO.getFavoriteSongs(user.getUserId());
            request.setAttribute("favoriteSongs", favoriteSongs);
            request.getRequestDispatcher("/WEB-INF/views/layouts/sidebar-favorites.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}