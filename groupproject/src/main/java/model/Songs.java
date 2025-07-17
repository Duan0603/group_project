package model;

import java.sql.Date;

public class Songs {
    private int songID;
    private String title;
    private String artist;
    private String album;
    private String genre;
    private int duration; // Duration in seconds
    private Date releaseDate;
    private String filePath;
    private String coverImage;
    private boolean status;

    public Songs() {
    }

    public Songs(int songID, String title, String artist, String album, String genre, int duration, Date releaseDate, String filePath, String coverImage, boolean status) {
        this.songID = songID;
        this.title = title;
        this.artist = artist;
        this.album = album;
        this.genre = genre;
        this.duration = duration;
        this.releaseDate = releaseDate;
        this.filePath = filePath;
        this.coverImage = coverImage;
        this.status = status;
    }

    public int getSongID() { return songID; }
    public void setSongID(int songID) { this.songID = songID; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getArtist() { return artist; }
    public void setArtist(String artist) { this.artist = artist; }

    public String getAlbum() { return album; }
    public void setAlbum(String album) { this.album = album; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public Date getReleaseDate() { return releaseDate; }
    public void setReleaseDate(Date releaseDate) { this.releaseDate = releaseDate; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
    
    public String getDurationFormatted() {
    int minutes = duration / 60;
    int seconds = duration % 60;
    return String.format("%d:%02d", minutes, seconds);
}
}
