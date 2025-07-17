<%@page import="java.net.URLEncoder"%>
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
            :root {
                --header-height: 70px;
                --player-height: 80px;
            }

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
                background: #121212; /* Updated to match sidebar.jsp */
                color: #fff;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                display: flex;
                flex-direction: column;
            }
           
            /* Main Layout Container */
            .main-container {
                display: flex;
                flex: 1;
                overflow: hidden;
            }

            /* Left Sidebar (from sidebar.jsp) */
            .left-sidebar {
                width: 350px;
                background: #121212;
                display: flex;
                flex-direction: column;
                position: relative;
                transition: width 0.3s;
                height: 100vh;
                z-index: 10;
            }

            .left-sidebar.expanded {
                position: fixed;
                top: var(--header-height);
                left: 0;
                width: 100vw;
                height: calc(100vh - var(--header-height) - var(--player-height));
                z-index: 1000;
                background: #121212;
                overflow-y: auto;
                padding-bottom: var(--player-height);
            }

            .left-sidebar.collapsed {
                width: 72px;
            }

            .sidebar-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 16px;
                border-bottom: 1px solid #282828;
            }

            .sidebar-header .left {
                display: flex;
                align-items: center;
                gap: 8px;
                color: white;
            }

            .sidebar-header button {
                background: #2a2a2a;
                border: none;
                color: white;
                padding: 8px 12px;
                border-radius: 20px;
                cursor: pointer;
                font-size: 14px;
            }

            .library-section {
                flex: 1;
                overflow-y: auto;
                padding: 8px;
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .library-item {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 8px;
                border-radius: 6px;
                cursor: pointer;
                transition: background 0.2s;
            }

            .library-item img {
                width: 48px;
                height: 48px;
                border-radius: 8px;
                object-fit: cover;
            }

            .library-item-info {
                flex: 1;
                min-width: 0;
            }

            .library-item-title {
                font-weight: 600;
                color: #fff;
                font-size: 14px;
            }

            .library-item-subtitle {
                color: #b3b3b3;
                font-size: 12px;
            }

            .left-sidebar.collapsed .library-item-info,
            .left-sidebar.collapsed .sidebar-header .left span,
            .left-sidebar.collapsed .sidebar-header .create-button,
            .left-sidebar.collapsed .toolbar,
            .left-sidebar.collapsed .view-modes {
                display: none !important;
            }

            .left-sidebar .expand-button {
                background: none;
                border: none;
                color: white;
                cursor: pointer;
                margin-left: auto;
            }

            .toolbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 8px 16px;
                border-top: 1px solid #282828;
                border-bottom: 1px solid #282828;
            }

            .toolbar input[type="text"] {
                background: #1e1e1e;
                border: none;
                border-radius: 16px;
                padding: 6px 12px;
                color: white;
                font-size: 14px;
                width: 120px;
            }

            .sort-dropdown {
                position: relative;
            }

            .sort-dropdown button {
                background: #1e1e1e;
                border: none;
                color: #fff;
                padding: 6px 12px;
                border-radius: 16px;
                cursor: pointer;
                font-size: 14px;
            }

            .sort-options {
                position: absolute;
                top: 36px;
                right: 0;
                background: #1e1e1e;
                border: 1px solid #282828;
                border-radius: 8px;
                width: 180px;
                display: none;
                flex-direction: column;
                z-index: 10;
            }

            .sort-options button {
                background: none;
                border: none;
                color: white;
                padding: 10px 16px;
                text-align: left;
                cursor: pointer;
                font-size: 14px;
            }

            .sort-options button:hover,
            .sort-options .active {
                background: #333;
                color: #1db954;
            }

            .view-modes {
                padding: 8px 16px;
                display: flex;
                gap: 8px;
            }

            .view-modes button {
                background: #2a2a2a;
                border: none;
                padding: 6px 12px;
                color: white;
                border-radius: 16px;
                cursor: pointer;
                font-size: 13px;
            }

            .view-modes button.active {
                background: #1db954;
                color: black;
            }

            .library-section.view-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
            }

            .library-section.view-grid .library-item {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }

            .library-section.view-grid .library-item-info {
                margin-top: 8px;
            }

            /* Main Content Area */
            .main-content {
                flex: 1;
                background: #000; /* Black background */
                overflow-y: auto;
                position: relative;
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

            /* Media Player (from player.jsp) */
            .media-player-wrapper {
                position: fixed;
                bottom: 0;
                left: 0;
                width: 100%;
                height: 72px;
                background: #181818;
                border-top: 1px solid #333;
                z-index: 1000;
                display: flex;
                justify-content: center;
                align-items: center;
                box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.5);
            }

            .media-player-container {
                width: 100%;
                max-width: 1400px;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 0 32px;
                box-sizing: border-box;
                background: transparent;
            }

            .media-info {
                display: flex;
                align-items: center;
                gap: 12px;
            }

            .media-thumbnail {
                width: 48px;
                height: 48px;
                border-radius: 8px;
                object-fit: cover;
            }

            .media-details h3 {
                color: #ffffff;
                margin: 0;
                font-size: 14px;
                font-weight: 600;
            }

            .media-details p {
                color: #b3b3b3;
                margin: 0;
                font-size: 12px;
            }

            .media-controls {
                display: flex;
                align-items: center;
                gap: 16px;
            }

            .control-btn {
                background: none;
                border: none;
                color: #ffffff;
                font-size: 18px;
                cursor: pointer;
                padding: 6px;
                border-radius: 50%;
                transition: all 0.3s ease;
            }

            .control-btn:hover {
                background: rgba(255, 255, 255, 0.1);
                transform: scale(1.1);
            }

            .play-btn {
                background: #1db954;
                font-size: 20px;
                width: 48px;
                height: 48px;
            }

            .play-btn:hover {
                background: #1ed760;
                transform: scale(1.05);
            }

            .progress-container {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 4px;
                width: 100%;
                max-width: 512px;
                margin: 0 16px;
            }

            .progress-bar {
                width: 100%;
                height: 6px;
                max-width: 512px;
                background: #404040;
                border-radius: 3px;
                position: relative;
                cursor: pointer;
                display: flex;
                flex-direction: column;
                justify-content: center;
                text-align: center;
                line-height: 24px;
                margin-bottom: 0;
            }

            .progress-fill {
                height: 100%;
                background: #b342f5;
                border-radius: 3px;
                width: 0%;
                transition: width 0.1s ease;
            }

            .progress-bar::after {
                content: '';
                position: absolute;
                top: 50%;
                transform: translateY(-50%);
                right: -6px;
                width: 12px;
                height: 12px;
                background: white;
                border-radius: 50%;
            }

            .time-display {
                display: flex;
                justify-content: space-between;
                width: 100%;
                max-width: 512px;
                font-size: 12px;
                color: #b3b3b3;
                line-height: 18px;
                margin: 0;
                padding: 0 10px;
            }

            .bottom-controls {
                display: flex;
                align-items: center;
                gap: 16px;
            }

            .volume-control {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .volume-slider {
                width: 64px;
                height: 4px;
                background: #404040;
                border-radius: 2px;
                outline: none;
                cursor: pointer;
            }

            .volume-slider::-webkit-slider-thumb {
                appearance: none;
                width: 12px;
                height: 12px;
                background: white;
                border-radius: 50%;
                margin-top: -4px;
            }

            .icon {
                width: 20px;
                height: 20px;
                fill: currentColor;
            }

            .hidden {
                display: none;
            }

            .queue-right-panel {
                display: none;
                position: fixed;
                top: 0;
                right: 0;
                height: 100vh;
                width: 25vw;
                min-width: 300px;
                max-width: 400px;
                background: #1e1e1e;
                color: white;
                padding: 16px;
                z-index: 9999;
                flex-direction: column;
                box-shadow: -5px 0 15px #e84393;
                overflow-y: auto;
            }

            .queue-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                font-weight: bold;
                font-size: 16px;
                color: #ff40b0;
                margin-bottom: 25px;
            }

            .queue-content h5 {
                color: #ff40b0;
                font-size: 20px;
                font-weight: bold;
                margin-bottom: 8px;
                text-align: center;
            }

            .queue-content p {
                color: #bbb;
                font-size: 13px;
                margin-bottom: 20px;
                text-align: center;
            }

            .queue-content button {
                background-color: #ff40b0;
                border: none;
                padding: 8px 16px;
                border-radius: 18px;
                color: white;
                cursor: pointer;
                font-weight: bold;
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

                .left-sidebar {
                    width: 100vw !important;
                    height: auto;
                    min-height: 100vh;
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
            <!-- Left Sidebar (from sidebar.jsp) -->
            <aside class="left-sidebar" id="sidebar">
                <div class="sidebar-header">
                    <div class="left">
                        <button onclick="toggleSidebar()" title="Thu gọn Thư viện">
                            <i class="fas fa-angle-double-left"></i>
                        </button>
                        <span>Thư viện</span>
                    </div>
                    <div class="right">
                        <button class="create-button" onclick="openCreatePlaylistModal()">
                            <i class="fas fa-plus"></i> Tạo
                        </button>
                        <button class="expand-button" title="Phóng to giao diện">
                            <i class="fas fa-expand"></i>
                        </button>
                    </div>
                </div>

                <div class="toolbar">
                    <input type="text" placeholder="Tìm kiếm..." />
                    <div class="sort-dropdown">
                        <button onclick="toggleSortOptions()">Sắp xếp theo</button>
                        <div class="sort-options" id="sortOptions">
                            <button class="active">Gần đây ✓</button>
                            <button>Mới thêm gần đây</button>
                            <button>Thứ tự chữ cái</button>
                            <button>Người sáng tạo</button>
                        </div>
                    </div>
                </div>

                <div class="view-modes">
                    <button class="active" onclick="setViewMode('list')">Danh sách</button>
                    <button onclick="setViewMode('grid')">Lưới</button>
                </div>

                <!-- Listening History Section -->
                <c:if test="${not empty listeningHistory}">
                    <div class="library-section" id="librarySection">
                        <h4 style="margin-left: 16px;">🕘 Đã nghe gần đây</h4>
                        <c:forEach var="his" items="${listeningHistory}">
                            <div class="library-item"
                                 onclick="playSong(
                                     '${pageContext.request.contextPath}/play?file=${his.song.filePath}',
                                     '${his.song.title}',
                                     '${his.song.artist}',
                                     '${pageContext.request.contextPath}/songImages/${his.song.title}.jpg',
                                     this)">
                                <img src="${pageContext.request.contextPath}/songImages/${his.song.title}.jpg"
                                     onerror="this.src='https://via.placeholder.com/48x48/333333/ffffff?text=♪'" alt="cover"/>
                                <div class="library-item-info">
                                    <div class="library-item-title">${his.song.title}</div>
                                    <div class="library-item-subtitle">${his.song.artist}</div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </aside>

            <!-- Main Content -->
            <main class="main-content">
                <div class="content-body">
                    <!-- Slideshow -->
                    <%
                        String[][] slide = {
                            {"haytraochoanh.jpg", "Hãy Trao Cho Anh", "Sơn Tùng M-TP"},
                            {"TRINH.jpg", "Trình", "HIEUTHUHAI"},
                            {"wn.png", "2022", "WN"},
                            {"badtrip.jpg", "Badtrip", "MCK"},
                            {"bonghoadepnhat.jpg", "Bông hoa đẹp nhất", "Quân A.P"},
                            {"hongnhan.jpg", "Hồng nhan", "Jack"},
                            {"lalala.jpg", "Lalala", "SOOBIN"},
                            {"louhoang.jpg", "Yêu em dại khờ", "Lou Hoàng"}
                        };
                    %>
                    <div id="slideshow" style="width: 100%; margin-bottom: 30px; position: relative;">
                        <img id="slideImage"
                             src="albumImages/<%= slide[0][0] %>"
                             onerror="this.src='albumImages/default.jpg'"
                             alt="Album Slideshow"
                             style="width: 100%; height: 250px; object-fit: cover; object-position: center; border-radius: 10px; transition: opacity 0.5s ease;">
                        <button class="nav-button nav-left-btn" onclick="prevSlide()" 
                                style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); background-color: rgba(0,0,0,0.5); color: white; border: none; padding: 10px; border-radius: 50%;">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <button class="nav-button nav-right-btn" onclick="nextSlide()" 
                                style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); background-color: rgba(0,0,0,0.5); color: white; border: none; padding: 10px; border-radius: 50%;">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                    </div>

                    <!-- Popular Albums -->
                    <div class="carousel-container" id="popularAlbumsCarousel">
                        <h2 class="section-title">Bài hát được mọi người yêu thích</h2>
                        <button class="nav-button nav-left-btn" onclick="moveCarousel('popularAlbumsCarousel', -1)">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <button class="nav-button nav-right-btn" onclick="moveCarousel('popularAlbumsCarousel', 1)">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                        <div class="carousel-items" id="albumScrollSnap">
                            <%
                                String[][] albums = {
                                    {"haytraochoanh.jpg", "Hãy Trao Cho Anh", "Sơn Tùng M-TP"},
                                    {"trinh.jpg", "Trình", "HIEUTHUHAI"},
                                    {"wn.png", "2022", "WN"},
                                    {"bonghoadepnhat.jpg", "Bông hoa đẹp nhất", "Quân A.P"},
                                    {"hongnhan.jpg", "Hồng nhan", "Jack"},
                                    {"lalala.jpg", "Lalala", "SOOBIN"},
                                    {"louhoang.jpg", "Yêu em dại khờ", "Lou Hoàng"}
                                };
                                for (String[] album : albums) {
                                    String defaultSongTitle = album[1];
                            %>
                            <div class="card">
                                <a href="${pageContext.request.contextPath}/hot-trend?name=<%= URLEncoder.encode(album[1], "UTF-8") %>&cover=<%= URLEncoder.encode(album[0], "UTF-8") %>">
                                    <img src="albumImages/<%= album[0] %>" alt="<%= album[1] %>" onerror="this.src='albumImages/default.jpg';">
                                </a>
                                <div class="card-title"><%= album[1] %></div>
                                <div class="card-subtitle"><%= album[2] %></div>
                                <button class="play-button" onclick="playFirstSong('<%= URLEncoder.encode(defaultSongTitle, "UTF-8") %>', '<%= URLEncoder.encode(album[1], "UTF-8") %>')">
                                    <i class="fas fa-play"></i>
                                </button>
                            </div>
                            <% } %>
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
                                <a href="<%=request.getContextPath()%>/artistsongs?artist=<%= artist[1] %>">
                                    <img src="<%=request.getContextPath()%>/coverImages/<%= artist[0] %>.jpg"
                                         alt="<%= artist[1] %>" style="border-radius: 50%;">
                                </a>
                                <div class="card-title"><%= artist[1]%></div>
                                <div class="card-subtitle">Nghệ sĩ</div>
                                <a href="javascript:void(0);" class="play-button"
                                   onclick="playArtist('<%= artist[1] %>')">
                                    <i class="fas fa-play"></i>
                                </a>
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
                                <div class="card">
                                    <a href="${pageContext.request.contextPath}/songDetail?title=${fn:escapeXml(s.title)}">
                                        <img src="${s.coverImage}" alt="${s.title}">
                                    </a>
                                    <div class="card-title">
                                        <a href="${pageContext.request.contextPath}/songDetail?title=${fn:escapeXml(s.title)}">${s.title}</a>
                                    </div>
                                    <div class="card-subtitle">${s.artist}</div>
                                    <a href="${pageContext.request.contextPath}/play?file=${fn:replace(s.filePath, ' ', '%20')}" class="play-button">
                                        <i class="fas fa-play"></i>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </main>


        <!-- Media Player (from player.jsp) -->
        <div class="media-player-wrapper">
            <div class="media-player-container">
                <!-- Media Info -->
                <div class="media-info">
                    <img src="https://via.placeholder.com/60x60/333333/ffffff?text=♪"
                         alt="Media thumbnail" class="media-thumbnail" id="mediaThumbnail">
                    <div class="media-details">
                        <h3 id="mediaTitle">Chưa có bài hát</h3>
                        <p id="mediaArtist">Không rõ nghệ sĩ</p>
                    </div>
                </div>

                <!-- Audio -->
                <audio id="audioPlayer" preload="metadata">
                    <source src="${not empty mediaInfo.audioUrl ? mediaInfo.audioUrl : ''}" type="audio/mpeg">
                    Your browser does not support the audio element.
                </audio>

                <!-- Controls -->
                <div class="media-controls">
                    <button class="control-btn" id="shuffleBtn" title="Shuffle">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M17 3L22.25 7.5L17 12V9H13.5L11.83 7.33L13.5 5.67H17V3ZM17 15V12L22.25 16.5L17 21V18H13.5L6.5 11L8.17 9.33L13.5 15H17ZM2 7.5L6.5 12L2 16.5V7.5Z"/></svg>
                    </button>
                    <button class="control-btn" id="prevBtn" title="Previous">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M6 6H8V18H6V6ZM9.5 12L18 6V18L9.5 12Z"/></svg>
                    </button>
                    <button class="control-btn play-btn" id="playBtn" title="Play/Pause">
                        <svg class="icon" id="playIcon" viewBox="0 0 24 24"><path d="M8 5V19L19 12L8 5Z"/></svg>
                        <svg class="icon hidden" id="pauseIcon" viewBox="0 0 24 24"><path d="M6 4H10V20H6V4ZM14 4H18V20H14V4Z"/></svg>
                    </button>
                    <button class="control-btn" id="nextBtn" title="Next">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M16 18H18V6H16V18ZM6 6V18L14.5 12L6 6Z"/></svg>
                    </button>
                    <button class="control-btn" id="repeatBtn" title="Repeat">
                        <svg class="icon" viewBox="0 0 24 24"><path d="M7 7H17V10L21 6L17 2V5H5V11H7V7ZM17 17H7V14L3 18L7 22V19H19V13H17V17Z"/></svg>
                    </button>
                </div>

                <!-- Progress Bar -->
                <div class="progress-container">
                    <div class="progress-bar" id="progressBar">
                        <div class="progress-fill" id="progressFill"></div>
                    </div>
                    <div class="time-display">
                        <span id="currentTime">0:00</span>
                        <span id="totalTime">-:--</span>
                    </div>
                </div>

                <!-- Bottom Controls -->
                <div class="bottom-controls">
                    <button class="control-btn" id="queueBtn" title="Queue">
                        <i class="fas fa-bars" style="font-size: 24px;"></i>
                    </button>
                </div>

                <div class="volume-control">
                    <button class="control-btn" id="volumeBtn" title="Volume">
                        <svg class="icon" id="volumeIcon" viewBox="0 0 24 24"><path d="M14,3.23V5.29C16.89,6.15 19,8.83 19,12C19,15.17 16.89,17.85 14,18.71V20.77C18.01,19.86 21,16.28 21,12C21,7.72 18.01,4.14 14,3.23M16.5,12C16.5,10.23 15.5,8.71 14,7.97V16C15.5,15.29 16.5,13.76 16.5,12M3,9V15H7L12,20V4L7,9H3Z"/></svg>
                    </button>
                    <input type="range" class="volume-slider" id="volumeSlider" min="0" max="100" value="50">
                </div>

                <!-- Queue Panel -->
                <div id="queueRightPanel" class="queue-right-panel">
                    <div class="queue-header">
                        <span>Danh sách chờ</span>
                        <button onclick="toggleQueueRight()" style="background:none;border:none;font-size:20px;color:#ff40b0;cursor:pointer;">×</button>
                    </div>
                    <div class="queue-content">
                        <i class="fas fa-bars" style="font-size:28px;color:#ff40b0;margin-bottom:8px;"></i>
                        <h5 style="color:#ff40b0;">Thêm vào danh sách chờ</h5>
                        <p style="color:#bbb;font-size:13px;">Nhấn vào "Thêm vào danh sách chờ" từ menu của một bài để đưa vào đây</p>
                        <button style="background-color:#ff40b0;border:none;padding:8px 16px;border-radius:18px;color:white;cursor:pointer;font-weight:bold;">Tìm nội dung để phát</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Sidebar Functions (from sidebar.jsp)
            function toggleSidebar() {
                const sidebar = document.getElementById("sidebar");
                sidebar.classList.toggle("collapsed");
            }

            function openCreatePlaylistModal() {
                alert("Tính năng tạo playlist sẽ được tích hợp tại đây!");
            }

            function toggleSortOptions() {
                const options = document.getElementById("sortOptions");
                options.style.display = options.style.display === "flex" ? "none" : "flex";
            }

            function setViewMode(mode) {
                const section = document.getElementById("librarySection");
                const buttons = document.querySelectorAll('.view-modes button');

                buttons.forEach(btn => btn.classList.remove("active"));
                document.querySelector(`.view-modes button[onclick*="setViewMode('${mode}')"]`).classList.add("active");

                section.classList.remove("view-list", "view-grid");
                section.classList.add(`view-${mode}`);
            }

            document.querySelector(".expand-button").addEventListener("click", () => {
                const sidebar = document.getElementById("sidebar");
                sidebar.classList.toggle("expanded");
            });

            document.querySelectorAll("#sortOptions button").forEach(button => {
                button.addEventListener("click", () => {
                    document.querySelectorAll("#sortOptions button").forEach(btn => btn.classList.remove("active"));
                    button.classList.add("active");
                    document.querySelector(".sort-dropdown button").textContent = button.textContent;
                    toggleSortOptions();
                });
            });

            // Slideshow
            const slideshowImages = [
                <% for (int i = 0; i < slide.length; i++) { %>
                    "albumImages/<%= slide[i][0] %>"<%= (i < slide.length - 1) ? "," : "" %>
                <% } %>
            ];

            let currentSlide = 0;
            const slideImage = document.getElementById("slideImage");

            function showSlide(index) {
                currentSlide = (index + slideshowImages.length) % slideshowImages.length;
                slideImage.style.opacity = 0;

                setTimeout(() => {
                    slideImage.src = slideshowImages[currentSlide];
                    slideImage.style.opacity = 1;
                }, 300);
            }

            function nextSlide() {
                showSlide(currentSlide + 1);
            }

            function prevSlide() {
                showSlide(currentSlide - 1);
            }

            // Tự động lướt ảnh mỗi 3 giây
            setInterval(nextSlide, 3000);

            // Carousel Navigation
            function moveCarousel(carouselId, direction) {
                const container = document.getElementById(carouselId);
                const items = container.querySelector(".carousel-items");
                const leftBtn = container.querySelector(".nav-left-btn");
                const rightBtn = container.querySelector(".nav-right-btn");
                const scrollAmount = direction * 200; // Adjust scroll amount as needed
                items.scrollLeft += scrollAmount;

                // Update button visibility
                requestAnimationFrame(() => {
                    const isAtStart = items.scrollLeft === 0;
                    const isAtEnd = items.scrollLeft + items.clientWidth >= items.scrollWidth - 1;
                    leftBtn.classList.toggle("active", !isAtStart);
                    rightBtn.classList.toggle("active", !isAtEnd);
                });
            }

            // Initialize button states for all carousels
            document.querySelectorAll(".carousel-container").forEach(container => {
                const items = container.querySelector(".carousel-items");
                const leftBtn = container.querySelector(".nav-left-btn");
                const rightBtn = container.querySelector(".nav-right-btn");
                const isAtStart = items.scrollLeft === 0;
                const isAtEnd = items.scrollLeft + items.clientWidth >= items.scrollWidth - 1;
                leftBtn.classList.toggle("active", !isAtStart);
                rightBtn.classList.toggle("active", !isAtEnd);

                items.addEventListener("scroll", () => {
                    const isAtStart = items.scrollLeft === 0;
                    const isAtEnd = items.scrollLeft + items.clientWidth >= items.scrollWidth - 1;
                    leftBtn.classList.toggle("active", !isAtStart);
                    rightBtn.classList.toggle("active", !isAtEnd);
                });
            });

            // Player Functions (from player.jsp)
            function toggleQueueRight() {
                const panel = document.getElementById('queueRightPanel');
                panel.style.display = panel.style.display === 'none' ? 'flex' : 'none';
            }

            function playSong(audioUrl, title, artist) {
                const audio = document.getElementById('audioPlayer');
                const titleEl = document.getElementById('mediaTitle');
                const artistEl = document.getElementById('mediaArtist');
                const thumbnailEl = document.getElementById('mediaThumbnail');

                // Set new audio source
                audio.src = audioUrl;
                audio.play();

                // Update song information
                titleEl.textContent = title || "Chưa có bài hát";
                artistEl.textContent = artist || "Không rõ nghệ sĩ";

                // Handle image from song title
                const imgName = toImageFileName(title);
                thumbnailEl.src = '<%= request.getContextPath() %>/songImages/' + imgName;
                thumbnailEl.onerror = () => {
                    thumbnailEl.src = '<%= request.getContextPath() %>/songImages/default.jpg';
                };
            }

            function toImageFileName(title) {
                if (!title) return 'default.jpg';
                const normalized = title.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/g, "d").replace(/Đ/g, "D");
                const words = normalized.split(/[^a-zA-Z0-9]+/);
                let pascalCase = "";
                for (let word of words) {
                    if (word) pascalCase += word[0].toUpperCase() + word.slice(1);
                }
                return pascalCase + ".jpg";
            }

            document.addEventListener('DOMContentLoaded', function () {
                const audio = document.getElementById('audioPlayer');
                const playBtn = document.getElementById('playBtn');
                const playIcon = document.getElementById('playIcon');
                const pauseIcon = document.getElementById('pauseIcon');
                const progressBar = document.getElementById('progressBar');
                const progressFill = document.getElementById('progressFill');
                const currentTimeSpan = document.getElementById('currentTime');
                const totalTimeSpan = document.getElementById('totalTime');
                const volumeSlider = document.getElementById('volumeSlider');
                const volumeBtn = document.getElementById('volumeBtn');
                const queueBtn = document.getElementById('queueBtn');

                audio.volume = 0.5;
                let isPlaying = false;
                let isDragging = false;

                function formatTime(seconds) {
                    const mins = Math.floor(seconds / 60);
                    const secs = Math.floor(seconds % 60);
                    return mins + ':' + (secs < 10 ? '0' : '') + secs;
                }

                playBtn.addEventListener('click', function () {
                    if (isPlaying) {
                        audio.pause();
                    } else {
                        audio.play();
                    }
                });

                audio.addEventListener('play', function () {
                    isPlaying = true;
                    playIcon.classList.add('hidden');
                    pauseIcon.classList.remove('hidden');
                });

                audio.addEventListener('pause', function () {
                    isPlaying = false;
                    playIcon.classList.remove('hidden');
                    pauseIcon.classList.add('hidden');
                });

                audio.addEventListener('loadedmetadata', function () {
                    totalTimeSpan.textContent = formatTime(audio.duration);
                });

                audio.addEventListener('timeupdate', function () {
                    if (!isDragging) {
                        const progress = (audio.currentTime / audio.duration) * 100;
                        progressFill.style.width = progress + '%';
                        currentTimeSpan.textContent = formatTime(audio.currentTime);
                    }
                });

                progressBar.addEventListener('click', function (e) {
                    const rect = progressBar.getBoundingClientRect();
                    const percent = (e.clientX - rect.left) / rect.width;
                    audio.currentTime = percent * audio.duration;
                });

                volumeSlider.addEventListener('input', function () {
                    audio.volume = this.value / 100;
                });

                volumeBtn.addEventListener('click', function () {
                    if (audio.volume > 0) {
                        audio.volume = 0;
                        volumeSlider.value = 0;
                    } else {
                        audio.volume = 0.5;
                        volumeSlider.value = 50;
                    }
                });

                queueBtn.addEventListener('click', toggleQueueRight);

                document.addEventListener('keydown', function (e) {
                    if (e.code === 'Space' && e.target.tagName !== 'INPUT') {
                        e.preventDefault();
                        playBtn.click();
                    }
                });

                document.getElementById('prevBtn').addEventListener('click', function () {
                    console.log('Previous track');
                });

                document.getElementById('nextBtn').addEventListener('click', function () {
                    console.log('Next track');
                });
            });
        </script>
    </body>
</html>