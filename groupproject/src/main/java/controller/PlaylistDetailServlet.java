package controller;

import dao.PlaylistDAO;
import dao.SongDAO;
import model.Playlist;
import model.Songs;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/playlistDetail")
public class PlaylistDetailServlet extends HttpServlet {

    private PlaylistDAO playlistDAO = new PlaylistDAO();
    private SongDAO songDAO = new SongDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String playlistIdStr = request.getParameter("playlistId");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Kiểm tra người dùng đã đăng nhập chưa
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Kiểm tra nếu id playlist hợp lệ
        int playlistId = -1;
        try {
            playlistId = Integer.parseInt(playlistIdStr);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID playlist không hợp lệ.");
            return;
        }
        if (playlistId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID playlist không hợp lệ.");
            return;
        }

        Playlist playlist = playlistDAO.getPlaylistById(playlistId);
        if (playlist == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Playlist không tồn tại.");
            return;
        }

        List<Songs> songs = songDAO.getSongsByPlaylistId(playlistId);
        // Truyền thêm danh sách playlist cho sidebar
        request.setAttribute("userPlaylists", playlistDAO.getPlaylistsByUser(user.getUserId()));
        request.setAttribute("playlist", playlist);
        request.setAttribute("songsInPlaylist", songs);
        // Nếu cần truyền allSongs cho modal thêm bài hát:
        request.setAttribute("allSongs", songDAO.getAllActiveSongs());
        request.getRequestDispatcher("/WEB-INF/views/details/playlistDetail.jsp").forward(request, response);
    }
}
