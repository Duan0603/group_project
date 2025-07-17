package dao;

import java.sql.*;
import model.User;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

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
        user.setPremium(rs.getBoolean("Premium"));
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

    public void setPremiumAndDate(int userId, boolean premium) {
        String sql = "UPDATE Users SET Premium = ?, PremiumDate = GETDATE() WHERE UserID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setBoolean(1, premium);
            st.setInt(2, userId);
            st.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Update premium and date error: " + e.getMessage());
            //cua admin
            public int countTotalUsers() {
                String sql = "SELECT COUNT(*) FROM Users";
                try (PreparedStatement st = connection.prepareStatement(sql)) {
                    ResultSet rs = st.executeQuery();
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                } catch (SQLException e) {
                    System.out.println("Count users error: " + e.getMessage());
                }
                return 0;
            }

            public List<User> getAllUsers() {
                List<User> userList = new ArrayList<>();
                String sql = "SELECT * FROM Users ORDER BY UserID";
                try (PreparedStatement st = connection.prepareStatement(sql)) {
                    ResultSet rs = st.executeQuery();
                    while (rs.next()) {
                        userList.add(extractUser(rs));
                    }
                } catch (SQLException e) {
                    System.out.println("Get all users error: " + e.getMessage());
                }
                return userList;
            }

            public boolean updateUser(User user) {
                String sql = "UPDATE Users SET Username = ?, Email = ?, Role = ? WHERE UserID = ?";
                try (PreparedStatement st = connection.prepareStatement(sql)) {
                    st.setString(1, user.getUsername());
                    st.setString(2, user.getEmail());
                    st.setString(3, user.getRole());
                    st.setInt(4, user.getUserId());
                    return st.executeUpdate() > 0;
                } catch (SQLException e) {
                    System.out.println("Update user error: " + e.getMessage());
                    return false;
                }
            }

            public boolean updateUserStatus(int userId, boolean newStatus) {
                String sql = "UPDATE Users SET Status = ? WHERE UserID = ?";
                try (PreparedStatement st = connection.prepareStatement(sql)) {
                    st.setBoolean(1, newStatus);
                    st.setInt(2, userId);
                    return st.executeUpdate() > 0;
                } catch (SQLException e) {
                    System.out.println("Update user status error: " + e.getMessage());
                    return false;
                }
            }

            public boolean deleteUser(int userId) {
                String[] deleteStatements = {
                        "DELETE FROM PlaylistSongs WHERE PlaylistID IN (SELECT PlaylistID FROM Playlists WHERE UserID = ?)",
                        "DELETE FROM Playlists WHERE UserID = ?",
                        "DELETE FROM UserFavorites WHERE UserID = ?",
                        "DELETE FROM ListeningHistory WHERE UserID = ?",
                        "DELETE FROM Follows WHERE followerId = ? OR followedId = ?",
                        "DELETE FROM Users WHERE UserID = ?"
                };

                try {
                    connection.setAutoCommit(false);

                    try (PreparedStatement st1 = connection.prepareStatement(deleteStatements[0])) { st1.setInt(1, userId); st1.executeUpdate(); }
                    try (PreparedStatement st2 = connection.prepareStatement(deleteStatements[1])) { st2.setInt(1, userId); st2.executeUpdate(); }
                    try (PreparedStatement st3 = connection.prepareStatement(deleteStatements[2])) { st3.setInt(1, userId); st3.executeUpdate(); }
                    try (PreparedStatement st4 = connection.prepareStatement(deleteStatements[3])) { st4.setInt(1, userId); st4.executeUpdate(); }
                    try (PreparedStatement st5 = connection.prepareStatement(deleteStatements[4])) { st5.setInt(1, userId); st5.setInt(2, userId); st5.executeUpdate(); }
                    try (PreparedStatement st6 = connection.prepareStatement(deleteStatements[5])) { st6.setInt(1, userId); st6.executeUpdate(); }

                    connection.commit();
                    return true;
                } catch (SQLException e) {
                    System.out.println("Delete user error: " + e.getMessage());
                    try {
                        connection.rollback();
                    } catch (SQLException ex) {
                        System.out.println("Rollback error: " + ex.getMessage());
                    }
                    return false;
                } finally {
                    try {
                        connection.setAutoCommit(true);
                    } catch (SQLException e) {
                        System.out.println("Set auto-commit error: " + e.getMessage());
                    }
                }
            }
        }