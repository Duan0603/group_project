package controller;

import com.google.gson.Gson;
import dao.PlaylistDAO;
import dao.SongDAO;
import model.Playlist;
import model.Songs;
import model.User;

import java.io.IOException;
import java.text.Normalizer;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/playlistDetail")
public class PlaylistDetailServlet extends HttpServlet {

    private final PlaylistDAO playlistDAO = new PlaylistDAO();
    private final SongDAO songDAO = new SongDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        if ("getSidebarPlaylists".equals(action)) {
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("[]");
                return;
            }

            List<Playlist> playlists = playlistDAO.getPlaylistsByUser(user.getUserId());
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            new Gson().toJson(playlists, response.getWriter());
            return;
        }

        // ========== DƯỚI ĐÂY LÀ XỬ LÝ TRANG CHI TIẾT PLAYLIST ==========
        String playlistIdStr = request.getParameter("playlistId");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int playlistId;
        try {
            playlistId = Integer.parseInt(playlistIdStr);
            if (playlistId <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID playlist không hợp lệ.");
            return;
        }

        Playlist playlist = playlistDAO.getPlaylistById(playlistId);
        if (playlist == null || playlist.getUserID() != user.getUserId()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Playlist không tồn tại hoặc không thuộc về bạn.");
            return;
        }

        List<Songs> songs = songDAO.getSongsByPlaylistId(playlistId);
        String thumbnail = songs.isEmpty() ? "default.jpg" : toImageFileName(songs.get(0).getTitle());
        playlist.setThumbnail(thumbnail);

        request.setAttribute("playlist", playlist);
        request.setAttribute("songsInPlaylist", songs);
        request.setAttribute("allSongs", songDAO.getAllActiveSongs());

        List<Playlist> userPlaylists = playlistDAO.getPlaylistsByUser(user.getUserId());
        request.setAttribute("userPlaylists", userPlaylists);

        request.getRequestDispatcher("/WEB-INF/views/details/playlistDetail.jsp").forward(request, response);
    }

    private String toImageFileName(String title) {
        if (title == null || title.trim().isEmpty()) return "default.jpg";

        try {
            String noDiacritics = Normalizer.normalize(title, Normalizer.Form.NFD)
                    .replaceAll("[\\p{InCombiningDiacriticalMarks}]", "")
                    .replace("đ", "d").replace("Đ", "D");

            String[] parts = noDiacritics.split("[^a-zA-Z0-9]");
            StringBuilder fileName = new StringBuilder();

            for (String part : parts) {
                if (!part.isEmpty()) {
                    fileName.append(Character.toUpperCase(part.charAt(0)));
                    if (part.length() > 1) fileName.append(part.substring(1));
                }
            }

            return (fileName.length() > 50 ? fileName.substring(0, 50) : fileName) + ".jpg";
        } catch (Exception e) {
            System.err.println("Lỗi tạo tên file ảnh: " + e.getMessage());
            return "default.jpg";
        }
    }
}
