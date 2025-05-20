package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Song;

public class SongDAO extends DBContext {
    
    public List<Song> getAllSongs(int page, int pageSize) {
        List<Song> songs = new ArrayList<>();
        String sql = "SELECT * FROM Songs WHERE Status = 1 ORDER BY SongID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, (page - 1) * pageSize);
            st.setInt(2, pageSize);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                songs.add(extractSongFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.out.println("Get songs error: " + e.getMessage());
        }
        return songs;
    }
    
    public int getTotalSongs() {
        String sql = "SELECT COUNT(*) FROM Songs WHERE Status = 1";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("Count songs error: " + e.getMessage());
        }
        return 0;
    }
    
    public Song getSongById(int songId) {
        String sql = "SELECT * FROM Songs WHERE SongID = ? AND Status = 1";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, songId);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return extractSongFromResultSet(rs);
            }
        } catch (SQLException e) {
            System.out.println("Get song error: " + e.getMessage());
        }
        return null;
    }
    
    public List<Song> searchSongs(String keyword, int page, int pageSize) {
        List<Song> songs = new ArrayList<>();
        String sql = "SELECT * FROM Songs WHERE Status = 1 AND (Title LIKE ? OR Artist LIKE ? OR Album LIKE ? OR Genre LIKE ?) " +
                    "ORDER BY SongID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            String searchPattern = "%" + keyword + "%";
            st.setString(1, searchPattern);
            st.setString(2, searchPattern);
            st.setString(3, searchPattern);
            st.setString(4, searchPattern);
            st.setInt(5, (page - 1) * pageSize);
            st.setInt(6, pageSize);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                songs.add(extractSongFromResultSet(rs));
            }
        } catch (SQLException e) {
            System.out.println("Search songs error: " + e.getMessage());
        }
        return songs;
    }
    
    public boolean addSong(Song song) {
        String sql = "INSERT INTO Songs (Title, Artist, Album, Genre, Duration, ReleaseDate, FilePath, CoverImage, Status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, song.getTitle());
            st.setString(2, song.getArtist());
            st.setString(3, song.getAlbum());
            st.setString(4, song.getGenre());
            st.setInt(5, song.getDuration());
            st.setDate(6, song.getReleaseDate());
            st.setString(7, song.getFilePath());
            st.setString(8, song.getCoverImage());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Add song error: " + e.getMessage());
            return false;
        }
    }
    
    public boolean updateSong(Song song) {
        String sql = "UPDATE Songs SET Title = ?, Artist = ?, Album = ?, Genre = ?, Duration = ?, " +
                    "ReleaseDate = ?, FilePath = ?, CoverImage = ? WHERE SongID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, song.getTitle());
            st.setString(2, song.getArtist());
            st.setString(3, song.getAlbum());
            st.setString(4, song.getGenre());
            st.setInt(5, song.getDuration());
            st.setDate(6, song.getReleaseDate());
            st.setString(7, song.getFilePath());
            st.setString(8, song.getCoverImage());
            st.setInt(9, song.getSongID());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Update song error: " + e.getMessage());
            return false;
        }
    }
    
    public boolean deleteSong(int songId) {
        String sql = "UPDATE Songs SET Status = 0 WHERE SongID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, songId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Delete song error: " + e.getMessage());
            return false;
        }
    }
    
    public int getTotalSearchResults(String keyword) {
        String sql = "SELECT COUNT(*) FROM Songs WHERE Status = 1 AND (Title LIKE ? OR Artist LIKE ? OR Album LIKE ? OR Genre LIKE ?)";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            String searchPattern = "%" + keyword + "%";
            st.setString(1, searchPattern);
            st.setString(2, searchPattern);
            st.setString(3, searchPattern);
            st.setString(4, searchPattern);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("Count search results error: " + e.getMessage());
        }
        return 0;
    }
    
    private Song extractSongFromResultSet(ResultSet rs) throws SQLException {
        Song song = new Song();
        song.setSongID(rs.getInt("SongID"));
        song.setTitle(rs.getString("Title"));
        song.setArtist(rs.getString("Artist"));
        song.setAlbum(rs.getString("Album"));
        song.setGenre(rs.getString("Genre"));
        song.setDuration(rs.getInt("Duration"));
        song.setReleaseDate(rs.getDate("ReleaseDate"));
        song.setFilePath(rs.getString("FilePath"));
        song.setCoverImage(rs.getString("CoverImage"));
        song.setStatus(rs.getBoolean("Status"));
        return song;
    }
} 