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

@WebServlet(name = "PlaylistServlet", urlPatterns = {"/playlist", "/addSongToPlaylist"})
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
            response.getWriter().write(new Gson().toJson(Map.of(
                    "success", false,
                    "message", "Vui lòng đăng nhập."
            )));
            return;
        }

        PlaylistDAO playlistDAO = new PlaylistDAO();

        switch (action) {
            case "createPlaylist":
                String playlistName = request.getParameter("name");
                String description = Optional.ofNullable(request.getParameter("description")).orElse("");
                boolean isPublic = Boolean.parseBoolean(request.getParameter("isPublic"));

                Playlist playlist = new Playlist(
                        0, // playlistID
                        user.getUserId(),
                        0, // songID (không cần khi tạo playlist mới)
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

                response.getWriter().write(new Gson().toJson(result));
                break;

            case "addSongToPlaylist":
                int playlistId = Integer.parseInt(request.getParameter("playlistId"));
                int songId = Integer.parseInt(request.getParameter("songId"));

                boolean added = playlistDAO.addSongToPlaylist(playlistId, songId);
                response.getWriter().write("{\"success\": " + added + "}");
                break;

            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(new Gson().toJson(Map.of(
                        "success", false,
                        "message", "Yêu cầu không hợp lệ."
                )));
                break;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("getUserPlaylists".equals(action) && user != null) {
            PlaylistDAO playlistDAO = new PlaylistDAO();
            List<Playlist> playlists = playlistDAO.getPlaylistsByUser(user.getUserId());
            response.getWriter().write(new Gson().toJson(playlists));
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(new Gson().toJson(Map.of(
                    "success", false,
                    "message", "Vui lòng đăng nhập hoặc sai action."
            )));
        }
    }
}
