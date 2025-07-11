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

-- Insert sample admin user (password: admin123)
INSERT INTO Users (Username, Password, Email, Role)
VALUES ('admin', 'sa', 'admin@music.com',  'ADMIN');
-- Insert sample genres

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
    PRINT N' Đã đổi Username sang NVARCHAR(50) và thêm lại UNIQUE thành công.';
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    PRINT N' Lỗi: ' + ERROR_MESSAGE();
END CATCH;

-- Insert songs table
INSERT INTO Songs (Title, Artist, Album, Genre, Duration, ReleaseDate, FilePath, CoverImage)
VALUES
(N'Thiên lý ơi', N'Jack', N'Jack', N'Pop, V-Pop, Ballad, Lofi', 220, '2024-02-22', '/songs/ThienLyOi-Jack.mp3', '/coverImages/Jack.jpg'),
(N'Ngôi sao cô đơn', N'Jack', N'Jack', N'Nhạc trẻ, Pop, Synth-wave, EDM', 276, '2022-07-19', '/songs/NgoiSaoCoDon-Jack.mp3', '/coverImages/Jack.jpg'),
(N'Từ nơi tôi sinh ra', N'Jack', N'Jack', N'Reggaeton, Pop', 232, '2023-03-31', '/songs/TuNoiToiSinhRa-Jack.mp3', '/coverImages/Jack.jpg'),
(N'Laylalay', N'Jack', N'Jack', N'V-Pop', 232, '2021-04-12', '/songs/Laylalay-JackG5R.mp3', '/coverImages/Jack.jpg'),
(N'Xóa tên anh đi', N'Jack', N'Jack', N'Nhạc trẻ, Pop, Funk, Disco, Rap/Hip Hop', 192, '2020-03-09', '/songs/XoaTenAnhDi-Jack.mp3', '/coverImages/Jack.jpg'),
(N'Hoa hải đường', N'Jack', N'Jack', N'Pop, EDM, Trap', 230, '2020-10-22', '/songs/HoaHaiDuong-JackG5R.mp3', '/coverImages/Jack.jpg'),
(N'Về bên anh', N'Jack', N'Jack', N'Pop, Dân ca đương đại, Ballad', 261, '2018-01-01', '/songs/VeBenAnh-Jack.mp3', '/coverImages/Jack.jpg'),
(N'Trịnh gia', N'Jack', N'Jack', N'Nhạc trẻ, Pop', 180, '2019-03-09', '/songs/TrinhGia-Jack.mp3', '/coverImages/Jack.jpg'),
(N'Hồng nhan', N'Jack', N'Jack', N'Nhạc trẻ, Pop, Ballad, Dân ca đương đại', 195, '2019-02-19', '/songs/HongNhan-JackG5R.mp3', '/coverImages/Jack.jpg'),
(N'Là 1 thằng con trai', N'Jack', N'Jack', N'Nhạc trẻ, Pop, Dance-Pop, R&B', 246, '2020-03-10', '/songs/LaMotThangConTrai-Jack.mp3', '/coverImages/Jack.jpg'),
(N'Chúng ta của hiện tại', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B, Dream Pop', 302, '2020-12-20', '/songs/ChungTaCuaHienTai-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Hãy trao cho anh', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Pop, EDM, Hip-Hop, Latin Pop', 246, '2019-07-01', '/songs/HayTraoChoAnh-SonTungMTPSnoopDogg.mp3', '/coverImages/sonTung.jpg'),
(N'Chạy ngay đi', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Pop, R&B, Dance-Pop', 248, '2018-05-12', '/songs/ChayNgayDi-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Chúng ta không thuộc về nhau', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Pop, EDM, Tropical House', 233, '2016-08-03', '/songs/ChungTaKhongThuocVeNhau-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Em của ngày hôm qua', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Dance-Pop, EDM', 264, '2013-12-19', '/songs/EmCuaNgayHomQua-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Muộn rồi mà sao còn', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B, Ballad', 276, '2021-04-29', '/songs/MuonRoiMaSaoCon-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Như ngày hôm qua', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Ballad', 222, '2015-12-24', '/songs/NhuNgayHomQua-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Buông đôi tay nhau ra', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B, EDM', 226, '2015-12-04', '/songs/BuongDoiTayNhauRa-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Nắng ấm xa dần', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B', 188, '2013-08-01', '/songs/NangAmXaDan-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Cơn mưa ngang qua', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B, Underground', 288, '2012-08-11', '/songs/ConMuaNgangQua-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Không phải dạng vừa đâu', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, EDM, Dance-Pop', 246, '2015-01-24', '/songs/KhongPhaiDangVuaDau-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Nơi này có anh', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B, Ballad', 260, '2017-02-14', '/songs/NoiNayCoAnh-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Một năm mới bình an', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Nhạc xuân', 247, '2016-01-20', '/songs/MotNamMoiBinhAn-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Anh sai rồi', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Ballad', 252, '2013-08-01', '/songs/AnhSaiRoi-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Ẩm thầm bên em', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B, Ballad', 291, '2015-08-05', '/songs/AmThamBenEm-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Ấn nút nhớ, thả giấc mơ', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Ballad, R&B', 245, '2014-12-16', '/songs/AnNutNhoThaGiacMo-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Lạc trôi', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Traditional Vietnamese Music', 233, '2017-01-01', '/songs/LacTroi-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Khuôn mặt đáng thương', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Dance-Pop, EDM', 257, '2015-02-18', '/songs/KhuonMatDangThuong-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Có chắc yêu là đây', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B, Lo-fi Pop', 202, '2020-07-05', '/songs/CoChacYeuLaDay-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Cơn mưa xa dần', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B', 197, '2013-08-01', '/songs/ConMuaXaDan-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Chắc ai đó sẽ về', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Ballad', 262, '2014-10-21', '/songs/ChacAiDoSeVe-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Thái bình mô hôi rơi', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, Rap', 318, '2014-04-18', '/songs/ThaiBinhMoHoiRoi-SonTungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Nắng ấm ngang qua', N'Sơn Tùng M-TP', N'Sơn Tùng M-TP', N'Nhạc trẻ, Pop, R&B', 195, '2012-08-11', '/songs/NangAmNgangQua-SontungMTP.mp3', '/coverImages/sonTung.jpg'),
(N'Vô hình trong tim em', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 246, '2016-06-27', '/songs/VoHinhTrongTimEm-Mr.Siro.mp3', '/coverImages/mrSiro.jpg'),
(N'Dưới những cơn mưa', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 297, '2014-07-29', '/songs/DuoiNhungConMua-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Day dứt nỗi đau', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 299, '2013-10-10', '/songs/DayDutNoiDau-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Tình yêu chắp vá', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 267, '2013-03-26', '/songs/TinhYeuChapVa-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Sống trong nỗi nhớ', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 333, '2012-09-06', '/songs/SongTrongNoiNho-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Phải chi lúc trước anh sai', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 248, '2012-05-17', '/songs/PhaiChiLucTruocAnhSai-Mr.Siro.mp3', '/coverImages/mrSiro.jpg'),
(N'Bức tranh từ nước mắt', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 260, '2012-01-12', '/songs/BucTranhTuNuocMat-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Đã từng vô giá', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 283, '2011-08-18', '/songs/DaTungVoGia-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Tìm được nhau khó thế nào', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 270, NULL, '/songs/TimDuocNhauKhoTheNao-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Người con gái anh không thể quên', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 269, '2011-01-06', '/songs/NguoiConGaiAnhKhongTheQuen-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Gương mặt lạ lẫm', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 334, '2010-09-16', '/songs/GuongMatLaLam-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Đừng lo anh đợi mà', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 272, '2010-05-27', '/songs/DungLoAnhDoiMa-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Yêu một người vô tâm', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 161, '2010-02-04', '/songs/YeuMotNguoiVoTam-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Tự lau nước mắt', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 324, '2011-09-22', '/songs/TuLauNuocMat-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Một bước yêu vạn dặm đau', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 299, '2020-04-20', '/songs/MotBuocYeuVanDamDau-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Không muốn yêu lại càng say đắm', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 331, '2020-03-24', '/songs/KhongMuonYeuLaiCangSayDam-MrSiro.mp3', '/coverImages/mrSiro.jpg'),
(N'Khóc cùng em', N'Mr.Siro', N'Mr.Siro', N'Nhạc trẻ, Pop, Ballad', 236, '2020-02-25', '/songs/KhocCungEm-MrSiroGRAYWind.mp3', '/coverImages/mrSiro.jpg'),
(N'Nơi tình yêu kết thúc', N'Bùi Anh Tuấn', N'Bùi Anh Tuấn', N'Nhạc trẻ, Pop, Ballad', 318, '2012-08-27', '/songs/NoiTinhYeuKetThuc-BuiAnhTuan.mp3', '/coverImages/buiAnhTuan.jpg'),
(N'Nơi tình yêu bắt đầu', N'Bùi Anh Tuấn', N'Bùi Anh Tuấn', N'Nhạc trẻ, Pop, Ballad', 276, '2012-01-20', '/songs/NoiTinhYeuBatDau-BuiAnhTuan.mp3', '/coverImages/buiAnhTuan.jpg'),
(N'Phía sau một cô gái', N'Soobin Hoàng Sơn', N'Soobin Hoàng Sơn', N'Nhạc Trẻ, Pop, Ballad', 270, '2016-10-18', '/songs/PhiaSauMotCoGai-SoobinHoangSon.mp3', '/coverImages/Soobin.jpg'),
(N'Lalala', N'Soobin Hoàng Sơn', N'Soobin Hoàng Sơn', N'Nhạc Trẻ, R&B', 212, '2016-08-03', '/songs/Lalala-SoobinHoangSon.mp3', '/coverImages/Soobin.jpg'),
(N'Đi để trở về', N'Soobin Hoàng Sơn', N'Soobin Hoàng Sơn', N'Nhạc Trẻ, Pop Ballad, R&B', 209, '2017-02-03', '/songs/DiDeTroVe-SoobinHoangSon.mp3', '/coverImages/Soobin.jpg'),
(N'Chuyến Đi Của Năm (Đi Để Trở Về 2)', N'Soobin Hoàng Sơn', N'Soobin Hoàng Sơn', N'Nhạc Trẻ, Pop Ballad', 296, '2018-01-01', '/songs/ChuyenDiCuaNamDiDeTroVe2-SoobinHoangSon.mp3', '/coverImages/Soobin.jpg'),
(N'Con Bướm Xuân', N'Hồ Quang Hiếu', N'Hồ Quang Hiếu', N'Nhạc Trẻ, Dance Cha‑Cha', 225, '2014-01-01', '/songs/ConBuomXuan-HoQuangHieu.mp3', '/coverImages/hoQuangHieu.jpg'),
(N'Đổi Thay', N'Hồ Quang Hiếu', N'Hồ Quang Hiếu', N'Nhạc Trẻ, Pop Ballad', 270, '2010-01-01', '/songs/DoiThay-HoQuangHieu.mp3', '/coverImages/hoQuangHieu.jpg'),
(N'Ngày Ấy Sẽ Đến', N'Hồ Quang Hiếu', N'Hồ Quang Hiếu', N'Nhạc Trẻ, Pop Ballad', 286, '2010-01-01', '/songs/NgayAySeDen-HoQuangHieu.mp3', '/coverImages/hoQuangHieu.jpg'),
(N'Còn Lại Gì Sau Cơn Mưa', N'Hồ Quang Hiếu', N'Hồ Quang Hiếu', N'Nhạc Trẻ, Pop Ballad', 268, '2025-03-08', '/songs/ConLaiGiSauConMua-HoQuangHieu.mp3', '/coverImages/hoQuangHieu.jpg'),
(N'Mưa Của Ngày Xưa', N'Hồ Quang Hiếu', N'Hồ Quang Hiếu', N'Nhạc Trẻ, Pop Ballad', 284, '2016-01-01', '/songs/MuaCuaNgayMua-HoQuangHieu.mp3', '/coverImages/hoQuangHieu.jpg'),
(N'Tái sinh', N'Tùng Dương', N'Tùng Dương', N'Nhạc Trẻ, Pop Ballad, EDM', 240, '2024-12-27', '/songs/TaiSinh-TungDuong.mp3', '/coverImages/tungDuong.jpg'),
(N'Sáng Mắt chưa', N'Trúc Nhân', N'Trúc Nhân', N'Nhạc Trẻ, Pop Ballad, EDM', 208, '2019-07-31', '/songs/SangMatChua-TrucNhan.mp3', '/coverImages/trucNhan.jpg'),
(N'Giá Như', N'Noo Phước Thịnh', N'Noo Phước Thịnh', N'Nhạc Trẻ, Pop Ballad', 279, '2019-02-27', '/songs/GiaNhu-NooPhuocThinh.mp3', '/coverImages/nooPhuocThinh.jpg'),
(N'Thương Em Là Điều Anh Không Thể Ngờ', N'Noo Phước Thịnh', N'Noo Phước Thịnh', N'Nhạc Trẻ, Pop Ballad', 309, '2018-12-18', '/songs/ThuongEmLaDieuAnhKhongTheNgo-NooPhuocThinh.mp3', '/coverImages/nooPhuocThinh.jpg'),
(N'Yêu Một Người Sao Buồn Đến Thế', N'Noo Phước Thịnh', N'Noo Phước Thịnh', N'Nhạc Trẻ, Pop Ballad', 299, '2020-10-27', '/songs/YeuMotNguoiSaoBuonDenThe1-NooPhuocThinh.mp3', '/coverImages/nooPhuocThinh.jpg'),
(N'Chạm Khẽ Tim Anh Một Chút Thôi', N'Noo Phước Thịnh', N'Noo Phước Thịnh', N'Nhạc Trẻ, Ballad', 346, '2023-11-15', '/songs/ChamKheTimAnhMotChutThoi-NooPhuocThinh.mp3', '/coverImages/nooPhuocThinh.jpg'),
(N'Không Thể Say', N'HIEUTHUHAI', N'HIEUTHUHAI', N'Pop', 228, '2023-04-19', '/songs/KhongTheSay-HIEUTHUHAI.mp3', '/coverImages/hieuThuHai.jpg'),
(N'TRÌNH', N'HIEUTHUHAI', N'HIEUTHUHAI', N'Rap, Hip-hop', 275, '2024-11-25', '/songs/TRINH-HIEUTHUHAI.mp3', '/coverImages/hieuThuHai.jpg'),
(N'Nàng Thơ', N'Hoàng Dũng', N'Hoàng Dũng', N'Pop, Ballad', 254, '2020-03-08', '/songs/NangTho-HoangDung.mp3', '/coverImages/hoangDung.jpg'),
(N'Thích em hơi nhiều', N'Hoàng Dũng', N'Hoàng Dũng', N'Pop, Ballad', 205, '2022-07-03', '/songs/ThichEmHoiNhieu-HoangDung.mp3', '/coverImages/hoangDung.jpg'),
(N'Hơn Cả Yêu', N'Đức Phúc', N'Đức Phúc', N'Pop, Ballad', 256, '2020-02-11', '/songs/HonCaYeu-DucPhuc.mp3', '/coverImages/ducPhuc.jpg'),
(N'Yêu Đương Khó Quá Thì Chạy Về Khóc Với Anh', N'ERIK', N'ERIK', N'Pop, Ballad', 224, '2022-01-26', '/songs/YeuDuongKhoQuaThiChayVeKhocVoiAnh-ERIK.mp3', '/coverImages/erik.jpg'),
(N'Anh Luôn Là Lý Do', N'ERIK', N'ERIK', N'Pop, Ballad', 222, '2021-01-13', '/songs/AnhLuonLaLyDo-ERIK.mp3', '/coverImages/erik.jpg'),
(N'Chạm Đáy Nỗi Đau', N'ERIK', N'ERIK', N'Pop, Ballad', 293, '2018-04-27', '/songs/ChamDayNoiDau-ERIK.mp3', '/coverImages/erik.jpg'),
(N'Nô Lệ Tình Yêu', N'Hồ Việt Trung', N'Hồ Việt Trung', N'Nhạc trẻ', 236, '2013-10-03', '/songs/NoLeTinhYeu-HoVietTrung.mp3', '/coverImages/hoVietTrung.jpg'),
(N'Chuyện Tình Trên Facebook', N'Hồ Việt Trung', N'Hồ Việt Trung', N'Nhạc Trẻ', 277, '2025-01-24', '/songs/ChuyenTinhTrenFacebook-HoVietTrung.mp3', '/coverImages/hoVietTrung.jpg'),
(N'Anh Nguyện Chết Vì Em', N'Hồ Việt Trung', N'Hồ Việt Trung', N'Nhạc Trẻ', 276, '2013-05-16', '/songs/AnhNguyenChetViEm-HoVietTrung.mp3', '/coverImages/hoVietTrung.jpg'),
(N'Chơi', N'Hồ Việt Trung', N'Hồ Việt Trung', N'Nhạc Trẻ, Pop', 298, '2013-01-01', '/songs/Choi-HoVietTrung.mp3', '/coverImages/hoVietTrung.jpg'),
(N'Đại Gia Thất Tình', N'Hồ Việt Trung', N'Hồ Việt Trung', N'Nhạc Trẻ, Pop', 268, '2013-01-01', '/songs/DaiGiaThatTinh-HoVietTrung.mp3', '/coverImages/hoVietTrung.jpg'),
(N'Không Ngừng Yêu Em', N'Hồ Việt Trung', N'Hồ Việt Trung', N'Nhạc Trẻ, Pop', 268, '2013-01-01', '/songs/KhongNgungYeuEm-HoVietTrung.mp3', '/coverImages/hoVietTrung.jpg'),
(N'Mình Là Gì Của Nhau', N'Lou Hoàng', N'Lou Hoàng', N'Nhạc Trẻ, R&B Pop', 229, '2016-09-21', '/songs/MinhLaGiCuaNhau-LouHoang.mp3', '/coverImages/louHoang.jpg'),
(N'Yêu Em Dại Khờ', N'Lou Hoàng', N'Lou Hoàng', N'Nhạc Trẻ, V‑Pop', 325, '2018-12-28', '/songs/YeuEmDaiKho-LouHoang.mp3', '/coverImages/louHoang.jpg'),
(N'Là Bạn Không Thể Yêu', N'Lou Hoàng', N'Lou Hoàng', N'Nhạc Trẻ, Pop Ballad', 254, '2019-09-29', '/songs/LaBanKhongTheYeuVux-LouHoang.mp3', '/coverImages/louHoang.jpg'),
(N'Bad Trip', N'RPT MCK', N'RPT MCK', N'Rap Việt, Hip-hop', 95, '2023-03-03', '/songs/BadTrip-MCK.mp3', '/coverImages/rptMck.jpg'),
(N'Đã lỡ yêu em nhiều', N'JustaTee', N'JustaTee', N'Nhạc Trẻ, Pop, R&B', 261, '2017-11-13', '/songs/DaLoYeuEmNhieu-JustaTee.mp3', '/coverImages/justaTee.jpg'),
(N'Mưa Tháng Sáu', N'Văn Mai Hương', N'Văn Mai Hương', N'Nhạc Trẻ, Pop, Ballad', 257, '2018-06-22', '/songs/MuaThangSau-VanMaiHuongGREYDTrungQuanIdol.mp3', '/coverImages/trungQuan.jpg'),
(N'Ước Mơ Của Mẹ', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Ballad', 255, '2019-09-25', '/songs/UocMoCuaMe-QuanAP.mp3', '/coverImages/quanAp.jpg'),
(N'Đáp Án Cuối Cùng', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Ballad', 291, '2020-09-26', '/songs/DapAnCuoiCung-QuanAP.mp3', '/coverImages/quanAp.jpg'),
(N'You Are My Crush', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Pop', 261, '2019-04-19', '/songs/YouAreMyCrush-QuanAP.mp3', '/coverImages/quanAp.jpg'),
(N'Bông Hoa Đẹp Nhất', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Ballad', 315, '2019-09-26', '/songs/BongHoaDepNhat-QuanAP.mp3', '/coverImages/quanAp.jpg'),
(N'Có Ai Hẹn Hò Cùng Em Chưa', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Pop', 309, '2019-11-05', '/songs/CoAiHenHoCungEmChua-QuanAP.mp3', '/coverImages/quanAp.jpg'),
(N'Đừng Như Thói Quen', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Ballad', 260, '2019-10-18', '/songs/DungNhuThoiQuen-QuanAPVanMaiHuong.mp3', '/coverImages/quanAp.jpg'),
(N'Phản Bội Chính Mình', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Ballad', 242, '2019-12-28', '/songs/PhanBoiChinhMinh-QuanAPVuongAnhTu.mp3', '/coverImages/quanAp.jpg'),
(N'Yêu Là Tha Thu', N'Quân A.P', N'Quân A.P', N'Nhạc Trẻ, Ballad', 300, '2020-01-10', '/songs/YeuLaThaThu-QuanAP.mp3', '/coverImages/quanAp.jpg'),
(N'Sai Người Sai Thời Điểm', N'Thanh Hưng', N'Thanh Hưng', N'Nhạc Trẻ, Pop, Ballad', 367, '2019-05-10', '/songs/SaiNguoiSaiThoiDiem-ThanhHungIdol.mp3', '/coverImages/thanhHung.jpg'),
(N'Id 072019', N'W/n', N'W/n', N'Nhạc Trẻ, R&B', 272, '2019-07-20', '/songs/Id072019-WN.mp3', '/coverImages/wn.png'),
(N'2022', N'W/n', N'W/n', N'Nhạc Trẻ, Pop', 200, '2022-01-01', '/songs/2022-WN.mp3', '/coverImages/wn.png'),
(N'3107_4', N'W/n', N'W/n', N'Nhạc Trẻ, R&B', 213, '2019-07-31', '/songs/3107_4-WN.mp3', '/coverImages/wn.png'),
(N'3107_3', N'W/n', N'W/n', N'Nhạc Trẻ, R&B', 235, '2019-07-30', '/songs/3107_3-WN.mp3', '/coverImages/wn.png');