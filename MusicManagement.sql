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
    Role VARCHAR(20) DEFAULT 'USER',
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME,
    Status BIT DEFAULT 1,
);

ALTER TABLE Users
ADD Reset_token VARCHAR(255);
ALTER TABLE Users ADD Reset_token_expiry VARCHAR(255);

ALTER TABLE Users ADD Provider VARCHAR(20) DEFAULT 'local';
ALTER TABLE Users ADD GoogleID VARCHAR(50);
ALTER TABLE Users ADD FacebookID VARCHAR(100);
ALTER TABLE Users DROP COLUMN FullName;
ALTER TABLE Users
ALTER COLUMN Username NVARCHAR(50) NOT NULL;

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

-- Login Attempts table
CREATE TABLE LoginAttempts (
    AttemptID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    IPAddress VARCHAR(45),
    AttemptTime DATETIME DEFAULT GETDATE(),
    Success BIT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- User Sessions table
CREATE TABLE UserSessions (
    SessionID VARCHAR(100) PRIMARY KEY,
    UserID INT NOT NULL,
    LoginTime DATETIME DEFAULT GETDATE(),
    ExpiryTime DATETIME,
    LastActivityTime DATETIME,
    IPAddress VARCHAR(45),
    UserAgent VARCHAR(255),
    IsValid BIT DEFAULT 1,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Insert sample admin user (password: admin123)
INSERT INTO Users (Username, Password, Email, FullName, Role)
VALUES ('admin', 'sa', 'admin@music.com', 'System Admin', 'ADMIN');
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

BEGIN TRY
    BEGIN TRAN;  -- Bắt đầu giao dịch

    -- 1. Tìm và xóa constraint UNIQUE hiện có trên Username
    DECLARE @uq_name sysname;
    SELECT @uq_name = kc.name
    FROM sys.key_constraints kc
    INNER JOIN sys.tables t ON kc.parent_object_id = t.object_id
    WHERE t.name = 'Users' AND kc.[type] = 'UQ';

    IF @uq_name IS NOT NULL
    BEGIN
       DECLARE @sql NVARCHAR(MAX);
SET @sql = N'ALTER TABLE Users DROP CONSTRAINT ' + QUOTENAME(@uq_name);
EXEC sp_executesql @sql;
    END

    -- 2. Đổi kiểu Username sang NVARCHAR(50)
    ALTER TABLE Users
    ALTER COLUMN Username NVARCHAR(50) NOT NULL;

    -- 3. Thêm lại UNIQUE constraint rõ ràng
    ALTER TABLE Users
    ADD CONSTRAINT UQ_Users_Username UNIQUE (Username);

    COMMIT TRAN;
    PRINT N'✅ Đã đổi Username sang NVARCHAR(50) và thêm lại UNIQUE thành công.';
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    PRINT N'❌ Lỗi: ' + ERROR_MESSAGE();
END CATCH;