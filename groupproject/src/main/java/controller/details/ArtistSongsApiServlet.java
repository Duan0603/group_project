package controller.details;

import dao.SongDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Songs;

@WebServlet(name = "ArtistSongsApiServlet", urlPatterns = {"/api/artist-songs"})
public class ArtistSongsApiServlet extends HttpServlet {
    private SongDAO songDAO = new SongDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String artistName = request.getParameter("artist");
        if (artistName == null || artistName.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Missing artist name\"}");
            return;
        }
        List<Songs> songs = songDAO.getSongsByArtist(artistName);
        com.google.gson.Gson gson = new com.google.gson.Gson();
        response.getWriter().write(gson.toJson(songs));
    }
} 