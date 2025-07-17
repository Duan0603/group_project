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
    // Kiểm tra xem playlist với tên này đã tồn tại chưa
    String checkExistSql = "SELECT COUNT(*) FROM Playlists WHERE Name = ? AND UserID = ? AND Status = 1";
    try (PreparedStatement checkStmt = conn.prepareStatement(checkExistSql)) {
        checkStmt.setString(1, playlist.getName());
        checkStmt.setInt(2, playlist.getUserID());
        ResultSet rs = checkStmt.executeQuery();
        if (rs.next() && rs.getInt(1) > 0) {
            return false; // Playlist đã tồn tại, không cho phép tạo mới
        }
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }

    // Thêm playlist mới
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

  public Playlist getPlaylistByName(String name, int userId) {
    Playlist playlist = null;
    String sql = "SELECT * FROM Playlists WHERE Name = ? AND UserID = ? AND Status = 1"; // Status = 1 để chỉ lấy playlist còn hoạt động

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, name);
        stmt.setInt(2, userId);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            playlist = new Playlist(
                rs.getInt("PlaylistID"),
                rs.getInt("UserID"),
                0, // Không chứa songID trong bảng Playlists
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
public List<Integer> getSongsInPlaylist(int playlistId) {
    List<Integer> songIds = new ArrayList<>();
    String sql = "SELECT SongID FROM PlaylistSongs WHERE PlaylistID = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlistId);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            songIds.add(rs.getInt("SongID"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return songIds;
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
    
    public List<Playlist> getPlaylistsContainingSong(int userId, int songId) {
    List<Playlist> list = new ArrayList<>();
    String sql = "SELECT p.* FROM Playlists p JOIN PlaylistSongs ps ON p.PlaylistID = ps.PlaylistID " +
                 "WHERE p.UserID = ? AND ps.SongID = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, songId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            list.add(mapResultSetToPlaylist(rs)); // Hàm map tương tự addPlaylist
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}
    private Playlist mapResultSetToPlaylist(ResultSet rs) throws SQLException {
    Playlist playlist = new Playlist(
        rs.getInt("PlaylistID"),
        rs.getInt("UserID"),
        0, // songID không có trong bảng Playlists
        rs.getString("Name"),
        rs.getString("Description"),
        rs.getTimestamp("CreatedDate"),
        rs.getBoolean("IsPublic"),
        rs.getBoolean("Status")
    );
    return playlist;
}
    
    public int countSongsInPlaylist(int playlistId) {
    String sql = "SELECT COUNT(*) FROM PlaylistSongs WHERE PlaylistID = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlistId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}
    public boolean removeSongFromPlaylist(int playlistID, int songID) {
    String sql = "DELETE FROM PlaylistSongs WHERE PlaylistID = ? AND SongID = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlistID);
        stmt.setInt(2, songID);
        return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
    
    public boolean renamePlaylist(int playlistID, String newName, String newDesc) {
    String sql = "UPDATE Playlists SET Name = ?, Description = ? WHERE PlaylistID = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, newName);
        stmt.setString(2, newDesc);
        stmt.setInt(3, playlistID);
        return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
    
    // Trả về danh sách playlistId của user đang chứa bài hát đó
public List<Integer> getPlaylistIdsContainingSong(int userId, int songId) {
    List<Integer> list = new ArrayList<>();
    String sql = "SELECT p.PlaylistID FROM Playlists p " +
                 "JOIN PlaylistSongs ps ON p.PlaylistID = ps.PlaylistID " +
                 "WHERE p.UserID = ? AND ps.SongID = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, userId);
        stmt.setInt(2, songId);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            list.add(rs.getInt("PlaylistID"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}


}
