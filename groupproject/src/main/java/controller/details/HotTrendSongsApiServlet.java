package controller.details;

import dao.SongDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Songs;
import java.io.IOException;
import java.util.*;

@WebServlet(name = "HotTrendSongsApiServlet", urlPatterns = {"/api/hottrend-songs"})
public class HotTrendSongsApiServlet extends HttpServlet {
    private final SongDAO songDAO = new SongDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String rawTitle = request.getParameter("name");
        String songTitle = rawTitle != null ? java.net.URLDecoder.decode(rawTitle.trim(), java.nio.charset.StandardCharsets.UTF_8) : null;
        java.util.List<model.Songs> songs = new java.util.ArrayList<>();
        java.util.Set<String> genreKeywords = new java.util.HashSet<>();
        if (songTitle != null && !songTitle.isEmpty()) {
            model.Songs songToPlay = songDAO.getSongByTitle(songTitle);
            if (songToPlay != null && songToPlay.getGenre() != null) {
                String genre = songToPlay.getGenre();
                String[] tokens = genre.split("[,\\s]+");
                for (String token : tokens) {
                    if (!token.trim().isEmpty()) {
                        genreKeywords.add(token.trim().toLowerCase());
                    }
                }
                songs = songDAO.getSongsByGenres(genreKeywords, songToPlay.getSongID());
                songs.add(0, songToPlay);
            }
        }
        if (songs.isEmpty()) {
            songs = songDAO.getAllActiveSongs();
        }
        songs.removeIf(s -> s.getTitle() != null && s.getTitle().equalsIgnoreCase("Sample Song 1"));
        com.google.gson.Gson gson = new com.google.gson.Gson();
        response.getWriter().write(gson.toJson(songs));
    }
} 