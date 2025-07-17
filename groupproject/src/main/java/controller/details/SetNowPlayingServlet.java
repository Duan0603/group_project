package controller.details;

import dao.SongDAO;
import model.Songs;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet("/setNowPlaying")
public class SetNowPlayingServlet extends HttpServlet {
    private final SongDAO songDAO = new SongDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String title = request.getParameter("title");
        if (title == null || title.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Songs song = songDAO.getSongByTitle(title);
        if (song != null) {
            HttpSession session = request.getSession();
            session.setAttribute("nowPlaying", song);
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
