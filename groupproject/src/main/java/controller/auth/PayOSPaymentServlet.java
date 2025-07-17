package controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;
import vn.payos.PayOS;
import vn.payos.type.CheckoutResponseData;
import vn.payos.type.PaymentData;
import vn.payos.type.ItemData;

@WebServlet(name = "PayOSPaymentServlet", urlPatterns = {"/payos-premium"})
public class PayOSPaymentServlet extends HttpServlet {
    // TỐT NHẤT: Nên đưa các giá trị này vào file cấu hình hoặc biến môi trường
    private static final String CLIENT_ID = "68a4f6f8-8542-4156-8f82-3591de822349";
    private static final String API_KEY = "bdef7c04-8333-40cf-a6b1-d4159d7f04c2";
    private static final String CHECKSUM_KEY = "5e5262b736e7c08161fe2e122aa3e97877ec4d4a02713edac8e43cf0e88d705d";
    private static final int PREMIUM_PRICE = 20000; // Giá premium (VND)

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=login_required");
            return;
        }

        try {
            // Khởi tạo PayOS SDK
            PayOS payOS = new PayOS(CLIENT_ID, API_KEY, CHECKSUM_KEY);

            // orderCode phải là số duy nhất (long).
            // Tạm thời vẫn dùng currentTimeMillis, nhưng nên có giải pháp tốt hơn.
            long orderCode = System.currentTimeMillis();

            // IMPORTANT: Xây dựng URL trả về động dựa trên request hiện tại.
            // Bạn cần tạo các Servlet/endpoint để xử lý các URL này.
            String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
            String returnUrl = baseUrl + "/payos-return"; // Endpoint xử lý khi thành công
            String cancelUrl = baseUrl + "/payos-return"; // Khi hủy đơn hàng, chuyển về trang chủ

            // Tạo item cho đơn hàng
            ItemData item = ItemData.builder()
                .name("Nâng cấp Premium cho " + user.getUsername())
                .quantity(1)
                .price(PREMIUM_PRICE)
                .build();

            // Tạo PaymentData
            PaymentData paymentData = PaymentData.builder()
                .orderCode(orderCode)
                .amount(PREMIUM_PRICE)
                .description("Prenium for: " + user.getUserId()) // Mô tả không dấu để tránh lỗi encoding
                .returnUrl(returnUrl)
                .cancelUrl(cancelUrl)
                .item(item)
                .buyerName(user.getUsername()) // Thêm thông tin người mua (tùy chọn nhưng nên có)
                .buyerEmail(user.getEmail()) // Thêm thông tin người mua (tùy chọn nhưng nên có)
                .build();

            // Tạo link thanh toán
            CheckoutResponseData result = payOS.createPaymentLink(paymentData);
            String paymentUrl = result.getCheckoutUrl();

            // Chuyển hướng người dùng đến cổng thanh toán PayOS
            response.sendRedirect(paymentUrl);

        } catch (Exception e) {
            // In lỗi ra console để debug
            System.err.println("Lỗi khi tạo link thanh toán PayOS: " + e.getMessage());
            e.printStackTrace();
            // Chuyển hướng về trang chủ với thông báo lỗi
            response.sendRedirect(request.getContextPath() + "/home?error=payos_failed");
        }
    }
}