package controller.auth;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;

@WebServlet(name = "PayOSReturnServlet", urlPatterns = {"/payos-return"})
public class PayOSReturnServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=login_required");
            return;
        }

        // Lấy trạng thái thanh toán từ PayOS (giả sử PayOS trả về tham số "status" và "orderCode")
        String status = request.getParameter("status");
        // Có thể kiểm tra thêm các tham số khác như orderCode, amount, checksum...

        if ("PAID".equalsIgnoreCase(status) || "SUCCESS".equalsIgnoreCase(status)) {
            // Cập nhật trạng thái premium cho user
            UserDAO userDAO = new UserDAO();
            userDAO.setPremium(user.getUserId(), true);
            user.setPremium(true);
            session.setAttribute("user", user);
            request.setAttribute("message", "Thanh toán thành công! Tài khoản của bạn đã được nâng cấp Premium.");
        } else {
            request.setAttribute("error", "Thanh toán thất bại hoặc bị hủy. Vui lòng thử lại.");
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/premium_result.jsp").forward(request, response);
    }
} 