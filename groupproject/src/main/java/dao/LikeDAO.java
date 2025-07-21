package dao;

import model.Like;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Songs;

public class LikeDAO {
    public boolean isLiked(int userId, int songId) {
        String sql = "SELECT 1 FROM Likes WHERE userId = ? AND songId = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, songId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addLike(int userId, int songId) {
        String sql = "INSERT INTO Likes (userId, songId, likedAt) VALUES (?, ?, ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, songId);
            ps.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeLike(int userId, int songId) {
        String sql = "DELETE FROM Likes WHERE userId = ? AND songId = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, songId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Songs> getLikedSongsByUserId(int userId) {
        List<Songs> likedSongs = new ArrayList<>();
        String sql = "SELECT s.songID, s.title, s.artist, s.album, s.genre, s.duration, s.releaseDate, s.filePath, s.coverImage, s.status " +
                "FROM Likes l JOIN Songs s ON l.songId = s.songID WHERE l.userId = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Songs song = new Songs(
                        rs.getInt("songID"),
                        rs.getString("title"),
                        rs.getString("artist"),
                        rs.getString("album"),
                        rs.getString("genre"),
                        rs.getInt("duration"),
                        rs.getDate("releaseDate"),
                        rs.getString("filePath"),
                        rs.getString("coverImage"),
                        rs.getBoolean("status")
                    );
                    likedSongs.add(song);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return likedSongs;
    }
} 