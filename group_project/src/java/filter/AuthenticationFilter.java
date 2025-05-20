package filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/admin/*", "/playlist/*", "/profile/*"})
public class AuthenticationFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession();
        
        String loginURI = req.getContextPath() + "/login";
        boolean isLoginRequest = req.getRequestURI().equals(loginURI);
        boolean isLoginPage = req.getRequestURI().endsWith("login.jsp");
        boolean isResourceRequest = req.getRequestURI().startsWith(req.getContextPath() + "/resources/");
        
        User user = (User) session.getAttribute("user");
        
        if (isLoginRequest || isLoginPage || isResourceRequest) {
            chain.doFilter(request, response);
            return;
        }
        
        // Check if user is logged in
        if (user == null) {
            res.sendRedirect(loginURI);
            return;
        }
        
        // Check role-based access
        String requestURI = req.getRequestURI();
        if (requestURI.startsWith(req.getContextPath() + "/admin/")) {
            if (!user.getRole().equals("ADMIN")) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
} 