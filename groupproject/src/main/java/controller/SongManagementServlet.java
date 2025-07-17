package controller;

import dao.SongDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import model.Songs;

@WebServlet(name = "SongManagementServlet", urlPatterns = {"/admin/songs"})
public class SongManagementServlet extends HttpServlet {

    private SongDAO songDAO;

    @Override
    public void init() throws ServletException {
        songDAO = new SongDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        try {
            switch (action) {
                case "add":
                    addSong(request, response);
                    break;
                case "delete":
                    deleteSong(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void addSong(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        String title = request.getParameter("title");
        String artist = request.getParameter("artist");
        String album = request.getParameter("album");
        String genre = request.getParameter("genre");
        int duration = Integer.parseInt(request.getParameter("duration"));
        Date releaseDate = Date.valueOf(request.getParameter("releaseDate"));
        String filePath = request.getParameter("filePath");
        String coverImage = request.getParameter("coverImage");

        Songs newSong = new Songs();
        newSong.setTitle(title);
        newSong.setArtist(artist);
        newSong.setAlbum(album);
        newSong.setGenre(genre);
        newSong.setDuration(duration);
        newSong.setReleaseDate(releaseDate);
        newSong.setFilePath(filePath);
        newSong.setCoverImage(coverImage);

        songDAO.addSong(newSong);
        response.sendRedirect(request.getContextPath() + "/admin#songs");
    }

    private void deleteSong(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        int songId = Integer.parseInt(request.getParameter("songId"));
        songDAO.deleteSong(songId);
        response.sendRedirect(request.getContextPath() + "/admin#songs");
    }
}
