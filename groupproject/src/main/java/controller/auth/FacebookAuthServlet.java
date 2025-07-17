package controller.auth;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONObject;

@WebServlet(name = "FacebookAuthServlet", urlPatterns = {"/facebook-auth"})
public class FacebookAuthServlet extends HttpServlet {

    private static final String APP_ID = "724548546615720";
    private static final String APP_SECRET = "4b5aa1d1a38eb3c853dd6372cfabb29a";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String code = request.getParameter("code");

        if (code == null) {
            String fbLoginUrl = "https://www.facebook.com/v20.0/dialog/oauth"
                    + "?client_id=" + APP_ID
                    + "&redirect_uri=" + URLEncoder.encode(buildRedirectUri(request), "UTF-8")
                    + "&scope=email,public_profile";
            response.sendRedirect(fbLoginUrl);
            return;
        }

        try {
            String tokenUrl = "https://graph.facebook.com/v20.0/oauth/access_token"
                    + "?client_id=" + APP_ID
                    + "&redirect_uri=" + URLEncoder.encode(buildRedirectUri(request), "UTF-8")
                    + "&client_secret=" + APP_SECRET
                    + "&code=" + URLEncoder.encode(code, "UTF-8");

            JSONObject tokenJson = getJson(tokenUrl);
            String accessToken = tokenJson.getString("access_token");

            String infoUrl = "https://graph.facebook.com/me?fields=id,name,email&access_token=" + accessToken;
            JSONObject userJson = getJson(infoUrl);

            String facebookId = userJson.getString("id");
            String name = userJson.optString("name", "Facebook User");
            String email = userJson.has("email") ? userJson.getString("email") : facebookId + "@facebook.com";

            UserDAO userDAO = new UserDAO();
            User user = userDAO.findByEmail(email);

            if (user != null && !"facebook".equals(user.getProvider())) {
                request.setAttribute("error", "Email này đã liên kết với một hình thức đăng nhập khác.");
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
                return;
            }

            if (user == null) {
                user = new User();
                user.setUsername(
                        name.trim()
                                .replaceAll("\\s+", " ")
                );
                user.setPassword("");
                user.setEmail(email);
                user.setRole("USER");
                user.setStatus(true);
                user.setProvider("facebook");
                user.setFacebookID(facebookId);

                boolean registered = userDAO.register(user);
                if (!registered) {
                    response.sendRedirect(request.getContextPath() + "/login?error=registration_failed");
                    return;
                }

                user = userDAO.findByEmail(email);
            }

            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            response.sendRedirect(request.getContextPath() + "/home");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login?error=facebook_login_failed");
        }
    }

    private JSONObject getJson(String urlStr) throws IOException {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
            String input;
            StringBuilder content = new StringBuilder();
            while ((input = in.readLine()) != null) {
                content.append(input);
            }
            return new JSONObject(content.toString());
        }
    }

    private String buildRedirectUri(HttpServletRequest request) {
        StringBuilder uri = new StringBuilder();
        uri.append(request.getScheme()).append("://").append(request.getServerName());
        if ((request.getScheme().equals("http") && request.getServerPort() != 80)
                || (request.getScheme().equals("https") && request.getServerPort() != 443)) {
            uri.append(":").append(request.getServerPort());
        }
        uri.append(request.getContextPath()).append("/facebook-auth");
        return uri.toString();
    }
}
