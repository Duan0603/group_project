<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.Songs" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.SongDAO" %>
<%@ page import="java.net.URLEncoder" %>

<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<%
    List<Songs> songs = (List<Songs>) request.getAttribute("songs");
    String artistName = (String) request.getAttribute("artistName");
    String coverImage = (String) request.getAttribute("coverImage");
    Songs songToPlay = (Songs) request.getAttribute("songToPlay");
    int totalDuration = (request.getAttribute("totalDuration") != null) ? (int) request.getAttribute("totalDuration") : 0;

    if (songs == null) songs = new ArrayList<>();
    if (songToPlay == null && !songs.isEmpty()) songToPlay = songs.get(0);
    if (artistName == null) artistName = "Không xác định";
    if (coverImage == null) coverImage = "default.jpg";

    int hours = totalDuration / 3600;
    int minutes = (totalDuration % 3600) / 60;
    int seconds = totalDuration % 60;
    String formattedDuration = String.format("%d:%02d:%02d", hours, minutes, seconds);
    
String firstSongImage = "https://via.placeholder.com/60x60/333333/ffffff?text=♪";
    if (songToPlay != null && songToPlay.getTitle() != null) {
        String fileName = dao.SongDAO.toImageFileName(songToPlay.getTitle());
        firstSongImage = "songImages/" + fileName;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title><%= artistName %></title>
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
            color: #1da1f2;
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
            transition: background 0.2s ease;
        }
        .song-item:hover {
            background: #2a2a2a;
        }
        .song-item.active {
            background: #2e2e2e;
            border: 1px solid #e84393;
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
    </style>
</head>

<body>
<div class="main-area">
    
    <div class="sidebar-area">
        <jsp:include page="/WEB-INF/views/layouts/sidebar.jsp" />
    </div>

    <div class="content-area">
        <div class="artist-header">
            <div class="verified">
                <span style="font-size:18px;">✔</span>
                <span>Nghệ sĩ được xác minh</span>
            </div>
            <h1 class="artist-name"><%= artistName %></h1>
            <p class="song-info"><%= songs.size() %> bài hát · Tổng thời lượng: <%= formattedDuration %></p>
            
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

        <!-- Danh sách bài hát -->
        <div class="song-list">
        <%
            int i = 1;
            for (Songs s : songs) {
                int h = s.getDuration() / 3600;
                int m = (s.getDuration() % 3600) / 60;
                int sec = s.getDuration() % 60;
        %>
            <div class="song-item"
     data-url="<%= request.getContextPath() %>/play?file=<%= URLEncoder.encode(s.getFilePath(), "UTF-8") %>&songId=<%= s.getSongID() %>"
     onclick="playSong(
         '<%= request.getContextPath() %>/play?file=<%= URLEncoder.encode(s.getFilePath(), "UTF-8") %>&songId=<%= s.getSongID() %>',
         '<%= s.getTitle().replace("'", "\\'") %>',
         '<%= s.getArtist() != null ? s.getArtist().replace("'", "\\'") : "Không rõ nghệ sĩ" %>',
         'songImages/<%= dao.SongDAO.toImageFileName(s.getTitle()) %>',
         this)">
                <div class="left">
                    <span style="width:24px;text-align:right;"><%= i++ %></span>
                    <img src="songImages/<%= dao.SongDAO.toImageFileName(s.getTitle()) %>" alt="cover">
                    <div class="title"><%= s.getTitle() %></div>
                </div>
                <div class="genre"><%= s.getGenre() != null ? s.getGenre() : "Chưa xác định" %></div>
                <div class="right">
                    <div class="duration"><%= (h > 0 ? h + ":" : "") + String.format("%02d:%02d", m, sec) %></div>
                    <span class="add-icon">➕</span>
                </div>
            </div>
        <%
            }
        %>
        </div>
    </div>
</div>

<script>
// Đảm bảo biến và hàm là global
if (typeof window.currentSongList === 'undefined') window.currentSongList = [];
if (typeof window.currentSongIndex === 'undefined') window.currentSongIndex = 0;
// Khi click vào bất kỳ bài nào, cập nhật lại currentSongList và currentSongIndex
const allSongItems = Array.from(document.querySelectorAll('.song-item'));
allSongItems.forEach((item, idx) => {
    item.addEventListener('click', function() {
        window.currentSongList = allSongItems.map(it => {
            let raw = (it.getAttribute('data-url').split('file=')[1] || '').split('&')[0];
            let decoded = decodeURIComponent(raw);
            if (decoded.startsWith('songs/')) decoded = decoded.substring(6);
            return {
                filePath: decoded,
                title: it.querySelector('.title')?.textContent || '',
                artist: it.querySelector('.left .title')?.textContent || ''
            };
        });
        window.currentSongIndex = idx;
    });
});
// Khi playFirstSong, cũng cập nhật queue
function playFirstSong() {
    const allItems = Array.from(document.querySelectorAll('.song-item'));
    if (allItems.length > 0) {
        window.currentSongList = allItems.map(it => {
            let raw = (it.getAttribute('data-url').split('file=')[1] || '').split('&')[0];
            let decoded = decodeURIComponent(raw);
            if (decoded.startsWith('songs/')) decoded = decoded.substring(6);
            return {
                filePath: decoded,
                title: it.querySelector('.title')?.textContent || '',
                artist: it.querySelector('.left .title')?.textContent || ''
            };
        });
        window.currentSongIndex = 0;
        allItems[0].click();
    }
}

function addToPlaylist(songId, event) {
    // Ngăn không cho sự kiện nhấn vào dấu cộng cũng kích hoạt playSong
    event.stopPropagation();

    // Tạo một popup hoặc modal để người dùng chọn playlist
    let modal = document.getElementById('playlistModal');
    modal.style.display = 'block'; // Hiển thị modal chọn playlist
    
    // Lấy danh sách playlist từ server (sử dụng AJAX hoặc Fetch API)
    fetch('/getUserPlaylists')
        .then(response => response.json())
        .then(playlists => {
            // Hiển thị danh sách playlist trong modal
            let playlistContainer = document.getElementById('playlistList');
            playlistContainer.innerHTML = ''; // Clear trước
            playlists.forEach(playlist => {
                let playlistItem = document.createElement('li');
                playlistItem.innerHTML = playlist.name;
                playlistItem.onclick = function() {
                    addSongToPlaylist(playlist.playlistID, songId);
                    modal.style.display = 'none'; // Đóng modal
                };
                playlistContainer.appendChild(playlistItem);
            });
        })
        .catch(error => console.error('Lỗi khi lấy playlist:', error));
}

function addSongToPlaylist(playlistId, songId) {
    // Gửi yêu cầu thêm bài hát vào playlist
    fetch(`/addSongToPlaylist?playlistId=${playlistId}&songId=${songId}`, {
        method: 'POST'
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert('Bài hát đã được thêm vào playlist!');
        } else {
            alert('Có lỗi xảy ra khi thêm bài hát vào playlist.');
        }
    })
    .catch(error => console.error('Lỗi khi thêm bài hát vào playlist:', error));
}

function playSong(audioUrl, title, artist, imageUrl, element) {
    const audio = document.getElementById('audioPlayer');
    const titleElem = document.getElementById('mediaTitle');
    const artistElem = document.getElementById('mediaArtist');
    const thumbnail = document.getElementById('mediaThumbnail');

    // Phát nhạc
    audio.src = audioUrl;
    audio.play();
    titleElem.textContent = title;
    artistElem.textContent = artist;
    thumbnail.src = imageUrl;
    thumbnail.onerror = () => {
        thumbnail.src = 'https://via.placeholder.com/60x60/333333/ffffff?text=♪';
    };

    // Lưu lịch sử ngay khi bài hát được chọn
    if (element && element.dataset && element.dataset.songId) {
        fetch(`${window.location.origin}${contextPath}/listening?songId=${element.dataset.songId}`)
            .catch(err => console.error("Lỗi khi lưu lịch sử:", err));
    }
    // Highlight bài hát
    highlightCurrentSong();
}

function highlightCurrentSong() {
    const items = document.querySelectorAll('.song-item');

    items.forEach(item => {
        const url1 = new URL(item.getAttribute('data-url'), window.location.origin).href;
        const url2 = new URL(audio.src, window.location.origin).href;

        if (url1 === url2) {
            item.classList.add('active');
        } else {
            item.classList.remove('active');
        }
    });
}

document.addEventListener('DOMContentLoaded', function () {
    const audio = document.getElementById('audioPlayer');
    if (audio) {
        audio.addEventListener('ended', function () {
            const allSongs = [...document.querySelectorAll('.song-item')];
            const currentIndex = allSongs.findIndex(item => {
                const url1 = new URL(item.getAttribute('data-url'), window.location.origin).href;
                const url2 = new URL(audio.src, window.location.origin).href;
                return url1 === url2;
            });
            if (currentIndex !== -1 && currentIndex < allSongs.length - 1) {
                allSongs[currentIndex + 1].click();
            }
        });
    }
});
</script>

<jsp:include page="/WEB-INF/views/layouts/player.jsp" />
</body>
</html>