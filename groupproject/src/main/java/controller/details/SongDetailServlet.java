package controller.details;

import dao.SongDAO;
import model.Songs;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/songDetail")
public class SongDetailServlet extends HttpServlet {
    private SongDAO songDAO = new SongDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String songTitle = request.getParameter("title");

        // Kiểm tra nếu tham số title không có giá trị
        if (songTitle == null || songTitle.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing song title");
            return;
        }

        // Lấy thông tin bài hát từ SongDAO
        Songs song = songDAO.getSongByTitle(songTitle);

// Nếu không tìm thấy bài hát
if (song == null) {
    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Song not found");
    return;
}

// Lấy các bài hát khác trong cùng album, ngoại trừ bài này
List<Songs> sameAlbumSongs = songDAO.getSongsByAlbum(song.getAlbum(), song.getSongID());

request.setAttribute("song", song);
request.setAttribute("sameAlbumSongs", sameAlbumSongs);

// Chuyển tiếp đến JSP
request.getRequestDispatcher("/WEB-INF/views/details/songDetail.jsp").forward(request, response);
}
}
