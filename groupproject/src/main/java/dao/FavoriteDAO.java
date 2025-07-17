package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import model.Songs;

public class FavoriteDAO {

    private Connection conn;

    public FavoriteDAO() {
        try {
            DBContext db = new DBContext();
            this.conn = db.getConnection();
            if (conn == null) {
                throw new SQLException("Không thể kết nối đến cơ sở dữ liệu");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi khởi tạo kết nối cơ sở dữ liệu: " + e.getMessage());
        }
    }

    private void checkConnection() throws SQLException {
        if (conn == null) {
            throw new SQLException("Không thể kết nối đến cơ sở dữ liệu");
        }
    }

    public boolean addFavorite(int userId, int songId) {
    String sql = "INSERT INTO Likes (userId, songId, likedAt) VALUES (?, ?, GETDATE())";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, songId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        // Tránh lỗi trùng khoá chính
        System.out.println("User already liked this song");
        return false;
    }
}

public boolean removeFavorite(int userId, int songId) {
    String sql = "DELETE FROM Likes WHERE userId = ? AND songId = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, songId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

   public List<Songs> getFavoriteSongs(int userId) throws SQLException {
    checkConnection();
    List<Songs> songs = new ArrayList<>();
    String sql = "SELECT s.SongID, s.Title, s.Artist, s.Album, s.Genre, s.Duration, s.ReleaseDate, s.FilePath, s.CoverImage " +
                 "FROM Songs s JOIN UserFavorites uf ON s.SongID = uf.SongID WHERE uf.UserID = ? AND s.Status = 1";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Songs song = new Songs();
            song.setSongID(rs.getInt("SongID"));
            song.setTitle(rs.getString("Title"));
            song.setArtist(rs.getString("Artist"));
            song.setAlbum(rs.getString("Album"));
            song.setGenre(rs.getString("Genre"));
            song.setDuration(rs.getInt("Duration"));
            song.setReleaseDate(rs.getDate("ReleaseDate"));
            song.setFilePath(rs.getString("FilePath"));
            song.setCoverImage(rs.getString("CoverImage"));
            songs.add(song);
        }
    } catch (SQLException e) {
        throw new SQLException("Lỗi khi lấy danh sách bài hát yêu thích: " + e.getMessage());
    }
    return songs;
}

public Set<Integer> getFavoriteSongIdsByUser(int userId) {
    Set<Integer> favoriteSongIds = new LinkedHashSet<>();
    String sql = "SELECT songId FROM Likes WHERE userId = ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            favoriteSongIds.add(rs.getInt("songId"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return favoriteSongIds;
}

    public int getFavoriteCountByUser(int userId) throws SQLException {
        checkConnection();
        String sql = "SELECT COUNT(*) FROM UserFavorites WHERE UserID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new SQLException("Lỗi khi đếm số lượng bài hát yêu thích: " + e.getMessage());
        }
        return 0;
    }
}