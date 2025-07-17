package controller.details;

import dao.SongDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.Songs;

@WebServlet(name = "ArtistSongsServlet", urlPatterns = {"/artistsongs"})
public class ArtistSongsServlet extends HttpServlet {
    private SongDAO songDAO = new SongDAO();

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

        // Chuẩn hóa tên để lấy ảnh
        String imageName = normalize(artistName) + ".png";
        request.setAttribute("artistImage", imageName);

        // Lấy danh sách bài hát theo nghệ sĩ
        List<Songs> songs = songDAO.getSongsByArtist(artistName);
        request.setAttribute("songs", songs);

        if (songs == null || songs.isEmpty()) {
            request.setAttribute("message", "Không tìm thấy bài hát nào cho nghệ sĩ này.");
        }

        // Tổng thời lượng
        int totalDuration = 0;
        for (Songs s : songs) {
            totalDuration += s.getDuration();
        }
        request.setAttribute("totalDuration", totalDuration);

        request.setAttribute("artistName", artistName);
        request.getRequestDispatcher("/WEB-INF/views/details/artistSongs.jsp").forward(request, response);
    }

    private String normalize(String input) {
        if (input == null) return "";
        return input.toLowerCase().replaceAll("[^a-z0-9]", "");
    }
}