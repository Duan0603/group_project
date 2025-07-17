package controller.auth;

import dao.UserDAO;
import model.User;
import utils.EmailUtility;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot_password.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        UserDAO dao = new UserDAO();
        User user = dao.findByEmail(email);

        if (user == null) {
            req.setAttribute("message", "Email không tồn tại trong hệ thống!");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot_password.jsp").forward(req, res);
            return;
        }

        // 1. tạo token + hết hạn 15 phút
        String token = UUID.randomUUID().toString();
        String expiry = LocalDateTime.now().plusMinutes(15)
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        dao.updateResetToken(email, token, expiry);

        // 2. link reset
        String resetLink = req.getRequestURL().toString()
                .replace("forgot-password", "reset-password") + "?token=" + token;

        // 3. soạn email
        String subject = "Khôi phục mật khẩu - Pinkify";

        String htmlContent = "<div style='background-color:#f9f9f9; padding: 30px 0;'>"
        + "<div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ddd; "
        + "border-radius:8px; padding:40px; font-family:Arial,sans-serif; color:#333;'>"
        + "<h2 style='color:#e84393; margin-top:0;'>Khôi phục mật khẩu</h2>"
        + "<p style='font-size: 15px;'>Xin chào, <strong>" + user.getUsername()+ "</strong></p>"
        + "<p>Bạn vừa yêu cầu đặt lại mật khẩu cho tài khoản Pinkify.</p>"
        + "<a href='" + resetLink + "' "
        + "style='display:inline-block; padding:12px 24px; background-color:#000; color:#fff; "
        + "text-decoration:none; font-weight:bold; border-radius:6px; margin: 20px 0;'>"
        + "Đặt lại mật khẩu</a>"
        + "<hr style='border:none; border-top:1px solid #eee; margin:30px 0;'>"
        + "<p style='font-size:13px; color:#666;'>Liên kết này sẽ hết hạn sau 15 phút.</p>"
        + "<p style='font-size:13px; color:#666;'>Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này.</p>"
        + "</div></div>";

        boolean ok = EmailUtility.sendEmail(email, subject, htmlContent);

        req.setAttribute("message",
                ok ? "Đã gửi email đặt lại mật khẩu – vui lòng kiểm tra hộp thư!"
                        : "Không thể gửi email, vui lòng thử lại sau.");
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot_password.jsp").forward(req, res);
    }
}
