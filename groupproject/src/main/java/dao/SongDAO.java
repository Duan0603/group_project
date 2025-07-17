package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import model.Songs;

public class SongDAO {

    private Connection conn;

    public SongDAO() {
    try {
        DBContext db = new DBContext();
        this.conn = db.getConnection();
    } catch (Exception e) {
        e.printStackTrace();
    }
}

    
    public List<Songs> getRecommendedSongs(int userId) {
    List<Songs> songs = new ArrayList<>();
    String sql =
        "SELECT TOP 10 s.* " +
        "FROM Songs s " +
        "JOIN ListeningHistory h ON s.genre = ( " +
        "    SELECT TOP 1 s2.genre " +
        "    FROM Songs s2 " +
        "    JOIN ListeningHistory h2 ON s2.songID = h2.songID " +
        "    WHERE h2.userID = ? " +
        "    ORDER BY h2.listenedAt DESC " +
        ") " +
        "WHERE s.status = 1 " +
        "ORDER BY NEWID()";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            songs.add(mapResultSetToSong(rs));
        }
    } catch (SQLException e) {
        System.out.println("Error fetching recommended songs: " + e.getMessage());
    }

    return songs;
}
    /**
     * Lấy tất cả bài hát đang active (status = 1)
     */
    public List<Songs> getAllActiveSongs() {
        List<Songs> songs = new ArrayList<>();
        String sql = "SELECT * FROM Songs WHERE status = 1 ORDER BY artist";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                songs.add(mapResultSetToSong(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error fetching all songs: " + e.getMessage());
        }

        return songs;
    }
    
public Songs getSongByTitle(String title) {
    String sql = "SELECT * FROM Songs WHERE title COLLATE Vietnamese_CI_AI = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, title);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return mapResultSetToSong(rs); // dùng lại hàm ánh xạ
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}


public List<Songs> getSongsByAlbum(String albumName, int excludeSongId) {
    List<Songs> songs = new ArrayList<>();
    String sql = "SELECT * FROM Songs WHERE album COLLATE Vietnamese_CI_AI = ? AND songID != ? AND status = 1";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, albumName);
        ps.setInt(2, excludeSongId);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            songs.add(mapResultSetToSong(rs));
        }
    } catch (SQLException e) {
        System.out.println("Error fetching songs by album: " + e.getMessage());
    }

    return songs;
}
public List<Songs> getSongsByGenres(Set<String> genres, int excludeSongId) {
    List<Songs> songs = new ArrayList<>();
    if (genres == null || genres.isEmpty()) return songs;

    String sql = "SELECT * FROM Songs WHERE songID != ? AND status = 1";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, excludeSongId);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            String genreStr = rs.getString("genre");
            boolean match = false;

            if (genreStr != null) {
                // Tách genre từng bài ra từng phần nhỏ, xử lý dấu cách & viết thường
                String[] parts = genreStr.toLowerCase().split(",");
                for (String part : parts) {
                    String trimmed = part.trim();
                    for (String g : genres) {
                        if (trimmed.contains(g.toLowerCase())) {
                            match = true;
                            break;
                        }
                    }
                    if (match) break;
                }
            }

            if (match) {
                Songs s = new Songs();
                s.setSongID(rs.getInt("songID"));
                s.setTitle(rs.getString("title"));
                s.setArtist(rs.getString("artist"));
                s.setGenre(rs.getString("genre"));
                s.setFilePath(rs.getString("filePath"));
                s.setDuration(rs.getInt("duration"));
                songs.add(s);
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return songs;
}
public List<Songs> getSongsByArtist(String artistName) {
    List<Songs> songs = new ArrayList<>();
    String normalizedInput = normalize(artistName); // normalize là hàm xử lý viết hoa/thường/dấu

    String sql = "SELECT * FROM Songs WHERE status = 1";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            String dbArtist = rs.getString("artist");
            if (normalize(dbArtist).contains(normalizedInput)) {
                Songs song = mapResultSetToSong(rs); // ánh xạ từ DB thành object
                songs.add(song);
            }
        }
    } catch (SQLException e) {
        System.out.println("Error fetching songs by artist: " + e.getMessage());
    }

    return songs;
}

private String normalize(String input) {
    if (input == null) return "";
    return input.toLowerCase().replaceAll("[^a-z0-9]", "");
}

    /**
     * Lấy 10 bài hát mới phát hành nhất
     */
    public List<Songs> getNewReleasedSongs() {
        List<Songs> songs = new ArrayList<>();
        String sql = "SELECT TOP 10 * FROM Songs WHERE status = 1 ORDER BY releaseDate DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                songs.add(mapResultSetToSong(rs));
            }
        } catch (SQLException e) {
            System.out.println("Error fetching new songs: " + e.getMessage());
        }

        return songs;
    }

    /**
     * Hàm private giúp tái sử dụng code chuyển đổi ResultSet thành đối tượng Songs
     */
    private Songs mapResultSetToSong(ResultSet rs) throws SQLException {
        Songs song = new Songs();
        song.setSongID(rs.getInt("songID"));
        song.setTitle(rs.getString("title"));
        song.setArtist(rs.getString("artist"));
        song.setAlbum(rs.getString("album"));
        song.setGenre(rs.getString("genre"));
        song.setDuration(rs.getInt("duration"));
        song.setReleaseDate(rs.getDate("releaseDate"));
        song.setFilePath(rs.getString("filePath"));
        song.setCoverImage(rs.getString("coverImage"));
        song.setStatus(rs.getBoolean("status"));
        return song;
    }
    
public List<Songs> getRecentlyPlayedSongs(int userId) {
    List<Songs> list = new ArrayList<>();
    String sql = "SELECT TOP 10 s.* " +
                 "FROM ListeningHistory lh " +
                 "JOIN Songs s ON lh.SongID = s.SongID " +
                 "WHERE lh.UserID = ? AND s.status = 1 " +
                 "ORDER BY lh.ListenedAt DESC";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            list.add(mapResultSetToSong(rs));
        }
    } catch (SQLException e) {
        System.out.println("Error fetching recently played songs: " + e.getMessage());
    }

    return list;
}
public void insertListeningHistory(int userId, int songId) {
    String sql = "INSERT INTO ListeningHistory (UserID, SongID, ListenedAt) VALUES (?, ?, GETDATE())";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ps.setInt(2, songId);
        ps.executeUpdate();
    } catch (SQLException e) {
        System.out.println("Error inserting listening history: " + e.getMessage());
    }
}

public List<String> getRecentArtists(int userId) {
    List<String> artists = new ArrayList<>();
    String sql = "SELECT DISTINCT TOP 5 s.Artist " +
                 "FROM ListeningHistory lh " +
                 "JOIN Songs s ON lh.SongID = s.SongID " +
                 "WHERE lh.UserID = ? AND s.status = 1 " +
                 "ORDER BY lh.ListenedAt DESC";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            artists.add(rs.getString("Artist"));
        }
    } catch (SQLException e) {
        System.out.println("Error fetching recent artists: " + e.getMessage());
    }

    return artists;
}

public List<Songs> getUserFavorites(int userId) {
    List<Songs> list = new ArrayList<>();
    String sql = "SELECT s.* " +
                 "FROM UserFavorites uf " +
                 "JOIN Songs s ON uf.SongID = s.SongID " +
                 "WHERE uf.UserID = ? AND s.status = 1 " +
                 "ORDER BY uf.AddedDate DESC";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            list.add(mapResultSetToSong(rs));
        }
    } catch (SQLException e) {
        System.out.println("Error fetching favorite songs: " + e.getMessage());
    }

    return list;
}
public static String toImageFileName(String title) {
    // Handle null or empty title
    if (title == null || title.trim().isEmpty()) {
        return "default.jpg";
    }

    try {
        // Normalize to remove diacritics and replace Vietnamese characters
        String noDiacritics = java.text.Normalizer.normalize(title.trim(), java.text.Normalizer.Form.NFD)
            .replaceAll("[\\p{InCombiningDiacriticalMarks}]", "")
            .replace("đ", "d").replace("Đ", "D");

        // Split into words, handling consecutive special characters
        String[] words = noDiacritics.split("[^a-zA-Z0-9]+");
        if (words.length == 0) {
            return "default.jpg"; // Fallback if no valid words
        }

        // Build PascalCase name
        StringBuilder pascalCase = new StringBuilder();
        for (String word : words) {
            if (!word.isEmpty()) {
                pascalCase.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    pascalCase.append(word.substring(1).toLowerCase());
                }
            }
        }

        // Ensure the result is not empty and limit length for file name safety
        String fileName = pascalCase.toString();
        if (fileName.isEmpty()) {
            return "default.jpg";
        }
        if (fileName.length() > 50) { // Arbitrary limit to prevent overly long names
            fileName = fileName.substring(0, 50);
        }

        return fileName + ".jpg";
    } catch (Exception e) {
        // Log the error for debugging (replace with your logging framework)
        System.err.println("Error processing title: " + title + " - " + e.getMessage());
        return "default.jpg"; // Fallback on error
    }
}
// cua admin
    public int countTotalSongs() {
    String sql = "SELECT COUNT(*) FROM Songs WHERE Status = 1";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        System.out.println("Count songs error: " + e.getMessage());
    }
    return 0;
    }
    
    public boolean addSong(Songs song) {
        String sql = "INSERT INTO Songs (Title, Artist, Album, Genre, Duration, ReleaseDate, FilePath, CoverImage, Status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, song.getTitle());
            ps.setString(2, song.getArtist());
            ps.setString(3, song.getAlbum());
            ps.setString(4, song.getGenre());
            ps.setInt(5, song.getDuration());
            ps.setDate(6, song.getReleaseDate());
            ps.setString(7, song.getFilePath());
            ps.setString(8, song.getCoverImage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Add song error: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteSong(int songId) {
        String sql = "UPDATE Songs SET Status = 0 WHERE SongID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, songId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Delete song error: " + e.getMessage());
            return false;
        }
    }
}
