package controller;

import com.google.gson.Gson;
import dao.PlaylistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Playlist;
import model.User;

import java.io.IOException;
import java.util.*;

@WebServlet(name = "PlaylistServlet", urlPatterns = {"/playlist", "/addSongToPlaylist", "/playlist/check"})
public class PlaylistServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(new Gson().toJson(Collections.singletonMap("message", "Vui lòng đăng nhập")));
            return;
        }

        PlaylistDAO playlistDAO = new PlaylistDAO();

        switch (action) {
            case "createPlaylist": {
                String playlistName = request.getParameter("name");
                String description = Optional.ofNullable(request.getParameter("description")).orElse("");
                boolean isPublic = Boolean.parseBoolean(request.getParameter("isPublic"));

                Playlist playlist = new Playlist(
                        0,
                        user.getUserId(),
                        0,
                        playlistName,
                        description,
                        new Date(),
                        isPublic,
                        true
                );

                boolean success = playlistDAO.addPlaylist(playlist);

                Map<String, Object> result = new HashMap<>();
                result.put("success", success);
                result.put("message", success ? "Tạo playlist thành công" : "Tạo playlist thất bại");
                result.put("name", playlistName);
                if (success) {
                    result.put("playlistId", playlist.getPlaylistID()); // ✅ Trả về ID cho JS
                }
                response.getWriter().write(new Gson().toJson(result));
                break;
            }

            case "addSongToPlaylist": {
                try {
                    int playlistId = Integer.parseInt(request.getParameter("playlistId"));
                    int songId = Integer.parseInt(request.getParameter("songId"));

                    if (playlistDAO.isSongInPlaylist(playlistId, songId)) {
                        response.getWriter().write(new Gson().toJson(Map.of(
                                "success", false,
                                "message", "Bài hát đã có trong playlist"
                        )));
                        return;
                    }

                    boolean success = playlistDAO.addSongToPlaylist(playlistId, songId);
                    response.getWriter().write(new Gson().toJson(Map.of(
                            "success", success,
                            "message", success ? "Đã thêm bài hát" : "Thêm thất bại"
                    )));
                } catch (NumberFormatException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write(new Gson().toJson(Collections.singletonMap("message", "Dữ liệu không hợp lệ")));
                }
                break;
            }

            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(new Gson().toJson(Collections.singletonMap("message", "Yêu cầu không hợp lệ")));
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        PlaylistDAO playlistDAO = new PlaylistDAO();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(new Gson().toJson(Map.of(
                    "success", false,
                    "message", "Vui lòng đăng nhập"
            )));
            return;
        }

        // ✅ Xử lý riêng khi gọi /playlist/check
        if (request.getServletPath().equals("/playlist/check")) {
            try {
                int songId = Integer.parseInt(request.getParameter("songId"));
                List<Integer> playlistIds = playlistDAO.getPlaylistIdsContainingSong(user.getUserId(), songId);
                response.getWriter().write(new Gson().toJson(playlistIds));
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(new Gson().toJson(Map.of("error", "ID không hợp lệ")));
            }
            return;
        }

        switch (action) {
            case "getUserPlaylists": {
                List<Playlist> playlists = playlistDAO.getPlaylistsByUser(user.getUserId());
request.setAttribute("userPlaylists", playlists);

                List<Map<String, Object>> result = new ArrayList<>();
                for (Playlist p : playlists) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("playlistId", p.getPlaylistID());
                    map.put("name", p.getName());
                    result.add(map);
                }

                response.getWriter().write(new Gson().toJson(result));
                break;
            }

            case "view": {
                List<Playlist> playlists = playlistDAO.getPlaylistsByUser(user.getUserId());
                request.setAttribute("userPlaylists", playlists);
                request.getRequestDispatcher("/WEB-INF/views/layouts/sidebar.jsp").forward(request, response);
                break;
            }

            default: {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(new Gson().toJson(Collections.singletonMap("message", "Sai action")));
            }
        }
    }
}
