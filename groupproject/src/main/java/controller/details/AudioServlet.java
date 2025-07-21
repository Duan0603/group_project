package controller.details;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;

@WebServlet("/play")
public class AudioServlet extends HttpServlet {

    private File SONG_DIRECTORY;

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

        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tên file");
            return;
        }

        fileName = new File(fileName).getName(); // Ngăn path traversal
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
