package dao;

import model.ListeningHistory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

public class ListeningHistoryDAO {
    private final Connection conn;
    
    public ListeningHistoryDAO() {
        DBContext dbContext = new DBContext();
        conn = dbContext.getConnection();
        if (conn == null) {
            System.err.println("❌ Failed to establish database connection");
        } else {
            System.out.println("✅ Database connection established");
        }
    }

     public void addHistory(int userId, int songId) {
        String sql = "INSERT INTO ListeningHistory (UserID, SongID, ListenedAt) VALUES (?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, songId);
            ps.setTimestamp(3, new Timestamp(System.currentTimeMillis())); // Add current timestamp
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("❌ Error inserting listening history: " + e.getMessage());
        }
    }

public List<ListeningHistory> getHistoryByUser(int userId) {
        List<ListeningHistory> historyList = new ArrayList<>();

        String sql = "SELECT * FROM ListeningHistory WHERE UserID = ? ORDER BY ListenedAt DESC";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                ListeningHistory history = new ListeningHistory();
                history.setHistoryID(rs.getInt("HistoryID"));
                history.setSongID(rs.getInt("SongID"));
                history.setUserID(rs.getInt("UserID"));
                history.setListenedAt(rs.getTimestamp("ListenedAt"));

                historyList.add(history);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return historyList;
    }

public static void main(String[] args) {
        try {
            // Khởi tạo DAO
            ListeningHistoryDAO dao = new ListeningHistoryDAO();

            // Kiểm tra kết nối cơ sở dữ liệu
            if (dao.conn == null) {
                System.err.println("❌ Database connection is null. Exiting...");
                return;
            }

            // Thêm một bản ghi lịch sử nghe (sử dụng userId và songId hợp lệ)
            int testUserId = 1; // Thay bằng userId hợp lệ trong bảng Users
            int testSongId = 1; // Thay bằng songId hợp lệ trong bảng Songs
            System.out.println("Testing addHistory with userId=" + testUserId + ", songId=" + testSongId);
            dao.addHistory(testUserId, testSongId);

            // Lấy và hiển thị lịch sử nghe
            System.out.println("\nTesting getHistoryByUser with userId=" + testUserId);
            List<ListeningHistory> historyList = dao.getHistoryByUser(testUserId);
            if (historyList.isEmpty()) {
                System.out.println("No history found for userId=" + testUserId);
            } else {
                for (ListeningHistory history : historyList) {
                    System.out.println("History Record: " +
                            "historyID=" + history.getHistoryID() +
                            ", userID=" + history.getUserID() +
                            ", songID=" + history.getSongID() +
                            ", timestamp=" + history.getListenedAt());
                }
            }

            // Đóng kết nối (tùy chọn, nếu DBContext không tự quản lý)
            try {
                dao.conn.close();
                System.out.println("✅ Database connection closed");
            } catch (SQLException e) {
                System.err.println("❌ Error closing connection: " + e.getMessage());
            }
        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
