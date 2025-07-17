package controller;

import dao.ListeningHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.ListeningHistory;

import java.io.IOException;
import java.util.List;

@WebServlet("/history")
public class ListeningHistoryServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user != null) {
            ListeningHistoryDAO historyDAO = new ListeningHistoryDAO();
            List<ListeningHistory> listeningHistory = historyDAO.getHistoryByUser(user.getUserId());

            // Truyền lịch sử vào request
            request.setAttribute("listeningHistory", listeningHistory);

            // Forward đến sidebar.jsp để hiển thị lịch sử
            request.getRequestDispatcher("/WEB-INF/views/layouts/sidebar.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
}
