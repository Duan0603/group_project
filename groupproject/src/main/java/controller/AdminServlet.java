package controller;

import dao.SongDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.User;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {

    private UserDAO userDAO;
    private SongDAO songDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        songDAO = new SongDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // --- KIỂM TRA QUYỀN TRUY CẬP ---
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // --- LẤY DỮ LIỆU CHO DASHBOARD ---
        request.setAttribute("totalUsers", userDAO.countTotalUsers());
        request.setAttribute("totalSongs", songDAO.countTotalSongs());
        
        // Giả lập dữ liệu cho đơn hàng và doanh thu vì chưa có DAO
        request.setAttribute("totalOrders", 0);
        request.setAttribute("totalRevenue", 0.0);

        // --- LẤY DỮ LIỆU CHO CÁC TAB ---
        request.setAttribute("userList", userDAO.getAllUsers());
        request.setAttribute("songList", songDAO.getAllActiveSongs());

        // --- Chuyển hướng đến trang JSP ---
        // Đã cập nhật đường dẫn theo yêu cầu của bạn
        request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
    }
}
