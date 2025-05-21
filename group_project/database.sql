-- Create database
CREATE DATABASE MusicManagement;
GO

USE MusicManagement;
GO

-- Users table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    FullName NVARCHAR(100),
    Role VARCHAR(20) DEFAULT 'USER',
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME,
    Status BIT DEFAULT 1
);

-- Artists table (extends Users)
CREATE TABLE Artists (
    artistId INT PRIMARY KEY,
    userId INT UNIQUE NOT NULL,
    biography NVARCHAR(1000),
    verified BIT DEFAULT 0,
    FOREIGN KEY (userId) REFERENCES Users(UserID)
);

-- Albums table
CREATE TABLE Albums (
    albumId INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(100) NOT NULL,
    artistId INT NOT NULL,
    coverImage VARCHAR(255),
    releaseDate DATE,
    description NVARCHAR(500),
    createdAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (artistId) REFERENCES Artists(artistId)
);

-- Songs table
CREATE TABLE Songs (
    SongID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Artist NVARCHAR(100),
    Album NVARCHAR(100),
    Genre NVARCHAR(50),
    Duration INT, -- Duration in seconds
    ReleaseDate DATE,
    FilePath VARCHAR(255),
    CoverImage VARCHAR(255),
    Status BIT DEFAULT 1
);

-- Playlists table
CREATE TABLE Playlists (
    PlaylistID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsPublic BIT DEFAULT 0,
    Status BIT DEFAULT 1
);

-- PlaylistSongs table (junction table for Playlists and Songs)
CREATE TABLE PlaylistSongs (
    PlaylistID INT,
    SongID INT,
    AddedDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (PlaylistID, SongID),
    FOREIGN KEY (PlaylistID) REFERENCES Playlists(PlaylistID),
    FOREIGN KEY (SongID) REFERENCES Songs(SongID)
);

-- UserFavorites table
CREATE TABLE UserFavorites (
    UserID INT,
    SongID INT,
    AddedDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (UserID, SongID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (SongID) REFERENCES Songs(SongID)
);

-- ListeningHistory table
CREATE TABLE ListeningHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    SongID INT FOREIGN KEY REFERENCES Songs(SongID),
    ListenedAt DATETIME DEFAULT GETDATE()
);

-- Insert sample admin user (password: admin123)
INSERT INTO Users (Username, Password, Email, FullName, Role)
VALUES ('admin', '123', 'admin@music.com', 'System Admin', 'ADMIN');

-- Insert sample genres
INSERT INTO Songs (Title, Artist, Album, Genre, Duration) VALUES
('Sample Song 1', 'Artist 1', 'Album 1', 'Pop', 180),
('Sample Song 2', 'Artist 2', 'Album 2', 'Rock', 240),
('Sample Song 3', 'Artist 3', 'Album 3', 'Jazz', 300);

-- Follows table (for user following artists/users)
CREATE TABLE Follows (
    followerId INT,
    followedId INT,
    followedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (followerId, followedId),
    FOREIGN KEY (followerId) REFERENCES Users(UserID),
    FOREIGN KEY (followedId) REFERENCES Users(UserID)
);

-- Likes table
CREATE TABLE Likes (
    userId INT,
    songId INT,
    likedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (userId, songId),
    FOREIGN KEY (userId) REFERENCES Users(UserID),
    FOREIGN KEY (songId) REFERENCES Songs(SongID)
); 