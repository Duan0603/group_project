package model;

public class User {

    private int userId;
    private String username;
    private String password;
    private String email;
    private String role;
    private boolean status;
    private String provider;
    private String googleID;
    private String facebookID;
    private String resetToken;
    private String resetTokenExpiry;

    public User() {
    }

    public User(int userId, String username, String password, String email, String role, boolean status, String provider, String googleID, String facebookID) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.email = email;
        this.role = role;
        this.status = status;
        this.provider = provider;
        this.googleID = googleID;
        this.facebookID = facebookID;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getGoogleID() {
        return googleID;
    }

    public void setGoogleID(String googleID) {
        this.googleID = googleID;
    }

    public String getFacebookID() {
        return facebookID;
    }

    public void setFacebookID(String facebookID) {
        this.facebookID = facebookID;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public String getResetTokenExpiry() {
        return resetTokenExpiry;
    }

    public void setResetTokenExpiry(String resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }

}