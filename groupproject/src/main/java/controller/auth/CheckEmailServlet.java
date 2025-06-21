package controller.auth;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "CheckEmailServlet", urlPatterns = {"/check-email"})
public class CheckEmailServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        boolean exists = false;

        User user = userDAO.findByEmail(email);
        if (user != null && "local".equalsIgnoreCase(user.getProvider())) {
            exists = true;
        }

        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
    }
}
