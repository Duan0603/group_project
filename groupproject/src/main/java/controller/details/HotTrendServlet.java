package controller.details;

import dao.PlaylistDAO;
import dao.SongDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Playlist;
import model.Songs;
import model.User;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.net.URLDecoder;
import java.util.*;

@WebServlet("/hot-trend")
public class HotTrendServlet extends HttpServlet {

    private final SongDAO songDAO = new SongDAO();
    private final PlaylistDAO playlistDAO = new PlaylistDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Decode title param
        String rawTitle = request.getParameter("name");
        String songTitle = rawTitle != null ? URLDecoder.decode(rawTitle.trim(), StandardCharsets.UTF_8) : null;
        String coverImage = request.getParameter("cover");

        System.out.println(" Tên bài hát được truyền vào: " + songTitle);

        Songs songToPlay = null;
        List<Songs> songs = new ArrayList<>();
        Set<String> genreKeywords = new HashSet<>();
        String genre = "";

        if (songTitle != null && !songTitle.isEmpty()) {
            songToPlay = songDAO.getSongByTitle(songTitle);

            if (songToPlay != null && songToPlay.getGenre() != null) {
                genre = songToPlay.getGenre();
                System.out.println("🎧 Đang phát bài: " + songToPlay.getTitle() + " | Thể loại: " + genre);

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
            if (!songs.isEmpty()) {
                songToPlay = songs.get(0);
                genre = "Tất cả";
            }
        }

        songs.removeIf(s -> s.getTitle() != null && s.getTitle().equalsIgnoreCase("Sample Song 1"));

        int totalDuration = songs.stream().mapToInt(Songs::getDuration).sum();

        request.setAttribute("songs", songs);
        request.setAttribute("songToPlay", songToPlay);
        request.setAttribute("albumName", "Gợi ý từ thể loại: " + genre);
        request.setAttribute("coverImage", coverImage != null ? coverImage : "default.jpg");
        request.setAttribute("totalDuration", totalDuration);

        // ✅ Render playlist sidebar nếu người dùng đã login
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            List<Playlist> playlists = playlistDAO.getPlaylistsByUser(user.getUserId());
            request.setAttribute("userPlaylists", playlists);
        }

        request.getRequestDispatcher("/WEB-INF/views/details/hotTrend.jsp").forward(request, response);
    }
}
