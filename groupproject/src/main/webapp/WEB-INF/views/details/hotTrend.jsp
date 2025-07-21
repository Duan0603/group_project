<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.Songs" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.SongDAO" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.google.gson.Gson" %>

<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<%
    List<Songs> songs = (List<Songs>) request.getAttribute("songs");
    String albumName = (String) request.getAttribute("albumName");
    String coverImage = (String) request.getAttribute("coverImage");
    Songs songToPlay = (Songs) request.getAttribute("songToPlay");
    int totalDuration = (request.getAttribute("totalDuration") != null) ? (int) request.getAttribute("totalDuration") : 0;

    if (songs == null) {
        songs = new ArrayList<>();
    }
    if (songToPlay == null && !songs.isEmpty()) {
        songToPlay = songs.get(0);
    }
    String encodedFirstSongPath = (songToPlay != null && songToPlay.getFilePath() != null)
            ? URLEncoder.encode(songToPlay.getFilePath(), "UTF-8")
            : "";
    if (albumName == null) {
        albumName = "Không xác định";
    }
    if (coverImage == null) {
        coverImage = "default.jpg";
    }

    int hours = totalDuration / 3600;
    int minutes = (totalDuration % 3600) / 60;
    int seconds = totalDuration % 60;
    String formattedDuration = String.format("%d:%02d:%02d", hours, minutes, seconds);

    Set<String> genreSet = new LinkedHashSet<>();
    for (Songs s : songs) {
        if (s.getGenre() != null) {
            genreSet.add(s.getGenre());
        }
    }
    String genresText = String.join(", ", genreSet);
    String firstSongImage = "https://via.placeholder.com/60x60/333333/ffffff?text=♪";
    if (songToPlay != null && songToPlay.getTitle() != null) {
        String fileName = dao.SongDAO.toImageFileName(songToPlay.getTitle());
        firstSongImage = "songImages/" + fileName;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title><%= albumName%></title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body {
                background: #121212;
                color: white;
                font-family: 'Segoe UI', sans-serif;
                margin: 0;
            }
            .main-area {
                display: flex;
                height: 100vh;
            }
            .sidebar-area {
                width: 320px;
                background: #1e1e1e;
            }
            .content-area {
                flex: 1;
                padding: 24px 32px 24px 48px;
                overflow-y: auto;
            }
            .artist-header {
                background: #1e1e1e;
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 4px 20px rgba(255, 255, 255, 0.05);
                margin-bottom: 32px;
            }
            .verified {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 12px;
                color: #fff;
                font-size: 14px;
            }
            .artist-name {
                font-size: 64px;
                margin: 8px 0;
                font-weight: bold;
            }
            .song-info {
                font-size: 16px;
            }
            .song-list {
                margin-top: 32px;
            }
            .song-item {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 12px 16px;
                margin-bottom: 12px;
                background: #1e1e1e;
                border-radius: 8px;
                cursor: pointer;
                transition: background 0.3s ease, transform 0.2s ease, box-shadow 0.2s ease;
            }
            .song-item:hover {
                background: #2a2a2a;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255, 255, 255, 0.05);
            }
            .song-item.active {
                background: #2e2e2e;
                border: 1px solid #e84393;
                transform: scale(1.02);
                box-shadow: 0 0 10px #e84393;
            }
            .song-item .left {
                display: flex;
                align-items: center;
                gap: 12px;
                flex: 1;
            }
            .song-item .left img {
                width: 48px;
                height: 48px;
                border-radius: 6px;
                object-fit: cover;
            }
            .song-item .left .title {
                font-weight: 500;
            }
            .song-item .genre {
                flex: 1;
                text-align: center;
                font-size: 14px;
                color: #aaa;
            }
            .song-item .right {
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .song-item .right .duration {
                width: 60px;
                text-align: right;
            }
            .song-item .right .add-icon {
                color: #e84393;
                font-size: 18px;
            }
            
.playlist-popup {
    width: 260px;
    background: #2c2c2c;
    border-radius: 10px;
    padding: 12px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.5);
    z-index: 9999;
    position: absolute;
}

.playlist-header {
    font-weight: bold;
    margin-bottom: 8px;
}

.playlist-search {
    width: 100%;
    padding: 6px 8px;
    border: none;
    border-radius: 6px;
    background-color: #2a2a2a;
    color: white;
    outline: none;
    margin-bottom: 8px;
}

.playlist-create {
    color: #1DB954;
    font-weight: bold;
    margin-top: 8px;
    cursor: pointer;
}

@keyframes fadeIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
}
        </style>
    </head>
    <body>
        <div class="main-area">
            <div class="sidebar-area">
                <jsp:include page="/WEB-INF/views/layouts/sidebar.jsp" />
            </div>
            <div class="content-area">
                <div class="artist-header">
                    <div class="verified"><span>Danh sách phát công khai</span></div>
                    <h1 class="artist-name">Bài hát được mọi người yêu thích</h1>
                    <p class="song-info"><%= songs.size()%> bài hát · Tổng thời lượng: <%= formattedDuration%></p>
                    <div class="controls" style="display: flex; gap: 16px; align-items: center; margin-top: 24px;">
                        <button onclick="playFirstSong()" style="background: #1DB954; border: none; border-radius: 50%; width: 56px; height: 56px; display: flex; justify-content: center; align-items: center; cursor: pointer;">
                            <i class="fa fa-play" style="color: white; font-size: 24px;"></i>
                        </button>
                        <div style="width: 48px; height: 48px; border-radius: 8px; overflow: hidden; border: 2px solid #999;">
                            <img id="firstSongImage" src="<%= firstSongImage%>" alt="Ảnh bài hát" style="width: 100%; height: 100%; object-fit: cover;">
                        </div>
                        <button onclick="toggleCreatePlaylist()" style="background: transparent; border: 2px solid #aaa; color: white; border-radius: 50%; width: 40px; height: 40px; display: flex; justify-content: center; align-items: center; font-size: 20px; cursor: pointer;">+</button>
                    </div>
                </div>
                <div class="song-list">
                    <% int i = 1;
                for (Songs s : songs) {
                    int h = s.getDuration() / 3600;
                    int m = (s.getDuration() % 3600) / 60;
                    int sec = s.getDuration() % 60;
                    String encodedPath = URLEncoder.encode((s.getFilePath() != null ? s.getFilePath() : ""), "UTF-8");
                    String safeTitle = s.getTitle().replace("'", "\\'").replace("\"", "\\\"");
                    String safeArtist = (s.getArtist() != null ? s.getArtist().replace("'", "\\'").replace("\"", "\\\"") : "Không rõ nghệ sĩ");
                    String imageFileName = dao.SongDAO.toImageFileName(s.getTitle());
                    %>
                    <div class="song-item"
                         data-song-id="<%= s.getSongID() %>"
                         data-url="<%= request.getContextPath() %>/play?file=<%= URLEncoder.encode(s.getFilePath(), "UTF-8") %>&songId=<%= s.getSongID() %>"
                         data-title="<%= s.getTitle().replace("\"", "&quot;") %>"
                         data-artist="<%= s.getArtist() != null ? s.getArtist().replace("\"", "&quot;") : "Không rõ nghệ sĩ" %>"
                         onclick="playAndSaveHistory(this.getAttribute('data-url'), this.getAttribute('data-title'), this.getAttribute('data-artist'), this.getAttribute('data-song-id'))">
                        <div class="left">
                            <span style="width:24px;text-align:right;"><%= i++%></span>
                            <img src="songImages/<%= imageFileName %>" alt="" onerror="this.onerror=null; this.src='https://via.placeholder.com/48x48/333333/ffffff?text=♪';">
                            <div class="title"><%= s.getTitle()%></div>
                        </div>
                        <div class="genre"><%= s.getGenre() != null ? s.getGenre() : "Chưa xác định"%></div>
                        <div class="right">
                            <div class="duration"><%= (h > 0 ? h + ":" : "") + String.format("%02d:%02d", m, sec) %></div>
                            <span class="add-icon" onclick="showPlaylistMenu(event, '<%= s.getSongID() %>'); event.stopPropagation();">➕</span>
                        </div>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>
        <script>
var isLoggedIn = <%= (session.getAttribute("user") != null) ? "true" : "false" %>;
function showLoginPrompt() {
    if (document.getElementById('loginPrompt')) return;
    const div = document.createElement('div');
    div.id = 'loginPrompt';
    div.style.position = 'fixed';
    div.style.top = '80px';
    div.style.right = '30px';
    div.style.background = '#3ec6ff';
    div.style.color = '#222';
    div.style.padding = '18px 24px';
    div.style.borderRadius = '12px';
    div.style.boxShadow = '0 2px 12px rgba(0,0,0,0.15)';
    div.style.zIndex = 99999;
    div.style.fontSize = '16px';
    div.innerHTML = `
        <b>Bạn đã đăng xuất</b><br>
        Đăng nhập để thêm bài hát vào Playlist của bạn.
        <span style="position:absolute;top:8px;right:12px;cursor:pointer;font-size:20px;" onclick="document.getElementById('loginPrompt').remove()">×</span>
    `;
    document.body.appendChild(div);
    window.scrollTo({top: 0, behavior: 'smooth'});
}
            
function showPlaylistMenu(event, songId) {
    event.stopPropagation();
    if (!window.isLoggedIn) {
        showLoginPrompt();
        return;
    }
    const menu = document.getElementById('playlistMenu');
    menu.style.display = 'block';
    menu.dataset.songId = songId;

    const btnRect = event.target.getBoundingClientRect();
    const popupWidth = 260;
    const margin = 12;
    let left = btnRect.left - popupWidth - margin;
    if (left < 0) left = margin;

    menu.style.left = left + 'px';
    menu.style.top = window.scrollY + btnRect.top + 'px';

    renderSidebarPlaylistsInPopup(songId);
}
function renderSidebarPlaylistsInPopup(songId) {
    fetch('<%= request.getContextPath() %>/playlistDetail?action=getSidebarPlaylists')
        .then(res => res.json())
        .then(playlists => {
            const container = document.getElementById('sidebarPlaylists');
            container.innerHTML = '';

            if (!playlists || playlists.length === 0) {
                container.innerHTML = '<div style="color:#777;">Không có playlist nào.</div>';
                return;
            }

            playlists.forEach(p => {
                const div = document.createElement('div');
                div.textContent = p.name;
                div.style.padding = '6px';
                div.style.cursor = 'pointer';
                div.style.borderRadius = '4px';
                div.style.transition = '0.2s';
                div.style.color = '#fff';
                div.onmouseenter = () => div.style.background = '#333';
                div.onmouseleave = () => div.style.background = 'transparent';
                div.onclick = () => {
                    addSongToPlaylist(p.playlistId || p.playlistID, songId);
                    document.getElementById('playlistMenu').style.display = 'none';
                };
                container.appendChild(div);
            });
        })
        .catch(err => {
            console.error('Lỗi khi load playlists:', err);
            document.getElementById('sidebarPlaylists').innerHTML = '<div style="color:red;">Ấp khi tải playlists.</div>';
        });
}
function filterPlaylist(keyword) {
    const items = document.querySelectorAll('#sidebarPlaylists div');
    items.forEach(item => {
        item.style.display = item.textContent.toLowerCase().includes(keyword.toLowerCase()) ? 'block' : 'none';
    });
}

function createNewPlaylistFromInput() {
    const name = document.getElementById('newPlaylistName').value.trim();
    if (!name) {
        alert("⚠️ Vui lòng nhập tên playlist");
        return;
    }

    fetch('<%= request.getContextPath() %>/playlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
            action: 'createPlaylist',
            name: name,
            description: '',
            isPublic: true
        })
    }).then(res => res.json())
    .then(result => {
        if (result.success) {
            alert("✅ Tạo playlist thành công!");
            document.getElementById('newPlaylistName').value = "";
            // Reload danh sách phát
            const songId = document.getElementById('playlistMenu').dataset.songId;
            showPlaylistMenu({target: document.querySelector(`[data-song-id='${songId}']`)}, songId);
        } else {
            alert("❌ Tạo thất bại: " + result.message);
        }
    }).catch(err => {
        console.error('Lỗi tạo playlist:', err);
    });
}

function addSongToPlaylist(playlistId, songId) {
    fetch('<%= request.getContextPath() %>/playlist', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
            action: 'addSongToPlaylist',
            playlistId: playlistId,
            songId: songId
        })
    }).then(res => res.json())
    .then(result => {
        if (result.success) {
            alert("🎵 Đã thêm bài hát vào playlist!");
        } else {
            alert("🚫 Lỗi khi thêm bài hát.");
        }
    }).catch(err => {
        console.error('Lỗi khi thêm:', err);
    });
}


    // Tắt popup nếu click ra ngoài
document.addEventListener('click', function (e) {
    const menu = document.getElementById('playlistMenu');
    if (menu && !menu.contains(e.target) && !e.target.matches('.add-icon')) {
        menu.style.display = 'none';
    }
});
            let currentPlayingUrl = "";
            function playFirstSong() {
                const firstSongPath = '<%= encodedFirstSongPath%>';
                const title = '<%= songToPlay != null ? songToPlay.getTitle().replace("\'", "\\\\'") : "Không có bài hát"%>';
                const artist = '<%= songToPlay != null && songToPlay.getArtist() != null ? songToPlay.getArtist().replace("\'", "\\\\'") : "Không rõ nghệ sĩ"%>';
                const image = '<%= firstSongImage%>';
                if (firstSongPath) {
                    currentPlayingUrl = '<%= request.getContextPath()%>/play?file=' + firstSongPath;
                    playSong(document.querySelector('.song-item')); // Pass the first song item
                }
            }
            function toggleCreatePlaylist() {
                alert("👉 Mở popup tạo playlist ở đây nha bro 😎 (Chưa code phần modal)");
            }
            function playSong(element) {
                const audioUrl = element.dataset.url;
                const title = element.dataset.title;
                const artist = element.dataset.artist;
                const imageUrl = element.dataset.image;

                const audio = document.getElementById('audioPlayer');
                const titleElem = document.getElementById('mediaTitle');
                const artistElem = document.getElementById('mediaArtist');
                const thumbnail = document.getElementById('mediaThumbnail');
                const contextPath = '<%= request.getContextPath() %>';

                // Phát nhạc
                audio.src = audioUrl;
                audio.play();
                titleElem.textContent = title;
                artistElem.textContent = artist;
                thumbnail.src = imageUrl;
                thumbnail.onerror = () => {
                    thumbnail.src = 'https://via.placeholder.com/60x60/333333/ffffff?text=♪';
                };

                // Highlight bài hát
                currentPlayingUrl = audioUrl;
                highlightCurrentSong();

                // Cập nhật ảnh header
                const headerImage = document.getElementById('firstSongImage');
                if (headerImage && imageUrl) {
                    headerImage.src = imageUrl;
                }

                // Gửi yêu cầu lưu lịch sử nghe
                if (element && element.dataset && element.dataset.songId) {
                    fetch(`${window.location.origin}${contextPath}/listening?songId=${element.dataset.songId}`)
                                        .catch(err => console.error("Lỗi khi lưu lịch sử:", err));
                            }
                        }
                        function highlightCurrentSong() {
                            const items = document.querySelectorAll('.song-item');
                            items.forEach(item => {
                                const url1 = new URL(item.getAttribute('data-url'), window.location.origin).href;
                                const url2 = new URL(currentPlayingUrl, window.location.origin).href;
                                item.classList.toggle('active', url1 === url2);
                            });
                        }
                        

               

// Hàm để set queue khi trang load
function setQueueFromCurrentPage() {
    const songListFromServer = JSON.parse('<%= new Gson().toJson(songs) %>');

    console.log('Songs from server:', songListFromServer.length);

    if (songListFromServer.length > 0) {
        // Fix JSON trước khi gửi
        const cleanSongList = songListFromServer.map(song => ({
            songID: song.songID,
            title: song.title,
            artist: song.artist,
            filePath: song.filePath,
            duration: song.duration,
            genre: song.genre
        }));

        const requestData = {
            action: 'setQueue',
            songList: JSON.stringify(cleanSongList),
            startIndex: 0
        };

        console.log('Sending queue data:', requestData);

        fetch('<%= request.getContextPath() %>/queue', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestData)
        })
        .then(response => {
            console.log('Response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('Response data:', data);
            if (data.success) {
                console.log('✅ Queue đã được set thành công:', data.message);
                fetchUpNextSongs();
            } else {
                console.error('❌ Lỗi khi set queue:', data.message);
            }
        })
        .catch(error => {
            console.error('❌ Lỗi khi gửi request set queue:', error);
        });
    } else {
        console.log('Không có bài hát nào để set queue');
    }
}

function fetchUpNextSongs() {
    fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
        .then(res => res.json())
        .then(data => {
            const upNextList = document.getElementById('upNextList');
            if (!upNextList) return;
            
            upNextList.innerHTML = ''; // clear cũ

            if (!data.queue || data.queue.length === 0) {
                upNextList.innerHTML = '<p style="color:gray">Không có bài hát trong queue.</p>';
                return;
            }

            // Hiển thị tất cả bài hát trong queue
            data.queue.forEach(song => {
                const item = document.createElement('div');
                item.className = 'queue-item media-info';
                item.innerHTML = `
                    <img src="<%= request.getContextPath() %>/songImages/${song.title.replaceAll(' ', '_')}.jpg" alt="Ảnh" class="media-thumbnail" onerror="this.src='https://via.placeholder.com/60x60/333333/ffffff?text=♪'" />
                    <div class="media-details">
                        <h3>${song.title}</h3>
                        <p>${song.artist}</p>
                    </div>
                `;
                upNextList.appendChild(item);
            });
        })
        .catch(err => {
            console.error('Lỗi khi lấy danh sách tiếp theo:', err);
            const upNextList = document.getElementById('upNextList');
            if (upNextList) {
                upNextList.innerHTML = '<p style="color:red">Lỗi khi tải queue.</p>';
            }
        });
}

// Gọi ngay khi DOM load
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOM loaded, đang set queue...');
    console.log('Songs từ server:', <%= (songs != null ? songs.size() : 0) %>);
    setQueueFromCurrentPage();
});

// Tạo biến global để test
window.testQueue = function() {
    console.log('Testing queue...');
    setQueueFromCurrentPage();
};

// Nếu muốn cập nhật mỗi lần phát bài mới, gọi lại fetchUpNextSongs()

        </script>
        <jsp:include page="/WEB-INF/views/layouts/player.jsp" />
<div id="playlistMenu" class="playlist-popup" style="display:none;">
    <div class="playlist-header">🎶 Chọn playlist để thêm bài hát</div>

    <!-- Remove the search input -->
    <!-- <input type="text" id="searchPlaylistInput" placeholder="🔍 Tìm playlist..." 
           oninput="filterPlaylist(this.value)" 
           class="playlist-search" /> -->

    <!-- Thêm vào playlist -->
    <div style="border-top: 1px solid #444; padding-top: 8px;">
        <div style="color: #aaa; margin-bottom: 6px;">➕ Thêm vào playlist đã tạo</div>
        <div id="sidebarPlaylists" style="max-height: 140px; overflow-y: auto;">
        </div>
    </div>
</div>

    </body>
</html>
