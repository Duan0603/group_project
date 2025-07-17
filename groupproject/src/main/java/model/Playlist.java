package model;

import java.util.Date;

public class Playlist {
    private int playlistID;
    private int userID;
    private int songID;
    private String name;
    private String description;
    private Date createdDate;
    private boolean isPublic;
    private boolean status;

    // Constructor
    public Playlist(int playlistID, int userID, int songID, String name, String description, Date createdDate, boolean isPublic, boolean status) {
        this.playlistID = playlistID;
        this.userID = userID;
        this.songID = songID;
        this.name = name;
        this.description = description;
        this.createdDate = createdDate;
        this.isPublic = isPublic;
        this.status = status;
    }
    

    // Getters and Setters

    public int getPlaylistID() {
        return playlistID;
    }

    public void setPlaylistID(int playlistID) {
        this.playlistID = playlistID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public int getSongID() {
        return songID;
    }

    public void setSongID(int songID) {
        this.songID = songID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public boolean isIsPublic() {
        return isPublic;
    }

    public void setIsPublic(boolean isPublic) {
        this.isPublic = isPublic;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }
    
}