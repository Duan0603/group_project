package dao;

import model.Playlist;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PlaylistDAO {
    private final Connection conn;

    public PlaylistDAO() {
        DBContext dbContext = new DBContext();
        conn = dbContext.getConnection();
    }

    // Thêm playlist mới
    public boolean addPlaylist(Playlist playlist) {
    String sql = "INSERT INTO Playlists (UserID, Name, Description, CreatedDate, IsPublic, Status) VALUES (?, ?, ?, ?, ?, ?)";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlist.getUserID());
        stmt.setString(2, playlist.getName());
        stmt.setString(3, playlist.getDescription());
        stmt.setTimestamp(4, new Timestamp(playlist.getCreatedDate().getTime()));
        stmt.setBoolean(5, playlist.isIsPublic());
        stmt.setBoolean(6, playlist.isStatus());
        int rowsAffected = stmt.executeUpdate();
        return rowsAffected > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

    // Lấy playlist theo UserID
public List<Playlist> getPlaylistsByUser(int userID) {
    List<Playlist> playlists = new ArrayList<>();
    String sql = "SELECT * FROM Playlists WHERE UserID = ? AND Status = 1";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, userID);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Playlist playlist = new Playlist(
                rs.getInt("PlaylistID"),
                rs.getInt("UserID"),
                0, // Không có songID trong bảng này
                rs.getString("Name"),
                rs.getString("Description"),
                rs.getTimestamp("CreatedDate"),
                rs.getBoolean("IsPublic"),
                rs.getBoolean("Status")
            );
            playlists.add(playlist);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return playlists;
}

    // Lấy playlist theo PlaylistID
    public Playlist getPlaylistById(int playlistID) {
    Playlist playlist = null;
    String sql = "SELECT * FROM Playlists WHERE PlaylistID = ? AND Status = 1";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlistID);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            playlist = new Playlist(
                rs.getInt("PlaylistID"),
                rs.getInt("UserID"),
                0, // Không chứa songID
                rs.getString("Name"),
                rs.getString("Description"),
                rs.getTimestamp("CreatedDate"),
                rs.getBoolean("IsPublic"),
                rs.getBoolean("Status")
            );
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return playlist;
}

    // Cập nhật playlist
    public boolean updatePlaylist(Playlist playlist) {
    String sql = "UPDATE Playlists SET Name = ?, Description = ?, IsPublic = ?, Status = ? WHERE PlaylistID = ?";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, playlist.getName());
        stmt.setString(2, playlist.getDescription());
        stmt.setBoolean(3, playlist.isIsPublic());
        stmt.setBoolean(4, playlist.isStatus());
        stmt.setInt(5, playlist.getPlaylistID());
        return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

    // Xóa playlist
    public boolean deletePlaylist(int playlistID) {
        String sql = "UPDATE Playlists SET Status = 0 WHERE PlaylistID = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistID);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Thêm bài hát vào playlist
    public boolean addSongToPlaylist(int playlistID, int songID) {
        String sql = "INSERT INTO PlaylistSongs (PlaylistID, SongID) VALUES (?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistID);
            stmt.setInt(2, songID);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Lấy bài hát trong playlist
    public List<Integer> getSongsInPlaylist(int playlistID) {
        List<Integer> songIDs = new ArrayList<>();
        String sql = "SELECT SongID FROM PlaylistSongs WHERE PlaylistID = ?";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistID);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                songIDs.add(rs.getInt("SongID"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return songIDs;
    }
    
    //check bai hat xem ton tai hay ch
    public boolean isSongInPlaylist(int playlistID, int songID) {
    String sql = "SELECT 1 FROM PlaylistSongs WHERE PlaylistID = ? AND SongID = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlistID);
        stmt.setInt(2, songID);
        ResultSet rs = stmt.executeQuery();
        return rs.next(); // tồn tại
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
}
