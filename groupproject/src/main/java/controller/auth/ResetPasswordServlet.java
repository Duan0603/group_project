package controller.auth;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.isEmpty()) {
            request.setAttribute("message", "Link không hợp lệ!");
            request.getRequestDispatcher("/WEB-INF/views/auth/reset_password.jsp").forward(request, response);
            return;
        }
        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByResetToken(token);
        if (user == null) {
            request.setAttribute("message", "Link không hợp lệ hoặc đã hết hạn!");
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/reset_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        if (token == null || token.isEmpty()) {
            request.setAttribute("message", "Link không hợp lệ!");
            request.getRequestDispatcher("/WEB-INF/views/auth/reset_password.jsp").forward(request, response);
            return;
        }
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("message", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/WEB-INF/views/auth/reset_password.jsp").forward(request, response);
            return;
        }
        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByResetToken(token);
        if (user == null) {
            request.setAttribute("message", "Link không hợp lệ hoặc đã hết hạn!");
            request.getRequestDispatcher("/WEB-INF/views/auth/reset_password.jsp").forward(request, response);
            return;
        }
        userDAO.updatePasswordByEmail(user.getEmail(), password);
        userDAO.clearResetToken(user.getEmail());
        request.setAttribute("message", "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập.");
        request.getRequestDispatcher("/WEB-INF/views/auth/reset_password.jsp").forward(request, response);
    }
} 