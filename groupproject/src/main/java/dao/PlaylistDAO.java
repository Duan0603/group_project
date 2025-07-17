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
  public Playlist addPlaylist(Playlist playlist) {
        // Kiểm tra xem playlist với tên này đã tồn tại cho người dùng này chưa
        String checkExistSql = "SELECT COUNT(*) FROM Playlists WHERE Name = ? AND UserID = ? AND Status = 1";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkExistSql)) {
            checkStmt.setString(1, playlist.getName());
            checkStmt.setInt(2, playlist.getUserID());
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("Playlist với tên này đã tồn tại.");
                return null; // Playlist đã tồn tại
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }

        // Nếu chưa, thêm playlist mới và lấy lại ID được tạo
        String sql = "INSERT INTO Playlists (UserID, Name, Description, CreatedDate, IsPublic, Status) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, playlist.getUserID());
            stmt.setString(2, playlist.getName());
            stmt.setString(3, playlist.getDescription());
            stmt.setTimestamp(4, new Timestamp(playlist.getCreatedDate().getTime()));
            stmt.setBoolean(5, playlist.isIsPublic());
            stmt.setBoolean(6, true); // Trạng thái luôn là true khi tạo mới

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                // Lấy ID vừa được tạo
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        playlist.setPlaylistID(generatedKeys.getInt(1)); // Cập nhật đối tượng với ID mới
                        return playlist; // Trả về đối tượng hoàn chỉnh
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Trả về null nếu thêm thất bại
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
    public boolean removeSongFromPlaylist(int playlistId, int songId) {
        String sql = "DELETE FROM PlaylistSongs WHERE PlaylistID = ? AND SongID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistId);
            stmt.setInt(2, songId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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

    public List<Integer> getSongsInPlaylistByUser(int playlistId, int userId) {
        List<Integer> songIds = new ArrayList<>();
        String sql = "SELECT ps.SongID FROM PlaylistSongs ps JOIN Playlists p ON ps.PlaylistID = p.PlaylistID WHERE ps.PlaylistID = ? AND p.UserID = ? AND p.Status = 1";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                songIds.add(rs.getInt("SongID"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return songIds;
    }

    // Lấy playlistId theo tên playlist và userId
    public Integer getPlaylistIdByName(String name, int userId) {
        String sql = "SELECT PlaylistID FROM Playlists WHERE Name = ? AND UserID = ? AND Status = 1";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                System.out.println("PlaylistID: " + rs.getInt("PlaylistID"));
                return rs.getInt("PlaylistID");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy tất cả playlist (mới nhất lên đầu)
    public List<Playlist> getAllPlaylists() {
        List<Playlist> playlists = new ArrayList<>();
        String sql = "SELECT PlaylistID, Name, UserID FROM Playlists WHERE Status = 1 ORDER BY PlaylistID DESC";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Playlist playlist = new Playlist(
                    rs.getInt("PlaylistID"),
                    rs.getInt("UserID"),
                    0, // Không chứa songID ở đây
                    rs.getString("Name"),
                    "", // Không lấy description ở đây
                    null, // Không lấy createdDate ở đây
                    true, // Không lấy isPublic ở đây
                    true  // Status = 1
                );
                playlists.add(playlist);
            }
        } catch (SQLException e) {
            System.err.println("[PlaylistDAO] SQL Error fetching all playlists: " + e.getMessage());
            e.printStackTrace();
        }
        return playlists;
    }

    // Tạo playlist mới và trả về ID vừa tạo
    public int createPlaylistAndGetId(String playlistName, int userId) {
        String sql = "INSERT INTO Playlists (Name, UserID, Status) VALUES (?, ?, 1)";
        int newPlaylistId = -1;
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, playlistName);
            stmt.setInt(2, userId);
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        newPlaylistId = generatedKeys.getInt(1);
                        System.out.println("[PlaylistDAO] Playlist mới được tạo với ID: " + newPlaylistId);
                    } else {
                        System.err.println("[PlaylistDAO] Không lấy được ID sau khi tạo playlist.");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[PlaylistDAO] SQL Error creating playlist '" + playlistName + "' for user ID " + userId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return newPlaylistId;
    }

    // Thêm bài hát vào playlist (nếu chưa có)
    public boolean addSongToPlaylist(int playlistId, int songId) {
        String checkSql = "SELECT COUNT(*) FROM PlaylistSongs WHERE PlaylistID = ? AND SongID = ?";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, playlistId);
            checkStmt.setInt(2, songId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    System.out.println("[PlaylistDAO] Bài hát ID " + songId + " đã tồn tại trong playlist ID " + playlistId + ". Không thêm lại.");
                    return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("[PlaylistDAO] Lỗi khi kiểm tra bài hát trong playlist: " + e.getMessage());
        }

        String sql = "INSERT INTO PlaylistSongs (PlaylistID, SongID) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistId);
            stmt.setInt(2, songId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("[PlaylistDAO] SQL Error adding song ID " + songId + " to playlist ID " + playlistId + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

}
