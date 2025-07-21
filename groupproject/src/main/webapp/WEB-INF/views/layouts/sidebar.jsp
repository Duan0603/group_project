<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thư viện người dùng</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/library.css">
        <style>
            :root {
                --header-height: 70px;
                --player-height: 80px;
            }
            body {
                margin: 0;
                background: #121212;
                color: white;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
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
            .library-item:hover {
                background: #2a2a2a;
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
            @media screen and (max-width: 768px) {
                .left-sidebar {
                    width: 100vw !important;
                    height: auto;
                    min-height: 100vh;
                }
            }
        </style>
    </head>
    <body>
        <%
            boolean isPremium = false;
            model.User user = (model.User) session.getAttribute("user");
            if (user != null && user.isPremium()) isPremium = true;
        %>
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

            <div id="createPlaylistForm" style="padding: 16px; display: none;">
                <input type="text" id="newPlaylistInput" placeholder="Nhập tên playlist..." 
                       style="width: 100%; padding: 6px; border-radius: 6px; margin-bottom: 8px;">
                <button onclick="createPlaylist()" 
                        style="width: 100%; padding: 6px; background: #1db954; color: black; border: none; border-radius: 6px; font-weight: bold;">
                    + Tạo mới
                </button>
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

            <!-- Danh sách playlist -->
            <div class="library-section" id="userPlaylistsSidebar">
                <h4 style="margin-left: 16px;">🎵 Playlist của bạn</h4>
                <c:forEach var="playlist" items="${userPlaylists}">
                    <a href="${pageContext.request.contextPath}/playlistDetail?playlistId=${playlist.playlistID}">
                        ${playlist.name}
                    </a>
                </c:forEach>
            </div>
        </aside>

        <!-- Premium Popup -->
        <div id="premiumPopup" style="display:none;position:fixed;bottom:100px;right:40px;z-index:99999;background:#fff;color:#222;padding:18px 28px;border-radius:12px;box-shadow:0 4px 24px rgba(0,0,0,0.18);font-size:16px;font-weight:500;align-items:center;gap:12px;min-width:260px;max-width:350px;">
            <span style="color:#e84393;font-size:22px;margin-right:10px;vertical-align:middle;"><i class="fas fa-crown"></i></span>
            Bạn cần <a href="${pageContext.request.contextPath}/payos-premium" style="color:#e84393;font-weight:bold;text-decoration:underline;margin:0 4px;">đăng ký Premium</a> để sử dụng tính năng này!
            <button onclick="document.getElementById('premiumPopup').style.display='none'" style="background:none;border:none;color:#e84393;font-size:18px;float:right;margin-left:10px;cursor:pointer;">&times;</button>
        </div>

        <script>
    const contextPath = '${pageContext.request.contextPath}';
    const IS_PREMIUM = <%= isPremium %>;

    function openCreatePlaylistModal() {
        if (!IS_PREMIUM) {
            showPremiumPopup();
            return;
        }
        const form = document.getElementById("createPlaylistForm");
        form.style.display = form.style.display === "none" ? "block" : "none";
        document.getElementById("newPlaylistInput").focus();
    }

    function createPlaylist() {
        const name = document.getElementById("newPlaylistInput").value.trim();
        if (!name) {
            alert("Vui lòng nhập tên playlist!");
            return;
        }

        fetch(contextPath + "/playlist", {
            method: "POST",
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: new URLSearchParams({
                action: "createPlaylist",
                name: name,
                description: "",
                isPublic: true
            })
        })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        alert("🎉 Playlist đã tạo!");
                        document.getElementById("newPlaylistInput").value = "";
                        document.getElementById("createPlaylistForm").style.display = "none";
                        // Làm mới danh sách playlist
                        refreshPlaylistList();
                    } else {
                        alert("❌ Tạo playlist thất bại: " + data.message);
                    }
                })
                .catch(err => {
                    console.error("Lỗi khi tạo playlist:", err);
                    alert("❌ Lỗi hệ thống khi tạo playlist.");
                });
    }

    function refreshPlaylistList() {
        const section = document.getElementById("userPlaylistsSidebar");
        // Giữ tiêu đề và xóa các playlist cũ
        section.innerHTML = '<h4 style="margin-left: 16px;">🎵 Playlist của bạn</h4>';

        // Lấy danh sách playlist từ server
        fetch(contextPath + "/playlist?action=getUserPlaylists")
                .then(res => res.json())
                .then(playlists => {
                    playlists.forEach(pl => {
                        const div = document.createElement("div");
                        div.className = "library-item";
div.setAttribute("data-playlist-id", pl.playlistID);
div.onclick = () => {
     window.location.href = `${contextPath}/playlist?action=viewPlaylistDetail&playlistId=${pl.playlistID}`;
};
                                                    div.innerHTML = `
    <img src="https://via.placeholder.com/48x48/333333/ffffff?text=♪" alt="cover"/>
    <div class="library-item-info">
        <div class="library-item-title">` + pl.name + `</div>
        <div class="library-item-subtitle">` + (pl.description || 'Playlist của bạn') + `</div>
    </div>
`;
                                                    section.appendChild(div);
                                                });
                                            })
                                            .catch(err => {
                                                console.error("Lỗi khi tải playlist:", err);
                                                section.innerHTML += '<div style="color: red; padding: 8px;">Không thể tải playlist</div>';
                                            });
                                }

                                function toggleSidebar() {
                                    const sidebar = document.getElementById("sidebar");
                                    sidebar.classList.toggle("collapsed");
                                }

                                function toggleSortOptions() {
                                    const options = document.getElementById("sortOptions");
                                    options.style.display = options.style.display === "flex" ? "none" : "flex";
                                }

                                function setViewMode(mode) {
                                    const section = document.getElementById("userPlaylistsSidebar");
                                    const buttons = document.querySelectorAll('.view-modes button');
                                    buttons.forEach(btn => btn.classList.remove("active"));
                                    document.querySelector(`.view-modes button[onclick*="setViewMode('${mode}')"]`).classList.add("active");
                                    section.classList.remove("view-list", "view-grid");
                                    section.classList.add(`view-${mode}`);
                                }

                                function showPremiumPopup() {
                                    var popup = document.getElementById('premiumPopup');
                                    if (popup) {
                                        popup.style.display = 'flex';
                                        setTimeout(function(){ popup.style.display = 'none'; }, 3500);
                                    }
                                }
        </script>
    </body>
</html>
