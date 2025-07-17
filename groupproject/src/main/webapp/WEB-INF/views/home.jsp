<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Songs" %>
<%@ page import="dao.SongDAO" %>
<%@ page import="model.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<%
    User user = (User) session.getAttribute("user");
    List<Songs> recommended = null;
    if (user != null) {
        recommended = new SongDAO().getRecommendedSongs(user.getUserId());
    }
    String displayName = (user != null) ? user.getUsername() : null;
%>

<%
    String avatarInitial = "U";
    if (user != null && user.getUsername() != null && !user.getUsername().isEmpty()) {
        avatarInitial = user.getUsername().substring(0, 1).toUpperCase();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Pinkify - Trang chủ</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* Reset cơ bản */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            height: 100vh;
            overflow: hidden;
        }

        body {
            background: #000; /* Black background */
            color: #fff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            flex-direction: column;
        }

        /* Top Navigation Bar */
        .top-nav {
            background: #000;
            padding: 8px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 64px;
            position: relative;
            z-index: 1000;
            border-bottom: 1px solid #e84393; /* Pink border */
        }

        .nav-left {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .nav-buttons {
            display: flex;
            gap: 8px;
        }

        .nav-btn {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: rgba(232, 67, 147, 0.7); /* Pink background */
            border: 2px solid #fff;
            color: #fff;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s;
        }

        .nav-btn:hover {
            background: #ff69b4; /* Lighter pink on hover */
        }

        .nav-btn:disabled {
            color: #727272;
            cursor: not-allowed;
        }

        .search-container {
            position: relative;
            width: 364px;
            margin-left: 16px;
        }

        .search-input {
            width: 100%;
            height: 48px;
            background: #1a1a1a;
            border: 2px solid #e84393; /* Pink border */
            border-radius: 24px;
            padding: 0 48px 0 16px;
            color: #fff;
            font-size: 14px;
        }

        .search-input::placeholder {
            color: #b3b3b3;
        }

        .search-icon {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #e84393; /* Pink search icon */
        }

        .user-menu {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: #e84393;
            color: black;
            font-weight: bold;
            font-size: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        /* Main Layout Container */
        .main-container {
            display: flex;
            flex: 1;
            overflow: hidden;
        }

        /* Left Sidebar */
        .left-sidebar {
            width: 280px;
            background: #1a1a1a; /* Darker black */
            display: flex;
            flex-direction: column;
            position: relative;
            resize: horizontal;
            min-width: 280px;
            max-width: 420px;
        }

        .sidebar-top {
            padding: 8px;
            background: #1a1a1a;
        }

        .sidebar-section {
            background: #1a1a1a;
            border-radius: 8px;
            margin-bottom: 8px;
            overflow: hidden;
        }

        .sidebar-header {
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 16px;
            color: #e84393; /* Pink text */
            font-size: 16px;
            font-weight: 600;
        }

        .sidebar-item {
            padding: 12px 16px;
            color: #b3b3b3;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 16px;
            transition: color 0.2s;
            font-size: 14px;
            font-weight: 500;
        }

        .sidebar-item:hover {
            color: #e84393; /* Pink on hover */
        }

        .sidebar-item.active {
            color: #e84393; /* Pink active state */
        }

        .library-section {
            flex: 1;
            overflow-y: auto;
            padding: 0 8px;
        }

        .library-item {
            padding: 8px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            border-radius: 4px;
            transition: background 0.2s;
        }

        .library-item:hover {
            background: rgba(232, 67, 147, 0.1); /* Pink hover */
        }

        .library-item img {
            width: 48px;
            height: 48px;
            border-radius: 4px;
            object-fit: cover;
        }

        .library-item-info {
            flex: 1;
            min-width: 0;
        }

        .library-item-title {
            font-size: 14px;
            font-weight: 500;
            color: #fff;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .library-item-subtitle {
            font-size: 12px;
            color: #b3b3b3;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* Main Content Area */
        .main-content {
            flex: 1;
            background: #000; /* Black background */
            overflow-y: auto;
            position: relative;
        }

        .content-header {
            position: sticky;
            top: 0;
            background: rgba(26, 26, 26, 0.9); /* Darker black with transparency */
            backdrop-filter: blur(10px);
            z-index: 100;
            padding: 16px 24px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .content-body {
            padding: 0 24px 24px;
        }

        .greeting {
            font-size: 32px;
            font-weight: 700;
            color: #e84393; /* Pink greeting */
            margin-bottom: 24px;
        }

        .section-title {
            font-size: 24px;
            font-weight: 700;
            color: #e84393; /* Pink section title */
            margin-bottom: 16px;
        }

        .quick-access-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 8px;
            margin-bottom: 40px;
        }

        .quick-access-item {
            background: rgba(232, 67, 147, 0.1); /* Pink background */
            border: 2px solid #e84393; /* Pink border */
            border-radius: 4px;
            display: flex;
            align-items: center;
            overflow: hidden;
            transition: background 0.2s;
            cursor: pointer;
            height: 80px;
        }

        .quick-access-item:hover {
            background: rgba(255, 105, 180, 0.2); /* Lighter pink on hover */
        }

        .quick-access-item img {
            width: 80px;
            height: 80px;
            object-fit: cover;
        }

        .quick-access-info {
            padding: 16px;
            font-size: 16px;
            font-weight: 600;
            color: #fff;
        }

        .carousel-container {
            position: relative;
            margin-bottom: 40px;
        }

        .carousel-items {
            display: flex;
            gap: 16px;
            overflow-x: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
            padding-bottom: 16px;
        }

        .carousel-items::-webkit-scrollbar {
            display: none;
        }

        .card {
            background: #1a1a1a; /* Darker black */
            border: 2px solid #e84393; /* Pink border */
            border-radius: 8px;
            padding: 16px;
            width: 180px;
            flex-shrink: 0;
            transition: background 0.2s;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .card:hover {
            background: #282828;
        }

        .card img {
            width: 100%;
            aspect-ratio: 1;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 16px;
        }

        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: #fff;
            margin-bottom: 8px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .card-subtitle {
            font-size: 14px;
            color: #b3b3b3;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .play-button {
            position: absolute;
            bottom: 104px;
            right: 16px;
            width: 48px;
            height: 48px;
            background: #e84393; /* Pink play button */
            border-radius: 50%;
            border: 2px solid #fff; /* White border */
            color: #000;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transform: translateY(8px);
            transition: all 0.2s;
            box-shadow: 0 8px 16px rgba(232, 67, 147, 0.5); /* Pink shadow */
        }

        .card:hover .play-button {
            opacity: 1;
            transform: translateY(0);
        }

        .play-button:hover {
            background: #ff69b4; /* Lighter pink on hover */
            transform: scale(1.05);
        }

        /* Navigation Buttons */
        .nav-button {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background: #121212;
            border: none;
            box-shadow: none;
            color: #b3b3b3;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 10;
            font-size: 18px;
            transition: background 0.2s, color 0.2s;
        }

        .carousel-container:hover .nav-button,
        #slideshow:hover .nav-button {
            display: flex;
        }

        .nav-button.active {
            display: flex;
        }

        .nav-button:hover {
            background: #2a2a2a;
            color: #fff;
        }

        .nav-button i {
            font-size: 18px;
            color: inherit;
        }
        .nav-left-btn {
            left: 10px;
        }

        .nav-right-btn {
            right: 10px;
        }

        /* Right Sidebar */
        .right-sidebar {
            width: 280px;
            background: #1a1a1a;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .now-playing-section {
            flex: 1;
            padding: 16px;
            overflow-y: auto;
            text-align: center;
        }

        .now-playing-header {
            font-size: 16px;
            font-weight: 600;
            color: #e84393;
            margin-bottom: 16px;
        }

        .now-playing-cover {
            width: 200px;
            height: 200px;
            border: 2px solid #e84393;
            border-radius: 10px;
            object-fit: cover;
            box-shadow: 0 4px 15px rgba(232, 67, 147, 0.5);
            margin-bottom: 16px;
        }

        .now-playing-title {
            font-size: 1.4rem;
            font-weight: bold;
            color: #fff;
            margin-bottom: 5px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 200px;
        }

        .now-playing-artist {
            font-size: 1rem;
            color: #b3b3b3;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 200px;
        }

        /* Bottom Player */
        .bottom-player {
            height: 90px;
            background: #1a1a1a;
            border-top: 1px solid #e84393;
            display: flex;
            align-items: center;
            padding: 0 16px;
            position: relative;
            z-index: 1000;
        }

        .now-playing {
            width: 280px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .now-playing img {
            width: 56px;
            height: 56px;
            border: 2px solid #e84393; /* Pink border */
            border-radius: 4px;
            object-fit: cover;
        }

        .now-playing-info {
            flex: 1;
            min-width: 0;
        }

        .now-playing-title {
            font-size: 14px;
            color: #fff;
            font-weight: 500;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .now-playing-artist {
            font-size: 12px;
            color: #b3b3b3;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .player-controls {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .control-buttons {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .control-btn {
            width: 32px;
            height: 32px;
            border: 2px solid #e84393; /* Pink border */
            background: #000; /* Black background */
            color: #e84393; /* Pink icon */
            cursor: pointer;
            transition: color 0.2s;
        }

        .control-btn:hover {
            color: #ff69b4; /* Lighter pink on hover */
        }

        .control-btn.play {
            width: 40px;
            height: 40px;
            background: #e84393; /* Pink play button */
            color: #000;
            border-radius: 50%;
            font-size: 16px;
        }

        .control-btn.play:hover {
            background: #ff69b4; /* Lighter pink on hover */
            transform: scale(1.05);
        }

        .progress-bar {
            width: 100%;
            max-width: 500px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .progress-time {
            font-size: 12px;
            color: #b3b3b3;
            min-width: 40px;
        }

        .progress-track {
            flex: 1;
            height: 4px;
            background: #404040;
            border-radius: 2px;
            position: relative;
            cursor: pointer;
        }

        .progress-fill {
            height: 100%;
            background: #e84393; /* Pink progress */
            border-radius: 2px;
            width: 30%;
            position: relative;
        }

        .volume-controls {
            width: 280px;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 8px;
        }

        .volume-btn {
            width: 32px;
            height: 32px;
            border: 2px solid #e84393; /* Pink border */
            background: #000; /* Black background */
            color: #e84393; /* Pink icon */
            cursor: pointer;
            transition: color 0.2s;
        }

        .volume-btn:hover {
            color: #ff69b4; /* Lighter pink on hover */
        }

        .volume-bar {
            width: 100px;
            height: 4px;
            background: #404040;
            border-radius: 2px;
            position: relative;
            cursor: pointer;
        }

        .volume-fill {
            height: 100%;
            background: #e84393; /* Pink volume */
            border-radius: 2px;
            width: 70%;
        }

        /* Queue Panel */
        .queue-right-panel {
            position: fixed;
            top: 0;
            right: -400px;
            width: 360px;
            height: 100%;
            background-color: #1a1a1a; /* Darker black */
            color: #fff;
            z-index: 9999;
            transition: right 0.3s ease;
            box-shadow: -5px 0 15px rgba(232, 67, 147, 0.5); /* Pink shadow */
            padding: 20px;
        }

        .queue-right-panel.active {
            right: 0;
        }

        .queue-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: bold;
            font-size: 18px;
            color: #e84393; /* Pink header */
            margin-bottom: 25px;
        }

        .queue-icon {
            font-size: 36px;
            color: #e84393; /* Pink icon */
            margin-bottom: 15px;
            display: block;
            margin-left: auto;
            margin-right: auto;
        }

        .queue-content h5 {
            font-size: 20px;
            font-weight: bold;
            color: #e84393; /* Pink text */
            margin-bottom: 8px;
            text-align: center;
        }

        .queue-content p {
            color: #b3b3b3;
            font-size: 14px;
            margin-bottom: 20px;
            text-align: center;
        }

        .find-btn {
            background-color: #e84393; /* Pink button */
            color: #000;
            border: none;
            padding: 10px 20px;
            font-weight: bold;
            border-radius: 30px;
            cursor: pointer;
            transition: background 0.2s;
            display: block;
            margin: 0 auto;
        }

        .find-btn:hover {
            background-color: #ff69b4; /* Lighter pink on hover */
        }

        .close-btn {
            background: none;
            border: none;
            color: #e84393; /* Pink close button */
            font-size: 22px;
            cursor: pointer;
        }

        /* Scrollbar Styling */
        .main-content::-webkit-scrollbar,
        .library-section::-webkit-scrollbar {
            width: 8px;
        }

        .main-content::-webkit-scrollbar-track,
        .library-section::-webkit-scrollbar-track {
            background: transparent;
        }

        .main-content::-webkit-scrollbar-thumb,
        .library-section::-webkit-scrollbar-thumb {
            background: #e84393; /* Pink scrollbar */
            border-radius: 4px;
        }

        .main-content::-webkit-scrollbar-thumb:hover,
        .library-section::-webkit-scrollbar-thumb:hover {
            background: #ff69b4; /* Lighter pink on hover */
        }

        /* Resize handle */
        .left-sidebar::after {
            content: '';
            position: absolute;
            right: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            cursor: col-resize;
            background: transparent;
        }

        .left-sidebar:hover::after {
            background: #e84393; /* Pink resize handle */
        }

        /* Responsive */
        @media (max-width: 768px) {
            .right-sidebar {
                display: none;
            }

            .left-sidebar {
                width: 240px;
                min-width: 240px;
            }

            .search-container {
                width: 200px;
            }
        }
    </style>
</head>
<body>


<!-- Main Container -->
<div class="main-container">
    <!-- Left Sidebar -->
    <aside class="left-sidebar">
        <div class="sidebar-top">
            <div class="sidebar-section">
                <a href="${pageContext.request.contextPath}/home" class="sidebar-item active">
                    <i class="fas fa-home"></i>
                    Trang chủ
                </a>
                <a href="#" class="sidebar-item">
                    <i class="fas fa-search"></i>
                    Tìm kiếm
                </a>
            </div>
            <div class="sidebar-section">
                <div class="library-header">
                            <span>
                                <i class="fas fa-list"></i>
                                Thư viện
                            </span>
                    <i class="fas fa-plus"></i>
                </div>
            </div>
        </div>
        <div class="library-section">
            <div class="library-item">
                <img src="https://via.placeholder.com/48/1db954/FFFFFF?text=♥" alt="Liked Songs">
                <div class="library-item-info">
                    <div class="library-item-title">Bài hát đã thích</div>
                    <div class="library-item-subtitle">Danh sách phát • 1 bài hát</div>
                </div>
            </div>
            <!-- Nghệ sĩ đã nghe gần đây -->
            <c:forEach var="artist" items="${recentArtists}">
                <div class="library-item">
                    <img src="artistImages/${artist}.jpg" alt="${artist}">
                    <div class="library-item-info">
                        <a href="home?action=artist&name=${artist}">
                            <div class="library-item-title">${artist}</div>
                            <div class="library-item-subtitle">Nghệ sĩ</div>
                        </a>
                    </div>
                </div>
            </c:forEach>
            <!-- Nếu đã click nghệ sĩ, hiển thị danh sách bài hát -->
            <c:if test="${not empty artistSongs}">
                <c:forEach var="song" items="${artistSongs}">
                    <div class="library-item">
                        <img src="coverImages/${song.coverImage}" alt="${song.title}">
                        <div class="library-item-info">
                            <a href="home?title=${song.title}">
                                <div class="library-item-title">${song.title}</div>
                                <div class="library-item-subtitle">${song.artist}</div>
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </c:if>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <div class="content-header">
            <div class="greeting">Chào <%= displayName != null ? displayName : "bạn"%>!</div>
        </div>
        <div class="content-body">
            <!-- Quick Access Grid -->
            <div class="quick-access-grid">
                <div class="quick-access-item">
                    <img src="https://via.placeholder.com/80/1db954/FFFFFF?text=♥" alt="Liked Songs">
                    <div class="quick-access-info">Bài hát đã thích</div>
                </div>
                <div class="quick-access-item">
                    <img src="https://via.placeholder.com/80/e84393/FFFFFF?text=1" alt="Playlist">
                    <div class="quick-access-info">My Playlist #1</div>
                </div>
                <div class="quick-access-item">
                    <img src="https://via.placeholder.com/80/e84393/FFFFFF?text=2" alt="Playlist">
                    <div class="quick-access-info">Recently Played</div>
                </div>
                <div class="quick-access-item">
                    <img src="albumImages/haytraochoanh.jpg" alt="Album">
                    <div class="quick-access-info">Hãy Trao Cho Anh</div>
                </div>
            </div>

            <!-- Slideshow -->
            <div id="slideshow" style="width: 100%; margin-bottom: 30px; position: relative;">
                <img id="slideImage" src="https://via.placeholder.com/800x250/e84393/FFFFFF?text=Album+1"
                     alt="Album Slideshow" style="width: 100%; border-radius: 10px; max-height: 250px; object-fit: cover;">
                <button class="nav-button nav-left-btn" onclick="moveCarousel('popularAlbumsCarousel', -1)">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <button class="nav-button nav-right-btn" onclick="moveCarousel('popularAlbumsCarousel', 1)">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>

            <!-- Recommended Section -->
            <% if (recommended != null && !recommended.isEmpty()) { %>
            <div class="carousel-container" id="recommendedCarousel">
                <h2 class="section-title">Gợi ý dành cho bạn</h2>
                <button class="nav-button nav-left-btn" onclick="moveCarousel('recommendedCarousel', -1)">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <button class="nav-button nav-right-btn" onclick="moveCarousel('recommendedCarousel', 1)">
                    <i class="fas fa-chevron-right"></i>
                </button>
                <div class="carousel-items">
                    <% for (Songs s : recommended) {%>
                    <div class="card">
                        <img src="<%= s.getCoverImage() != null ? s.getCoverImage() : "https://via.placeholder.com/160/e84393/FFFFFF?text=No+Cover"%>" alt="<%= s.getTitle()%>">
                        <div class="card-title"><%= s.getTitle()%></div>
                        <div class="card-subtitle"><%= s.getArtist()%></div>
                        <a href="${pageContext.request.contextPath}/play?songId=${s.songID}" class="play-button">
                            <i class="fas fa-play"></i>
                        </a>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>

            <!-- Recently Played -->
            <div class="carousel-container" id="recentlyPlayedCarousel">
                <div class="section-header d-flex justify-content-between align-items-center mb-3">
                    <h2 class="section-title">Mới phát gần đây</h2>
                    <c:if test="${empty recentSongs}">
                        <p class="text-muted">Bạn chưa phát bài hát nào gần đây.</p>
                    </c:if>
                    <a href="#" class="text-muted small">Hiện tất cả</a>
                </div>
                <button class="nav-button nav-left-btn" onclick="moveCarousel('recentlyPlayedCarousel', -1)"></button>
                <button class="nav-button nav-right-btn" onclick="moveCarousel('recentlyPlayedCarousel', 1)"></button>
                <div class="carousel-items">
                    <c:forEach var="song" items="${recentSongs}">
                        <div class="card">
                            <img src="${song.coverImage}" alt="${song.title}">
                            <div class="card-title">${song.title}</div>
                            <div class="card-subtitle">${song.artist}</div>
                            <a href="${pageContext.request.contextPath}/play?songId=${song.songID}" class="play-button">
                                <i class="fas fa-play"></i>
                            </a>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <!-- Popular Albums (theo genre, không hiển thị số lượng bài hát) -->
            <div class="carousel-container" id="popularAlbumsCarousel">
                <h2 class="section-title">Thể loại nổi bật</h2>
                <button class="nav-button nav-left-btn" onclick="moveCarousel('popularAlbumsCarousel', -1)">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <button class="nav-button nav-right-btn" onclick="moveCarousel('popularAlbumsCarousel', 1)">
                    <i class="fas fa-chevron-right"></i>
                </button>
                <div class="carousel-items" id="albumScrollSnap">
                    <div class="card">
                        <img src="albumImages/haytraochoanh.jpg" alt="Nhạc trẻ">
                        <div class="card-title">Nhạc trẻ</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('Nhạc trẻ')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <div class="card">
                        <img src="albumImages/lalala.jpg" alt="Pop">
                        <div class="card-title">Pop</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('Pop')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <div class="card">
                        <img src="albumImages/bonghoadepnhat.jpg" alt="Ballad">
                        <div class="card-title">Ballad</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('Ballad')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <div class="card">
                        <img src="albumImages/wn.png" alt="R&B">
                        <div class="card-title">R&B</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('R&B')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <div class="card">
                        <img src="albumImages/trinh.jpg" alt="Pop Ballad">
                        <div class="card-title">Pop Ballad</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('Pop Ballad')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <div class="card">
                        <img src="albumImages/badtrip.jpg" alt="EDM">
                        <div class="card-title">EDM</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('EDM')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <div class="card">
                        <img src="albumImages/louhoang.jpg" alt="Dance-Pop">
                        <div class="card-title">Dance-Pop</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('Dance-Pop')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <div class="card">
                        <img src="albumImages/hongnhan.jpg" alt="Hip-Hop">
                        <div class="card-title">Hip-Hop</div>
                        <button class="play-button" type="button" onclick="selectSongFromGenre('Hip-Hop')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Popular Artists -->
            <div class="carousel-container" id="popularArtistsCarousel">
                <h2 class="section-title">Nghệ sĩ phổ biến</h2>
                <button class="nav-button nav-left-btn" onclick="moveCarousel('popularArtistsCarousel', -1)"></button>
                <button class="nav-button nav-right-btn" onclick="moveCarousel('popularArtistsCarousel', 1)"></button>
                <div class="carousel-items">
                    <%
                        String[][] artists = {
                                {"sonTung", "Sơn Tùng M-TP"},
                                {"Soobin", "SOOBIN"},
                                {"louHoang", "Lou Hoàng"},
                                {"mrSiro", "Mr. Siro"},
                                {"quanAp", "Quân A.P"},
                                {"hieuThuHai", "HIEUTHUHAI"},
                                {"ducPhuc", "Đức Phúc"},
                                {"Jack", "Jack"},
                                {"rptMck", "MCK"}
                        };
                        for (String[] artist : artists) {
                    %>
                    <div class="card">
                        <img src="<%=request.getContextPath()%>/coverImages/<%= artist[0]%>.jpg" alt="<%= artist[1]%>" style="border-radius: 50%;">
                        <div class="card-title"><%= artist[1]%></div>
                        <div class="card-subtitle">Nghệ sĩ</div>
                        <button class="play-button" type="button" onclick="selectSongFromArtist('<%= artist[1] %>')">
                            <i class="fas fa-play"></i>
                        </button>
                    </div>
                    <% }%>
                </div>
            </div>

            <!-- New Songs -->
            <div class="carousel-container" id="newSongsCarousel">
                <h2 class="section-title">Bài hát mới phát hành</h2>
                <button class="nav-button nav-left-btn" onclick="moveCarousel('newSongsCarousel', -1)">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <button class="nav-button nav-right-btn" onclick="moveCarousel('newSongsCarousel', 1)">
                    <i class="fas fa-chevron-right"></i>
                </button>
                <div class="carousel-items">
                    <c:forEach var="s" items="${newSongs}">
                        <div class="card song-item"
                             data-title="${s.title}"
                             data-artist="${s.artist}"
                             data-file="${fn:replace(s.filePath, '/songs/', '')}"
                             data-duration="${s.duration}">
                            <img src="${s.coverImage}" alt="${s.title}">
                            <div class="card-title">${s.title}</div>
                            <div class="card-subtitle">${s.artist}</div>
                            <button class="play-button" type="button" onclick="selectSong(this.parentElement)">
                                <i class="fas fa-play"></i>
                            </button>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </main>

    <!-- Right Sidebar -->
    <aside class="right-sidebar">
        <div class="now-playing-section">
            <div class="now-playing-header">Đang phát</div>
            <img src="https://via.placeholder.com/200/e84393/FFFFFF?text=Now+Playing" alt="Ảnh bìa bài hát đang phát" class="now-playing-cover">
            <div class="now-playing-title">Tên bài hát đang phát</div>
            <div class="now-playing-artist">Tên nghệ sĩ</div>
        </div>
    </aside>
</div>

<!-- Bottom Player -->
<jsp:include page="/WEB-INF/views/layouts/player.jsp" />

<!-- Queue Panel -->
<div id="queueRightPanel" class="queue-right-panel">
    <div class="queue-header">
        <span>Danh sách chờ</span>
        <button onclick="toggleQueueRight()" class="close-btn">×</button>
    </div>
    <div class="queue-content">
        <i class="fas fa-bars queue-icon"></i>
        <h5>Thêm vào danh sách chờ</h5>
        <p>Nhấn vào "Thêm vào danh sách chờ" từ menu của một bài để đưa vào đây</p>
        <button class="find-btn">Tìm nội dung để phát</button>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Hàm phát playlist
    function playPlaylist(playlist, index) {
        if (!playlist || playlist.length === 0) return;
        if (index < 0 || index >= playlist.length) return;
        window.songList = playlist;
        window.currentSongIndex = index;
        window.playedSongFiles = (window.playedSongFiles || new Set());
        // Đánh dấu các bài đã phát trong playlist
        playlist.forEach(s => window.playedSongFiles.add(s.file));
        if (typeof playSongByIndex === 'function') {
            playSongByIndex(index);
            // Gán lại onended để xử lý phát tiếp allSongs nếu hết playlist
            if (window.currentAudio) {
                window.currentAudio.onended = function() {
                    if (window.currentSongIndex + 1 < window.songList.length) {
                        playSongByIndex(window.currentSongIndex + 1);
                    } else {
                        // Đã hết playlist, phát tiếp các bài chưa phát trong allSongs
                        fetchAllSongsAndPlayNext();
                    }
                };
            }
        } else {
            // ... giữ nguyên fallback logic cũ ...
        }
    }

    function fetchAllSongsAndPlayNext() {
        // Lưu lại playlist trước đó và chỉ số bài cuối cùng
        window.previousPlaylist = window.songList;
        window.previousPlaylistLastIndex = window.currentSongIndex;
        // Lấy allSongs từ biến JSP nếu có, hoặc fetch từ backend nếu cần
        let allSongs = window.allSongs;
        if (!allSongs) {
            // Nếu chưa có, fetch từ backend (giả sử backend trả JSON ở /playlist?type=all)
            fetch('<%=request.getContextPath()%>/playlist?type=all')
                .then(res => res.json())
                .then(songs => {
                    window.allSongs = songs;
                    playNextFromAllSongs();
                });
        } else {
            playNextFromAllSongs();
        }
    }

    function playNextFromAllSongs() {
        const played = window.playedSongFiles || new Set();
        const allSongs = window.allSongs || [];
        // Lọc ra các bài chưa phát
        const remaining = allSongs.filter(s => !played.has(s.file || s.filePath));
        if (remaining.length > 0) {
            window.songList = remaining;
            window.currentSongIndex = 0;
            remaining.forEach(s => played.add(s.file || s.filePath));
            if (typeof playSongByIndex === 'function') {
                playSongByIndex(0);
            }
        } else {
            // Không còn bài nào để phát
            window.isPlaying = false;
            if (window.currentAudio) window.currentAudio.pause();
        }
    }

    // Hàm lấy playlist động từ servlet và phát
    function selectSongFromArtist(artistName) {
        fetch('<%=request.getContextPath()%>/playlist?type=artist&name=' + encodeURIComponent(artistName))
            .then(res => res.json())
            .then(playlist => {
                if (playlist && playlist.length > 0) {
                    // Chuyển đổi nếu backend trả về filePath/coverImage thay vì file/cover
                    playlist = playlist.map(s => ({
                        title: s.title,
                        artist: s.artist,
                        file: s.filePath || s.file,
                        cover: s.coverImage || s.cover,
                        duration: s.duration
                    }));
                    playPlaylist(playlist, 0);
                } else {
                    alert("Không tìm thấy bài hát cho nghệ sĩ: " + artistName);
                }
            });
    }
    function selectSongFromGenre(genreName) {
        fetch('<%=request.getContextPath()%>/playlist?type=genre&name=' + encodeURIComponent(genreName))
            .then(res => res.json())
            .then(playlist => {
                if (playlist && playlist.length > 0) {
                    playlist = playlist.map(s => ({
                        title: s.title,
                        artist: s.artist,
                        file: s.filePath || s.file,
                        cover: s.coverImage || s.cover,
                        duration: s.duration
                    }));
                    playPlaylist(playlist, 0);
                } else {
                    alert("Không tìm thấy bài hát cho thể loại: " + genreName);
                }
            });
    }
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds === undefined || seconds === null) return '00:00';
        seconds = Math.floor(seconds);
        const min = Math.floor(seconds / 60);
        const sec = seconds % 60;
        return `${min < 10 ? '0' : ''}${min}:${sec < 10 ? '0' : ''}${sec}`;
    }
    function updateProgress() {
        if (window.currentAudio) {
            const currentTime = Math.floor(window.currentAudio.currentTime) || 0;
            const duration = Math.floor(window.currentAudio.duration) || 0;
            const currentTimeSpan = document.getElementById('current-time');
            const durationSpan = document.getElementById('duration');
            const progressBar = document.getElementById('progress-bar');
            if (currentTimeSpan) currentTimeSpan.textContent = formatTime(currentTime);
            if (durationSpan) durationSpan.textContent = formatTime(duration);
            if (progressBar) {
                progressBar.value = currentTime;
                progressBar.max = duration;
                const percent = duration > 0 ? (currentTime / duration) * 100 : 0;
                progressBar.style.setProperty('--progress', percent + '%');
            }
        }
    }
    function moveCarousel(carouselId, direction) {
        const container = document.getElementById(carouselId);
        if (!container) return;
        const items = container.querySelector(".carousel-items");
        const leftBtn = container.querySelector(".nav-left-btn");
        const rightBtn = container.querySelector(".nav-right-btn");
        const scrollAmount = direction * 200; // Điều chỉnh nếu cần
        if (items) items.scrollLeft += scrollAmount;

        // Cập nhật trạng thái nút
        if (items && leftBtn && rightBtn) {
            const isAtStart = items.scrollLeft === 0;
            const isAtEnd = items.scrollLeft + items.clientWidth >= items.scrollWidth - 1;
            leftBtn.classList.toggle("active", !isAtStart);
            rightBtn.classList.toggle("active", !isAtEnd);
        }
    }
</script>
</body>
</html>