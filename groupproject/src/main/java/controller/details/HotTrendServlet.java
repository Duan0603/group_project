package controller.details;

import dao.SongDAO;
import dao.PlaylistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Songs;
import model.User;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.net.URLDecoder;
import java.util.*;

@WebServlet("/hot-trend")
public class HotTrendServlet extends HttpServlet {

    private final SongDAO songDAO = new SongDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Lấy và decode tham số đầu vào
        String rawTitle = request.getParameter("name");
        String songTitle = rawTitle != null ? URLDecoder.decode(rawTitle.trim(), StandardCharsets.UTF_8) : null;
        String coverImage = request.getParameter("cover");

        System.out.println("🔥 Tên bài hát được truyền vào: " + songTitle);

        Songs songToPlay = null;
        List<Songs> songs = new ArrayList<>();
        Set<String> genreKeywords = new HashSet<>();
        String genre = "";

        if (songTitle != null && !songTitle.isEmpty()) {
            songToPlay = songDAO.getSongByTitle(songTitle);

            if (songToPlay != null && songToPlay.getGenre() != null) {
                genre = songToPlay.getGenre();
                System.out.println("🎧 Đang phát bài: " + songToPlay.getTitle() + " | Thể loại: " + genre);

                // Tách từ khóa
                String[] tokens = genre.split("[,\\s]+");
                for (String token : tokens) {
                    if (!token.trim().isEmpty()) {
                        genreKeywords.add(token.trim().toLowerCase());
                    }
                }

                songs = songDAO.getSongsByGenres(genreKeywords, songToPlay.getSongID());

                // ➕ Gắn bài đang phát vào đầu danh sách
                songs.add(0, songToPlay);
            }
        }

        if (songs.isEmpty()) {
            songs = songDAO.getAllActiveSongs();
            if (!songs.isEmpty()) {
                songToPlay = songs.get(0);
                genre = "Tất cả";
            }
        }

// ❌ Loại bỏ bài test
        songs.removeIf(s -> s.getTitle() != null && s.getTitle().equalsIgnoreCase("Sample Song 1"));

        int totalDuration = songs.stream().mapToInt(Songs::getDuration).sum();

        // Truyền userPlaylists vào request
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user != null) {
            PlaylistDAO playlistDAO = new PlaylistDAO();
            request.setAttribute("userPlaylists", playlistDAO.getPlaylistsByUser(user.getUserId()));
        }

        request.setAttribute("songs", songs);
        request.setAttribute("songToPlay", songToPlay);
        request.setAttribute("albumName", "Gợi ý từ thể loại: " + genre);
        request.setAttribute("coverImage", coverImage != null ? coverImage : "default.jpg");
        request.setAttribute("totalDuration", totalDuration);

        request.getRequestDispatcher("/WEB-INF/views/details/hotTrend.jsp").forward(request, response);
    }
}
