package controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

@WebServlet(name = "PayOSPaymentServlet", urlPatterns = {"/payos-premium"})
public class PayOSPaymentServlet extends HttpServlet {
    private static final String CLIENT_ID = "68a4f6f8-8542-4156-8f82-3591de822349";
    private static final String API_KEY = "bdef7c04-8333-40cf-a6b1-d4159d7f04c2";
    private static final String CHECKSUM_KEY = "5e5262b736e7c08161fe2e122aa3e97877ec4d4a02713edac8e43cf0e88d705d";
    private static final String PAYOS_ENDPOINT = "https://api.payos.vn/v2/payment-requests";
    private static final String RETURN_URL = "https://my.payos.vn/d2325fce630711f094d10242ac110002/create-payment-link";
    private static final String PREMIUM_DESCRIPTION = "Nâng cấp tài khoản Premium";
    private static final int PREMIUM_PRICE = 50000; // Giá premium (VND)

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=login_required");
            return;
        }

        // Tạo orderId duy nhất cho mỗi giao dịch
        String orderId = UUID.randomUUID().toString();
        String orderInfo = PREMIUM_DESCRIPTION + " cho user " + user.getUsername();

        // Tạo JSON body cho PayOS
        String jsonBody = "{" +
                "\"orderCode\": \"" + orderId + "\"," +
                "\"amount\": " + PREMIUM_PRICE + "," +
                "\"description\": \"" + orderInfo + "\"," +
                "\"returnUrl\": \"" + RETURN_URL + "\"," +
                "\"cancelUrl\": \"" + RETURN_URL + "\"}";

        // Gửi request tạo payment link tới PayOS
        URL url = new URL(PAYOS_ENDPOINT);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("x-client-id", CLIENT_ID);
        conn.setRequestProperty("x-api-key", API_KEY);
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonBody.getBytes(StandardCharsets.UTF_8);
            os.write(input, 0, input.length);
        }

        int status = conn.getResponseCode();
        if (status == 200 || status == 201) {
            // Đọc response để lấy paymentUrl
            java.util.Scanner s = new java.util.Scanner(conn.getInputStream()).useDelimiter("\\A");
            String result = s.hasNext() ? s.next() : "";
            s.close();
            // Trích xuất paymentUrl từ JSON (đơn giản, không dùng thư viện JSON)
            String paymentUrl = null;
            int idx = result.indexOf("paymentUrl");
            if (idx != -1) {
                int start = result.indexOf('"', idx + 12) + 1;
                int end = result.indexOf('"', start);
                paymentUrl = result.substring(start, end);
            }
            if (paymentUrl != null) {
                response.sendRedirect(paymentUrl);
                return;
            }
        } else {
            java.util.Scanner s = new java.util.Scanner(conn.getErrorStream()).useDelimiter("\\A");
            String errorResult = s.hasNext() ? s.next() : "";
            s.close();
            System.out.println("PayOS error: " + errorResult);
        }
        // Nếu lỗi, chuyển về trang lỗi
        response.sendRedirect(request.getContextPath() + "/home?error=payos_failed");
    }
} 