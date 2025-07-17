package controller;

import dao.PlaylistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/addSongsToPlaylist")
public class AddSongsToPlaylistServlet extends HttpServlet {
    private PlaylistDAO playlistDAO;

    @Override
    public void init() {
        playlistDAO = new PlaylistDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String playlistIdStr = request.getParameter("playlistId");
        String[] selectedSongIdsStr = request.getParameterValues("selectedSongIds");

        if (playlistIdStr == null || playlistIdStr.isEmpty()) {
            request.getSession().setAttribute("errorMessagePlaylist", "Lỗi: Không tìm thấy ID của playlist.");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int playlistId = -1;
        try {
            playlistId = Integer.parseInt(playlistIdStr);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessagePlaylist", "Lỗi: ID playlist không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int songsSuccessfullyAdded = 0;
        if (selectedSongIdsStr != null) {
            for (String songIdStr : selectedSongIdsStr) {
                try {
                    int songId = Integer.parseInt(songIdStr);
                    if (playlistDAO.addSongToPlaylist(playlistId, songId)) {
                        songsSuccessfullyAdded++;
                    }
                } catch (NumberFormatException ignored) {}
            }
        }

        if (songsSuccessfullyAdded > 0) {
            request.getSession().setAttribute("successMessagePlaylist", "Đã thêm " + songsSuccessfullyAdded + " bài hát vào playlist.");
        } else {
            request.getSession().setAttribute("errorMessagePlaylist", "Không có bài hát nào được thêm.");
        }

        response.sendRedirect(request.getContextPath() + "/playlistDetail?playlistId=" + playlistId);
    }
}