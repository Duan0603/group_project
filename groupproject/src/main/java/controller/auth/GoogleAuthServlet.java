package controller.auth;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import utils.MailUtil;
import utils.OtpManager;

@WebServlet(name = "GoogleAuthServlet", urlPatterns = {"/login-google"})
public class GoogleAuthServlet extends HttpServlet {

    private static final String CLIENT_ID = "434084397596-ke38cl1ediqsmlunleio6srv1ape03kr.apps.googleusercontent.com";
    private static final String CLIENT_SECRET = "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";
    private static final String SCOPE = "email profile openid";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");
        System.out.println("👉 [GoogleAuthServlet] code = " + code);

        if (code == null) {
            String redirectUri = buildRedirectUri(request);
            String googleLoginUrl = "https://accounts.google.com/o/oauth2/v2/auth"
                    + "?client_id=" + CLIENT_ID
                    + "&response_type=code"
                    + "&scope=" + URLEncoder.encode(SCOPE, "UTF-8")
                    + "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8")
                    + "&access_type=offline"
                    + "&prompt=consent";
            response.sendRedirect(googleLoginUrl);
        } else {
            try {
                String redirectUri = buildRedirectUri(request);
                String tokenUrl = "https://oauth2.googleapis.com/token";
                String postParams = "code=" + URLEncoder.encode(code, "UTF-8")
                        + "&client_id=" + URLEncoder.encode(CLIENT_ID, "UTF-8")
                        + "&client_secret=" + URLEncoder.encode(CLIENT_SECRET, "UTF-8")
                        + "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8")
                        + "&grant_type=authorization_code";

                URL url = new URL(tokenUrl);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setDoOutput(true);
                conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

                try (OutputStream os = conn.getOutputStream()) {
                    os.write(postParams.getBytes());
                    os.flush();
                }

                int responseCode = conn.getResponseCode();
                System.out.println("👉 Token exchange response code: " + responseCode);
                if (responseCode != 200) {
                    throw new IOException("Failed to get token: HTTP error code " + responseCode);
                }

                StringBuilder responseBuilder = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        responseBuilder.append(line);
                    }
                }
                conn.disconnect();

                JsonObject jsonResponse = JsonParser.parseString(responseBuilder.toString()).getAsJsonObject();
                String accessToken = jsonResponse.get("access_token").getAsString();
                System.out.println(" Access token = " + accessToken);

                // Lấy user info
                String userInfoUrl = "https://www.googleapis.com/oauth2/v3/userinfo?access_token=" + accessToken;
                URL userInfoConnUrl = new URL(userInfoUrl);
                HttpURLConnection userInfoConn = (HttpURLConnection) userInfoConnUrl.openConnection();
                userInfoConn.setRequestMethod("GET");

                int userInfoResponseCode = userInfoConn.getResponseCode();
                System.out.println("👉 User info response code: " + userInfoResponseCode);
                if (userInfoResponseCode != 200) {
                    throw new IOException("Failed to get user info: HTTP error code " + userInfoResponseCode);
                }

                StringBuilder userInfoResponseBuilder = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(userInfoConn.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        userInfoResponseBuilder.append(line);
                    }
                }
                userInfoConn.disconnect();

                JsonObject userInfo = JsonParser.parseString(userInfoResponseBuilder.toString()).getAsJsonObject();
                String email = userInfo.has("email") ? userInfo.get("email").getAsString() : null;
                String sub = userInfo.has("sub") ? userInfo.get("sub").getAsString() : null;
                String name = userInfo.has("name") ? userInfo.get("name").getAsString() : "Người dùng Google";

                System.out.println("👉 Email: " + email + ", Name: " + name + ", Sub: " + sub);

                if (email == null) {
                    response.sendRedirect(request.getContextPath() + "/login?error=email_not_found");
                    return;
                }

                UserDAO userDAO = new UserDAO();
                User user = userDAO.findByEmail(email);
                System.out.println("User found? " + (user != null));

                if (user != null) {
                    // Nếu đã có user, cập nhật lại provider nếu cần
                    if (!"google".equalsIgnoreCase(user.getProvider())) {
                        userDAO.updateProvider(email, "google");
                        user.setProvider("google");
                        System.out.println(" Provider updated to google");
                    }
                } else {
                    // Nếu chưa có thì tạo mới user Google
                    user = new User();
                    user.setUsername(name.trim().replaceAll("\\s+", " "));
                    user.setPassword("");
                    user.setEmail(email);
                    user.setRole("USER");
                    user.setStatus(true);
                    user.setProvider("google");
                    user.setGoogleID(sub);

                    boolean registered = userDAO.register(user);
                    System.out.println("� New user registered? " + registered);
                    if (!registered) {
                        response.sendRedirect(request.getContextPath() + "/login?error=registration_failed");
                        return;
                    }

                    user = userDAO.findByEmail(email);
                }

                // Gửi OTP
                try {
                    String otp = OtpManager.generate(email);
                    MailUtil.sendOtp(email, user.getUsername(), otp);
                    System.out.println(" OTP sent to " + email);
                } catch (Exception ex) {
                    System.out.println(" Failed to send OTP: " + ex.getMessage());
                    ex.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/login?error=otp_failed");
                    return;
                }

                // Set session và chuyển trang
                HttpSession session = request.getSession();
                session.setAttribute("pendingUser", user);
                session.setAttribute("pendingEmail", email);

                System.out.println("✅ Redirecting to /verify-otp");
                response.sendRedirect(request.getContextPath() + "/verify-otp");

            } catch (Exception e) {
                System.out.println(" Exception in GoogleAuthServlet: " + e.getMessage());
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/login?error=google_login_failed");
            }
        }
    }

    private String buildRedirectUri(HttpServletRequest request) {
        StringBuilder redirectUri = new StringBuilder();
        redirectUri.append(request.getScheme())
                .append("://")
                .append(request.getServerName());

        if ((request.getScheme().equals("http") && request.getServerPort() != 80)
                || (request.getScheme().equals("https") && request.getServerPort() != 443)) {
            redirectUri.append(":").append(request.getServerPort());
        }

        redirectUri.append(request.getContextPath()).append("/login-google");
        return redirectUri.toString();
    }
}
