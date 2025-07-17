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

        // Lấy tên playlist từ URL
        String playlistName = request.getParameter("name");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Kiểm tra người dùng đã đăng nhập chưa
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Kiểm tra nếu tên playlist không rỗng và tồn tại
        if (playlistName != null && !playlistName.isEmpty()) {
            // Lấy playlist theo tên
            Playlist playlist = playlistDAO.getPlaylistByName(playlistName, user.getUserId());

            if (playlist != null) {
                // Lấy danh sách bài hát trong playlist
                List<Songs> songs = songDAO.getSongsByPlaylistId(playlist.getPlaylistID());
                
                // Truyền thông tin playlist và các bài hát vào request
                request.setAttribute("playlist", playlist);
                request.setAttribute("songs", songs);
                
                // Forward đến trang playlistDetail.jsp
                request.getRequestDispatcher("/WEB-INF/views/playlistDetail.jsp").forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Playlist không tồn tại.");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tên playlist không hợp lệ.");
        }
    }
}
