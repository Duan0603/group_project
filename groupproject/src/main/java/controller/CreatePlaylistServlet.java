// Xóa toàn bộ nội dung file này, các chức năng đã được tách sang các servlet riêng biệt.

package controller;

import dao.PlaylistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/createPlaylist")
public class CreatePlaylistServlet extends HttpServlet {
    private PlaylistDAO playlistDAO;

    @Override
    public void init() {
        playlistDAO = new PlaylistDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String playlistName = request.getParameter("playlistName");
        String[] selectedSongIdsStr = request.getParameterValues("selectedSongIds");
        int defaultUserId = 1; // Sửa lại lấy userId thực tế nếu có đăng nhập

        if (playlistName != null && !playlistName.trim().isEmpty()) {
            int newPlaylistId = playlistDAO.createPlaylistAndGetId(playlistName.trim(), defaultUserId);

            if (newPlaylistId > 0) {
                int songsAddedCount = 0;
                if (selectedSongIdsStr != null) {
                    for (String songIdStr : selectedSongIdsStr) {
                        try {
                            int songId = Integer.parseInt(songIdStr);
                            if (playlistDAO.addSongToPlaylist(newPlaylistId, songId)) {
                                songsAddedCount++;
                            }
                        } catch (NumberFormatException ignored) {}
                    }
                }
                request.getSession().setAttribute("successMessage", "Playlist '" + playlistName + "' đã được tạo và " + songsAddedCount + " bài hát đã được thêm!");
            } else {
                request.getSession().setAttribute("errorMessage", "Không thể tạo playlist. Có thể tên đã tồn tại hoặc có lỗi xảy ra.");
            }
        } else {
            request.getSession().setAttribute("errorMessage", "Tên playlist không được để trống.");
        }
        response.sendRedirect(request.getContextPath() + "/home");
    }
}
