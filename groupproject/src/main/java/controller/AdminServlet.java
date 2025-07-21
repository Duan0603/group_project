package controller;

import dao.OrderDAO;
import dao.SongDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {

    private UserDAO userDAO;
    private SongDAO songDAO;
    private OrderDAO orderDAO; // Thêm OrderDAO

    @Override
    public void init() throws ServletException {
        // Khởi tạo tất cả các DAO cần thiết một lần duy nhất
        userDAO = new UserDAO();
        songDAO = new SongDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Kiểm tra quyền truy cập, chỉ cho phép ADMIN vào trang này
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy dữ liệu cho các thẻ thống kê trên Dashboard
        request.setAttribute("totalUsers", userDAO.countTotalUsers());
        request.setAttribute("totalSongs", songDAO.countTotalSongs());
        request.setAttribute("totalOrders", orderDAO.countTotalOrders());
        request.setAttribute("totalRevenue", orderDAO.calculateTotalRevenue());
        
        
        // LẤY DỮ LIỆU CHO BIỂU ĐỒ
        String monthlyRevenueData = orderDAO.getMonthlyRevenueForChart();
        request.setAttribute("monthlyRevenueData", monthlyRevenueData);

        // Lấy danh sách chi tiết cho các bảng quản lý
        request.setAttribute("userList", userDAO.getAllUsers());
        request.setAttribute("songList", songDAO.getAllActiveSongs());
        request.setAttribute("orderList", orderDAO.getAllOrders());

        // Chuyển tiếp tất cả dữ liệu đến trang JSP để hiển thị
        request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
    }
}
