package controller;

import dao.PlaylistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/removeSongFromPlaylist")
public class RemoveSongFromPlaylistServlet extends HttpServlet {
    private PlaylistDAO playlistDAO;

    @Override
    public void init() throws ServletException {
        playlistDAO = new PlaylistDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String playlistIdStr = request.getParameter("playlistId");
        String songIdStr = request.getParameter("songId");
        int playlistId = -1;
        int songId = -1;
        try {
            playlistId = Integer.parseInt(playlistIdStr);
            songId = Integer.parseInt(songIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ");
            return;
        }
        boolean removed = playlistDAO.removeSongFromPlaylist(playlistId, songId);
        if (removed) {
            request.getSession().setAttribute("successMessagePlaylist", "Đã xóa bài hát khỏi playlist.");
        } else {
            request.getSession().setAttribute("errorMessagePlaylist", "Không thể xóa bài hát khỏi playlist.");
        }
        response.sendRedirect(request.getContextPath() + "/playlistDetail?playlistId=" + playlistId);
    }
} 