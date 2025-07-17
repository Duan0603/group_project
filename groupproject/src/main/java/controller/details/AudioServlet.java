package controller.details;

import dao.ListeningHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;

@WebServlet("/play")
public class AudioServlet extends HttpServlet {

    private File SONG_DIRECTORY;
    private final ListeningHistoryDAO historyDAO = new ListeningHistoryDAO(); // ✅ thêm DAO

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
        String songIdParam = request.getParameter("songId"); // ✅ lấy songId để ghi log
        Integer userId = (Integer) request.getSession().getAttribute("userId");

        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tên file");
            return;
        }

        // ✅ Ghi lịch sử nghe nếu có đủ thông tin
        if (userId != null && songIdParam != null) {
            try {
                int songId = Integer.parseInt(songIdParam);
                historyDAO.addHistory(userId, songId);
            } catch (NumberFormatException ignored) {}
        }

        fileName = new File(fileName).getName(); // ngăn path traversal
        File file = new File(SONG_DIRECTORY, fileName);

        if (!file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File không tồn tại");
            return;
        }

        String mimeType = getServletContext().getMimeType(fileName);
        if (mimeType == null) mimeType = "audio/mpeg";

        response.setContentType(mimeType);
        response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
        response.setContentLengthLong(file.length());

        try (BufferedInputStream in = new BufferedInputStream(new FileInputStream(file));
             OutputStream out = response.getOutputStream()) {

            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }

        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi khi stream tệp: " + e.getMessage());
        }
    }
}
