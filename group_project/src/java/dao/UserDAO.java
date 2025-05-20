package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.User;
import utils.SecurityUtils;

public class UserDAO extends DBContext {
    
    public User login(String username, String password) {
        String sql = "SELECT * FROM Users WHERE Username = ? AND Password = ? AND Status = 1";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, username);
            st.setString(2, SecurityUtils.getMD5Hash(password));
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setUserID(rs.getInt("UserID"));
                user.setUsername(rs.getString("Username"));
                user.setEmail(rs.getString("Email"));
                user.setFullName(rs.getString("FullName"));
                user.setRole(rs.getString("Role"));
                user.setCreatedDate(rs.getTimestamp("CreatedDate"));
                user.setLastLogin(rs.getTimestamp("LastLogin"));
                user.setStatus(rs.getBoolean("Status"));
                return user;
            }
        } catch (SQLException e) {
            System.out.println("Login error: " + e.getMessage());
        }
        return null;
    }
    
    public boolean register(User user) {
        String sql = "INSERT INTO Users (Username, Password, Email, FullName, Role) VALUES (?, ?, ?, ?, 'USER')";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, user.getUsername());
            st.setString(2, SecurityUtils.getMD5Hash(user.getPassword()));
            st.setString(3, user.getEmail());
            st.setString(4, user.getFullName());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Register error: " + e.getMessage());
            return false;
        }
    }
    
    public List<User> getAllUsers(int page, int pageSize) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM Users ORDER BY UserID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, (page - 1) * pageSize);
            st.setInt(2, pageSize);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                User user = new User();
                user.setUserID(rs.getInt("UserID"));
                user.setUsername(rs.getString("Username"));
                user.setEmail(rs.getString("Email"));
                user.setFullName(rs.getString("FullName"));
                user.setRole(rs.getString("Role"));
                user.setCreatedDate(rs.getTimestamp("CreatedDate"));
                user.setLastLogin(rs.getTimestamp("LastLogin"));
                user.setStatus(rs.getBoolean("Status"));
                users.add(user);
            }
        } catch (SQLException e) {
            System.out.println("Get users error: " + e.getMessage());
        }
        return users;
    }
    
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM Users";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("Count users error: " + e.getMessage());
        }
        return 0;
    }
    
    public boolean updateUser(User user) {
        String sql = "UPDATE Users SET Email = ?, FullName = ?, Role = ?, Status = ? WHERE UserID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, user.getEmail());
            st.setString(2, user.getFullName());
            st.setString(3, user.getRole());
            st.setBoolean(4, user.isStatus());
            st.setInt(5, user.getUserID());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Update user error: " + e.getMessage());
            return false;
        }
    }
    
    public boolean deleteUser(int userID) {
        String sql = "UPDATE Users SET Status = 0 WHERE UserID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, userID);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Delete user error: " + e.getMessage());
            return false;
        }
    }
    
    public boolean changePassword(int userID, String newPassword) {
        String sql = "UPDATE Users SET Password = ? WHERE UserID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, SecurityUtils.getMD5Hash(newPassword));
            st.setInt(2, userID);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Change password error: " + e.getMessage());
            return false;
        }
    }
} 