package model;

import java.sql.Timestamp;

public class ListeningHistory {
    private int historyID;
    private int userID;
    private int songID;
    private Timestamp listenedAt;

    // Getters & Setters
    public int getHistoryID() {
        return historyID;
    }

    public void setHistoryID(int historyID) {
        this.historyID = historyID;
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

    public Timestamp getListenedAt() {
        return listenedAt;
    }

    public void setListenedAt(Timestamp listenedAt) {
        this.listenedAt = listenedAt;
    }
}
