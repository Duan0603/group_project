package dao;

import model.Playlist;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Songs;

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
    String sql = "SELECT * FROM Playlists WHERE Name = ? AND UserID = ? AND Status = 1";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, name);
        stmt.setInt(2, userId);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            playlist = new Playlist(
                rs.getInt("PlaylistID"),
                rs.getInt("UserID"),
                0, // songID không có trong bảng Playlist
                rs.getString("Name"),
                rs.getString("Description"),
                rs.getTimestamp("CreatedDate"),
                rs.getBoolean("IsPublic"),
                rs.getBoolean("Status"),
                "default.jpg" // Gán thumbnail trực tiếp vào constructor
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
                0, // songID không cần ở đây
                rs.getString("Name"),
                rs.getString("Description"),
                rs.getTimestamp("CreatedDate"),
                rs.getBoolean("IsPublic"),
                rs.getBoolean("Status"),
                     "default.jpg"
            );

            // Gán thumbnail theo bài hát đầu tiên nếu có
            List<Songs> songs = new SongDAO().getSongsByPlaylistId(playlist.getPlaylistID());
            if (!songs.isEmpty()) {
                String title = songs.get(0).getTitle();
                String thumbnail = toImageFileName(title);
                playlist.setThumbnail(thumbnail);
            } else {
                playlist.setThumbnail("default.jpg");
            }

            playlists.add(playlist);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return playlists;
}

private String toImageFileName(String title) {
    if (title == null || title.trim().isEmpty()) {
        return "default.jpg";
    }

    try {
        String noDiacritics = java.text.Normalizer.normalize(title.trim(), java.text.Normalizer.Form.NFD)
            .replaceAll("[\\p{InCombiningDiacriticalMarks}]", "")
            .replace("đ", "d").replace("Đ", "D");

        String[] words = noDiacritics.split("[^a-zA-Z0-9]+");
        if (words.length == 0) {
            return "default.jpg";
        }

        StringBuilder pascalCase = new StringBuilder();
        for (String word : words) {
            if (!word.isEmpty()) {
                pascalCase.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    pascalCase.append(word.substring(1).toLowerCase());
                }
            }
        }

        String fileName = pascalCase.toString();
        if (fileName.isEmpty()) return "default.jpg";
        if (fileName.length() > 50) fileName = fileName.substring(0, 50);

        return fileName + ".jpg";
    } catch (Exception e) {
        System.err.println("Error generating image from title: " + e.getMessage());
        return "default.jpg";
    }
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
                rs.getBoolean("Status"),
                "default.jpg" // Gán thumbnail mặc định
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
        // Xóa các bản ghi liên quan trong PlaylistSongs trước
        String deleteSongsSql = "DELETE FROM PlaylistSongs WHERE PlaylistID = ?";
        try (PreparedStatement delSongsStmt = conn.prepareStatement(deleteSongsSql)) {
            delSongsStmt.setInt(1, playlistID);
            delSongsStmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
        
        // Sau đó mới UPDATE Status = 0
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
    return new Playlist(
        rs.getInt("PlaylistID"),
        rs.getInt("UserID"),
        0, // songID không tồn tại trong bảng Playlists
        rs.getString("Name"),
        rs.getString("Description"),
        rs.getTimestamp("CreatedDate"),
        rs.getBoolean("IsPublic"),
        rs.getBoolean("Status"),
        "default.jpg" // Gán thumbnail mặc định
    );
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
                0,               // Không có songID ở đây
                rs.getString("Name"),
                "",              // Không lấy description
                null,            // Không lấy createdDate
                true,            // Giả định là public
                true,            // Status luôn là true do WHERE đã lọc
                "default.jpg"    // Gán thumbnail mặc định
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

    // Xóa tất cả playlist của user
    public boolean deleteAllPlaylistsByUser(int userId) {
        String selectSql = "SELECT PlaylistID FROM Playlists WHERE UserID = ?";
        try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
            selectStmt.setInt(1, userId);
            ResultSet rs = selectStmt.executeQuery();
            List<Integer> playlistIds = new ArrayList<>();
            while (rs.next()) {
                playlistIds.add(rs.getInt("PlaylistID"));
            }
            if (playlistIds.isEmpty()) return false;
            String inClause = playlistIds.toString().replace('[', '(').replace(']', ')');
            String deleteSongsSql = "DELETE FROM PlaylistSongs WHERE PlaylistID IN " + inClause;
            try (PreparedStatement delSongsStmt = conn.prepareStatement(deleteSongsSql)) {
                delSongsStmt.executeUpdate();
            }
            String deletePlaylistsSql = "DELETE FROM Playlists WHERE PlaylistID IN " + inClause;
            try (PreparedStatement delPlaylistsStmt = conn.prepareStatement(deletePlaylistsSql)) {
                int rows = delPlaylistsStmt.executeUpdate();
                return rows > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa playlist theo tên và userId
    public boolean deletePlaylistByNameAndUser(String name, int userId) {
        // Lấy PlaylistID trước
        Integer playlistId = getPlaylistIdByName(name, userId);
        if (playlistId == null) return false;
        
        // Xóa các bản ghi liên quan trong PlaylistSongs trước
        String deleteSongsSql = "DELETE FROM PlaylistSongs WHERE PlaylistID = ?";
        try (PreparedStatement delSongsStmt = conn.prepareStatement(deleteSongsSql)) {
            delSongsStmt.setInt(1, playlistId);
            delSongsStmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
        
        // Sau đó mới xóa playlist
        String deletePlaylistSql = "DELETE FROM Playlists WHERE PlaylistID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deletePlaylistSql)) {
            stmt.setInt(1, playlistId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public String getFirstSongTitleInPlaylist(int playlistId) {
    String sql = "SELECT TOP 1 s.Title FROM Songs s JOIN PlaylistSongs ps ON s.SongID = ps.SongID " +
                 "WHERE ps.PlaylistID = ? ORDER BY ps.AddedDate ASC";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlistId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return rs.getString("Title");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}
    
    private String getFirstSongThumbnail(int playlistId) {
    String sql = "SELECT TOP 1 s.Thumbnail FROM PlaylistSongs ps " +
                 "JOIN Songs s ON ps.SongID = s.SongID " +
                 "WHERE ps.PlaylistID = ? ORDER BY ps.SongID ASC";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, playlistId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return rs.getString("Thumbnail");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return "default.jpg"; // fallback
}

    public List<Playlist> getPlaylistsWithThumbnails(int userId) {
    List<Playlist> playlists = new ArrayList<>();
    String sql = "SELECT p.*, " +
                 "(SELECT TOP 1 s.Thumbnail FROM PlaylistSongs ps " +
                 "JOIN Songs s ON ps.SongID = s.SongID " +
                 "WHERE ps.PlaylistID = p.PlaylistID ORDER BY ps.SongID ASC) AS Thumbnail " +
                 "FROM Playlists p WHERE p.UserID = ? AND p.Status = 1";

    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            Playlist playlist = new Playlist(
                rs.getInt("PlaylistID"),
                rs.getInt("UserID"),
                0,
                rs.getString("Name"),
                rs.getString("Description"),
                rs.getTimestamp("CreatedDate"),
                rs.getBoolean("IsPublic"),
                rs.getBoolean("Status"),
                rs.getString("Thumbnail") != null ? rs.getString("Thumbnail") : "default.jpg"
            );
            playlists.add(playlist);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return playlists;
}
    // Xóa tất cả playlist AI đã tạo của user
    public boolean deleteAllAIPlaylistsByUser(int userId) {
        String selectSql = "SELECT PlaylistID FROM Playlists WHERE UserID = ? AND (Name LIKE 'AI:%' OR Name LIKE 'Playlist AI%')";
        try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
            selectStmt.setInt(1, userId);
            ResultSet rs = selectStmt.executeQuery();
            List<Integer> playlistIds = new ArrayList<>();
            while (rs.next()) {
                playlistIds.add(rs.getInt("PlaylistID"));
            }
            if (playlistIds.isEmpty()) return false;
            // Xóa các bản ghi liên quan trong PlaylistSongs
            String inClause = playlistIds.toString().replace('[', '(').replace(']', ')');
            String deleteSongsSql = "DELETE FROM PlaylistSongs WHERE PlaylistID IN " + inClause;
            try (PreparedStatement delSongsStmt = conn.prepareStatement(deleteSongsSql)) {
                delSongsStmt.executeUpdate();
            }
            // Xóa các playlist
            String deletePlaylistsSql = "DELETE FROM Playlists WHERE PlaylistID IN " + inClause;
            try (PreparedStatement delPlaylistsStmt = conn.prepareStatement(deletePlaylistsSql)) {
                int rows = delPlaylistsStmt.executeUpdate();
                return rows > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}