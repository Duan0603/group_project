package controller.details;

import dao.ListeningHistoryDAO;
import dao.SongDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Songs;

import java.io.*;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/play")
public class AudioServlet extends HttpServlet {

    private File SONG_DIRECTORY;
    private final ListeningHistoryDAO historyDAO = new ListeningHistoryDAO();
    private final SongDAO songDAO = new SongDAO();

    @Override
    public void init() throws ServletException {
        String path = getServletContext().getRealPath("/songs");
        SONG_DIRECTORY = new File(path);
        if (!SONG_DIRECTORY.exists()) {
            SONG_DIRECTORY.mkdirs();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fileName = request.getParameter("file");
        String songIdParam = request.getParameter("songId");
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tên file");
            return;
        }

        fileName = new File(fileName).getName();
        File file = new File(SONG_DIRECTORY, fileName);

        if (!file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File không tồn tại");
            return;
        }

        // Ghi lịch sử nghe
        Songs currentSong = null;
        if (userId != null && songIdParam != null) {
            try {
                int songId = Integer.parseInt(songIdParam);
                currentSong = songDAO.getSongById(songId);
                historyDAO.addHistory(userId, songId);
            } catch (NumberFormatException ignored) {
            }
        }

        // Nếu có currentSong thì set session queue + nowPlaying
        if (currentSong != null) {
            Set<String> genreSet = new HashSet<>();
            String[] genres = currentSong.getGenre().split("[,\\s]+");
            for (String genre : genres) {
                if (!genre.trim().isEmpty()) {
                    genreSet.add(genre.trim().toLowerCase());
                }
            }

            List<Songs> queue = songDAO.getSongsByGenres(genreSet, currentSong.getSongID());
            queue.add(0, currentSong);

            session.setAttribute("nowPlaying", currentSong);
            session.setAttribute("queue", queue);
        }

        // Stream audio with Range support (tua nhạc)
        String mimeType = getServletContext().getMimeType(fileName);
        if (mimeType == null) {
            mimeType = "audio/mpeg";
        }

        String range = request.getHeader("Range");
        try (RandomAccessFile raf = new RandomAccessFile(file, "r")) {
            long fileLength = file.length();
            long start = 0;
            long end = fileLength - 1;

            if (range != null && range.startsWith("bytes=")) {
                String[] parts = range.substring(6).split("-");
                try {
                    start = Long.parseLong(parts[0]);
                    if (parts.length > 1) {
                        end = Long.parseLong(parts[1]);
                    }
                } catch (NumberFormatException e) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Range không hợp lệ");
                    return;
                }
            }

            long contentLength = end - start + 1;

            response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            response.setContentType(mimeType);
            response.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLength);
            response.setHeader("Accept-Ranges", "bytes");
            response.setHeader("Content-Length", String.valueOf(contentLength));

            try (OutputStream out = response.getOutputStream()) {
                raf.seek(start);
                byte[] buffer = new byte[8192];
                long remaining = contentLength;
                int bytesRead;

                while (remaining > 0 &&
                        (bytesRead = raf.read(buffer, 0, (int) Math.min(buffer.length, remaining))) != -1) {
                    out.write(buffer, 0, bytesRead);
                    remaining -= bytesRead;
                }
            }
        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi khi stream tệp: " + e.getMessage());
        }
    }
}
