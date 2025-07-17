package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;

@WebServlet("/uploadImage")
@MultipartConfig
public class UploadImageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = request.getParameter("type"); // "artist" hoặc "album"
        String name = request.getParameter("name"); // tên file không có đuôi
        Part filePart = request.getPart("file");

        // Lấy tên file gốc được người dùng upload
        String submittedFileName = filePart.getSubmittedFileName();
        if (submittedFileName == null || !submittedFileName.contains(".")) {
            response.getWriter().println("File không hợp lệ.");
            return;
        }

        // Lấy phần đuôi file (ví dụ: ".png" hoặc ".jpg")
        String extension = submittedFileName.substring(submittedFileName.lastIndexOf(".")).toLowerCase();

        // Chỉ cho phép .jpg và .png
        if (!extension.equals(".jpg") && !extension.equals(".png")) {
            response.getWriter().println("Chỉ hỗ trợ định dạng ảnh .jpg hoặc .png.");
            return;
        }

        // Chọn thư mục lưu ảnh
        String folder = "";
        if ("artist".equalsIgnoreCase(type)) {
            folder = "coverImages";
        } else if ("album".equalsIgnoreCase(type)) {
            folder = "albumImages";
        } else {
            response.getWriter().println("Loại ảnh không hợp lệ (chỉ nhận 'artist' hoặc 'album').");
            return;
        }

        // Tạo thư mục nếu chưa có
        String appPath = request.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + folder;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        // Tạo tên file mới theo name truyền lên
        String fileName = name + extension;

        // Ghi file vào server
        filePart.write(uploadPath + File.separator + fileName);

        // Phản hồi
        response.getWriter().println("Upload thành công vào thư mục " + folder + "!<br>");
        response.getWriter().println("Tên file đã lưu: " + fileName + "<br>");
        response.getWriter().println("<a href=\"upload.jsp\">Quay lại</a>");
    }
}
