package dao;

import java.sql.*;
import model.User;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class UserDAO extends DBContext {

    public User login(String usernameOrEmail, String password) {
        String sql = "SELECT * FROM Users WHERE (Username = ? OR Email = ?) AND Password = ? AND Status = 1";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, usernameOrEmail);
            st.setString(2, usernameOrEmail);
            st.setString(3, password);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return extractUser(rs);
            }
        } catch (SQLException e) {
            System.out.println("Login error: " + e.getMessage());
        }
        return null;
    }

    public boolean register(User user) {
        String sql = "INSERT INTO Users (Username, Password, Email, Role, Status, Provider, GoogleID, FacebookID) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, user.getUsername());
            st.setString(2, user.getPassword());
            st.setString(3, user.getEmail());
            st.setString(4, user.getRole());
            st.setBoolean(5, user.isStatus());
            st.setString(6, user.getProvider());
            st.setString(7, user.getGoogleID());
            st.setString(8, user.getFacebookID());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Register error: " + e.getMessage());
            return false;
        }
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM Users WHERE Email = ? AND Status = 1";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, email);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return extractUser(rs);
            }
        } catch (SQLException e) {
            System.out.println("Find by email error: " + e.getMessage());
        }
        return null;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, email);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.out.println("Check email exists error: " + e.getMessage());
        }
        return false;
    }

    private User extractUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("UserID"));
        user.setUsername(rs.getString("Username"));
        user.setPassword(rs.getString("Password"));
        user.setEmail(rs.getString("Email"));
        user.setRole(rs.getString("Role"));
        user.setStatus(rs.getBoolean("Status"));
        user.setProvider(rs.getString("Provider"));
        user.setGoogleID(rs.getString("GoogleID"));
        user.setFacebookID(rs.getString("FacebookID"));
        return user;
    }

    public User findByResetToken(String token) {
        String sql = "SELECT * FROM Users WHERE reset_token = ? AND Status = 1";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, token);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return extractUser(rs);
            }
        } catch (SQLException e) {
            System.out.println("Find by reset token error: " + e.getMessage());
        }
        return null;
    }

    public void updateResetToken(String email, String token, String expiry) {
        String sql = "UPDATE Users SET reset_token = ?, reset_token_expiry = ? WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, token);
            st.setString(2, expiry);
            st.setString(3, email);
            st.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Update reset token error: " + e.getMessage());
        }
    }

    public boolean isResetTokenExpired(User user) {
        String expiryStr = user.getResetTokenExpiry();
        if (expiryStr == null) {
            return true;
        }

        try {
            LocalDateTime expiryTime = LocalDateTime.parse(expiryStr, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            return LocalDateTime.now().isAfter(expiryTime);
        } catch (Exception e) {
            System.out.println("Parse expiry error: " + e.getMessage());
            return true;
        }
    }

    public void updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE Users SET Password = ? WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, newPassword); // Bạn nên hash mật khẩu ở đây
            st.setString(2, email);
            st.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Update password by email error: " + e.getMessage());
        }
    }

    public void clearResetToken(String email) {
        String sql = "UPDATE Users SET reset_token = NULL, reset_token_expiry = NULL WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, email);
            st.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Clear reset token error: " + e.getMessage());
        }
    }

    public void updateResetToken(String email, String token) {
        String sql = "UPDATE Users SET reset_token = ? WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, token);
            st.setString(2, email);
            st.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Update reset token error: " + e.getMessage());
        }
    }
}