package controller.details;

import dao.PlaylistDAO;
import dao.SongDAO;
import model.Playlist;
import model.Songs;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ArtistSongsServlet", urlPatterns = {"/artistsongs"})
public class ArtistSongsServlet extends HttpServlet {
    private SongDAO songDAO = new SongDAO();
    private PlaylistDAO playlistDAO = new PlaylistDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String artistName = request.getParameter("artist");

        if (artistName == null || artistName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing artist name");
            return;
        }

        // Normalize image name
        String imageName = normalize(artistName) + ".png";
        request.setAttribute("artistImage", imageName);

        // Lấy danh sách bài hát theo nghệ sĩ
        List<Songs> songs = songDAO.getSongsByArtist(artistName);
        request.setAttribute("songs", songs);

        // Tổng thời lượng
        int totalDuration = songs.stream().mapToInt(Songs::getDuration).sum();
        request.setAttribute("totalDuration", totalDuration);

        request.setAttribute("artistName", artistName);

        // ✅ Gửi playlist của user để render sidebar
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            List<Playlist> userPlaylists = playlistDAO.getPlaylistsByUser(user.getUserId());
            request.setAttribute("userPlaylists", userPlaylists);
        }

        request.getRequestDispatcher("/WEB-INF/views/details/artistSongs.jsp").forward(request, response);
    }

    private String normalize(String input) {
        if (input == null) return "";
        return input.toLowerCase().replaceAll("[^a-z0-9]", "");
    }
}
