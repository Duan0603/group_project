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

@WebServlet(name = "ListeningServlet", urlPatterns = {"/listening"})
public class ListeningServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy songId từ request
        String songIdParam = request.getParameter("songId");

        // 2. Kiểm tra songId hợp lệ
        if (songIdParam != null && songIdParam.matches("\\d+")) {
            int songId = Integer.parseInt(songIdParam);

            // 3. Lấy user từ session
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");

            // 4. Nếu người dùng đã đăng nhập
            if (user != null) {
                ListeningHistoryDAO dao = new ListeningHistoryDAO();
                
                // 5. Lưu lịch sử nghe vào cơ sở dữ liệu
                dao.addHistory(user.getUserId(), songId);

                // 6. Lấy lại danh sách lịch sử nghe của người dùng
                List<ListeningHistory> listeningHistory = dao.getHistoryByUser(user.getUserId());

                // 7. Truyền danh sách lịch sử vào request
                request.setAttribute("listeningHistory", listeningHistory);

                // 8. Forward request đến sidebar.jsp để hiển thị lịch sử
                request.getRequestDispatcher("/WEB-INF/views/layouts/sidebar.jsp").forward(request, response);
                return;
            } else {
                // 9. Nếu người dùng chưa đăng nhập
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Bạn cần đăng nhập để lưu lịch sử nghe");
                return;
            }
        }

        // 10. Nếu songId không hợp lệ
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.getWriter().write("Song ID không hợp lệ");
    }
}
