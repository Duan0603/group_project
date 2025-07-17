package controller;

import dao.OrderDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "UserManagementServlet", urlPatterns = {"/admin/users"})
public class UserManagementServlet extends HttpServlet {

    private UserDAO userDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        try {
            switch (action) {
                case "update":
                    updateUser(request, response);
                    break;
                case "toggleStatus":
                    toggleUserStatus(request, response);
                    break;
                case "delete":
                    deleteUser(request, response);
                    break;
                case "togglePremium":
                    togglePremiumStatus(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String role = request.getParameter("role");

        User user = new User();
        user.setUserId(userId);
        user.setUsername(username);
        user.setEmail(email);
        user.setRole(role);

        userDAO.updateUser(user);
        response.sendRedirect(request.getContextPath() + "/admin#accounts");
    }

    private void toggleUserStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        boolean currentStatus = Boolean.parseBoolean(request.getParameter("currentStatus"));
        
        userDAO.updateUserStatus(userId, !currentStatus);
        response.sendRedirect(request.getContextPath() + "/admin#accounts");
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        userDAO.deleteUser(userId);
        response.sendRedirect(request.getContextPath() + "/admin#accounts");
    }
    
    private void togglePremiumStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        boolean currentPremiumStatus = Boolean.parseBoolean(request.getParameter("currentPremiumStatus"));
        
        boolean success = userDAO.togglePremiumStatus(userId, currentPremiumStatus);
        
        if (success && !currentPremiumStatus) {
            orderDAO.createOrder(userId, 20000, "Nâng cấp tài khoản Premium");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin#accounts");
    }
}
