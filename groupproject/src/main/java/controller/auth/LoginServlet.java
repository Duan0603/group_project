package controller.auth;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Base64;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private static final int REMEMBER_ME_EXPIRY = 30 * 24 * 60 * 60; // 30 ngày

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check cookie Remember Me
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            String rememberedUsernameOrEmail = null;
            String rememberedPassword = null;

            for (Cookie cookie : cookies) {
                if ("rememberedUsernameOrEmail".equals(cookie.getName())) {
                    rememberedUsernameOrEmail = decodeCookie(cookie.getValue());
                } else if ("rememberedPassword".equals(cookie.getName())) {
                    rememberedPassword = decodeCookie(cookie.getValue());
                }
            }

            if (rememberedUsernameOrEmail != null && rememberedPassword != null) {
                UserDAO userDAO = new UserDAO();
                User user = userDAO.login(rememberedUsernameOrEmail, rememberedPassword);
                if (user != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("user", user);
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
            }
        }

        // Nếu chưa login, hiển thị form login
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String usernameOrEmail = request.getParameter("username");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        UserDAO userDAO = new UserDAO();
        User user = userDAO.login(usernameOrEmail, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            if (rememberMe != null) {
                addRememberMeCookies(response, usernameOrEmail, password);
            }

            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        } 
    }

    // Hàm thêm cookies Remember Me
    private void addRememberMeCookies(HttpServletResponse response, String usernameOrEmail, String password) {
        Cookie usernameCookie = new Cookie("rememberedUsernameOrEmail", encodeCookie(usernameOrEmail));
        Cookie passwordCookie = new Cookie("rememberedPassword", encodeCookie(password));

        usernameCookie.setMaxAge(REMEMBER_ME_EXPIRY);
        passwordCookie.setMaxAge(REMEMBER_ME_EXPIRY);
        usernameCookie.setPath("/");
        passwordCookie.setPath("/");
        usernameCookie.setHttpOnly(true);
        passwordCookie.setHttpOnly(true);

        response.addCookie(usernameCookie);
        response.addCookie(passwordCookie);
    }

    // Encode cookie
    private String encodeCookie(String value) {
        return Base64.getEncoder().encodeToString(value.getBytes());
    }

    // Decode cookie
    private String decodeCookie(String value) {
        return new String(Base64.getDecoder().decode(value));
    }
}
