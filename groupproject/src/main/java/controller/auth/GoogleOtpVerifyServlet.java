/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import utils.OtpManager;
import model.User;

@WebServlet(name = "GoogleOtpVerifyServlet", urlPatterns = {"/verify-otp"})
public class GoogleOtpVerifyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/verify_otp.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession ss = req.getSession(false);
        if (ss == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String input = req.getParameter("otp");
        String email = (String) ss.getAttribute("pendingEmail");

        if (OtpManager.verify(email, input)) {
            User user = (User) ss.getAttribute("pendingUser");
            ss.removeAttribute("pendingEmail");
            ss.removeAttribute("pendingUser");
            ss.setAttribute("user", user);                    // login chính thức
            res.sendRedirect(req.getContextPath() + "/home");
        } else {
            req.setAttribute("error", "Mã OTP sai hoặc đã hết hạn!");
            req.getRequestDispatcher("/WEB-INF/views/auth/verify_otp.jsp").forward(req, res);
        }
    }
}
