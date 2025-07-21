package model;

import java.sql.Timestamp;

public class Like {
    private int userId;
    private int songId;
    private Timestamp likedAt;

    public Like() {}

    public Like(int userId, int songId, Timestamp likedAt) {
        this.userId = userId;
        this.songId = songId;
        this.likedAt = likedAt;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getSongId() {
        return songId;
    }

    public void setSongId(int songId) {
        this.songId = songId;
    }

    public Timestamp getLikedAt() {
        return likedAt;
    }

    public void setLikedAt(Timestamp likedAt) {
        this.likedAt = likedAt;
    }
} 