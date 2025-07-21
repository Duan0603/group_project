package dao;

import model.Songs;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
    String sql = "INSERT INTO ListeningHistory (UserID, SongID, ListenedAt) VALUES (?, ?, GETDATE())";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, songId);
        ps.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
    }
}

    // Lấy tất cả lịch sử nghe nhạc theo user
    public List<Songs> getListeningHistoryByUserId(int userId) {
        List<Songs> list = new ArrayList<>();
        String sql = "SELECT s.* FROM Songs s " +
                     "JOIN ListeningHistory h ON s.SongID = h.SongID " +
                     "WHERE h.UserID = ? ORDER BY h.ListenedAt DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Songs song = new Songs();
                song.setSongID(rs.getInt("SongID"));
                song.setTitle(rs.getString("Title"));
                song.setArtist(rs.getString("Artist"));
                song.setCoverImage(rs.getString("CoverImage"));
                song.setFilePath(rs.getString("AudioPath"));
                list.add(song);
            }
        } catch (Exception e) {
            System.err.println("❌ Error getting history: " + e.getMessage());
        }

        return list;
    }

    // Lấy tối đa N bài lịch sử gần nhất
public List<Songs> getRecentHistory(int userId, int limit) {
    List<Songs> list = new ArrayList<>();
    String sql = "SELECT TOP (?) s.* FROM Songs s " +
                 "JOIN ListeningHistory h ON s.SongID = h.SongID " +
                 "WHERE h.UserID = ? ORDER BY h.ListenedAt DESC";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, limit);
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Songs song = new Songs();
            song.setSongID(rs.getInt("SongID"));
            song.setTitle(rs.getString("Title"));
            song.setArtist(rs.getString("Artist"));
            song.setCoverImage(rs.getString("CoverImage"));
            song.setFilePath(rs.getString("AudioPath"));
            list.add(song);
        }
    } catch (Exception e) {
        System.err.println("❌ Error getting recent history: " + e.getMessage());
    }

    return list;
}

    // Xóa toàn bộ lịch sử nghe nhạc
    public boolean clearListeningHistory(int userId) {
        String sql = "DELETE FROM ListeningHistory WHERE UserID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error clearing history: " + e.getMessage());
            return false;
        }
    }
}
