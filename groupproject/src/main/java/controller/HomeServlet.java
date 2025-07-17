package controller;

import dao.SongDAO;
import dao.LikeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Songs;
import model.User;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        SongDAO songDAO = new SongDAO();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        String action = request.getParameter("action");
        String title = request.getParameter("title");
        String albumNameParam = request.getParameter("name");

        // ==============================================
        // XỬ LÝ NGHỆ SĨ (hiển thị danh sách bài hát nghệ sĩ)
        if ("artist".equals(action)) {
            String artistName = request.getParameter("name");
            if (artistName != null && !artistName.trim().isEmpty()) {
                List<Songs> artistSongs = songDAO.getSongsByArtist(artistName);
                request.setAttribute("artistSongs", artistSongs);
                request.setAttribute("selectedArtist", artistName);
            }
        }

        // ==============================================
        // XỬ LÝ ALBUM DETAIL (nếu có param name)
        if (albumNameParam != null && !albumNameParam.trim().isEmpty()) {
            List<Songs> songsToDisplay = new ArrayList<>();
            Songs mainSong = null;

            // Lấy danh sách bài hát trong album
            List<Songs> songsByAlbum = songDAO.getSongsByAlbum(albumNameParam);
            if (songsByAlbum != null && !songsByAlbum.isEmpty()) {
                songsToDisplay = songsByAlbum;
                mainSong = songsByAlbum.get(0); // mặc định bài đầu tiên
            } else {
                // Trường hợp là đĩa đơn
                mainSong = songDAO.getSongByTitle(albumNameParam);
                if (mainSong != null) {
                    songsToDisplay.add(mainSong);
                }
            }

            // Nếu có bài cụ thể được chọn
            if (title != null && !title.trim().isEmpty()) {
                Songs songToPlay = songDAO.getSongByTitle(title);
                if (songToPlay != null) {
                    request.setAttribute("songToPlay", songToPlay);
                    mainSong = songToPlay;
                }
            } else if (mainSong != null) {
                request.setAttribute("songToPlay", mainSong);
            }

            // Gán dữ liệu cho album.jsp
            request.setAttribute("songs", songsToDisplay);
            request.setAttribute("albumName", (mainSong != null) ? mainSong.getAlbum() : albumNameParam);
            request.setAttribute("coverImage", (mainSong != null && mainSong.getCoverImage() != null)
                    ? mainSong.getCoverImage() : "default.jpg");
            request.setAttribute("totalDuration", songsToDisplay.stream().mapToInt(Songs::getDuration).sum());

            // Gợi ý cùng thể loại
            if (mainSong != null && mainSong.getGenre() != null) {
                List<Songs> sameGenre = songDAO.getSongsByGenre(mainSong.getGenre(), mainSong.getSongID());
                request.setAttribute("sameGenreSongs", sameGenre);
            }

            request.getRequestDispatcher("/WEB-INF/views/details/album.jsp").forward(request, response);
            return;
        }

        // ==============================================
        // TRANG CHỦ - nếu không có albumNameParam
        if (title != null && !title.trim().isEmpty()) {
            Songs song = songDAO.getSongByTitle(title);
            if (song != null) {
                request.setAttribute("songToPlay", song);
                // Bổ sung truyền mediaInfo cho player.jsp
                User currentUser = (User) session.getAttribute("user");
                boolean liked = false;
                if (currentUser != null) {
                    LikeDAO likeDAO = new LikeDAO();
                    liked = likeDAO.isSongLiked(currentUser.getUserId(), song.getSongID());
                }
                Map<String, Object> mediaInfo = new HashMap<>();
                mediaInfo.put("songId", song.getSongID());
                mediaInfo.put("liked", liked);
                mediaInfo.put("thumbnail", song.getCoverImage());
                mediaInfo.put("title", song.getTitle());
                mediaInfo.put("artist", song.getArtist());
                request.setAttribute("mediaInfo", mediaInfo);
            }
        }

        request.setAttribute("newSongs", songDAO.getNewReleasedSongs());
        request.setAttribute("allSongs", songDAO.getAllActiveSongs());

        if (user != null) {
            request.setAttribute("recommended", songDAO.getRecommendedSongs(user.getUserId()));
            request.setAttribute("recentSongs", songDAO.getRecentlyPlayedSongs(user.getUserId()));
            request.setAttribute("recentArtists", songDAO.getRecentArtists(user.getUserId()));
            request.setAttribute("favorites", songDAO.getUserFavorites(user.getUserId()));
        }

        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}