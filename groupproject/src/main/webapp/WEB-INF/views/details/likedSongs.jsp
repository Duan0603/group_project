<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.Songs" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.SongDAO" %>
<%@ page import="java.net.URLEncoder" %>

<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<%
    List<Songs> songs = (List<Songs>) request.getAttribute("likedSongs");
    if (songs == null) songs = new ArrayList<>();
    int totalDuration = 0;
    for (Songs s : songs) totalDuration += s.getDuration();
    int hours = totalDuration / 3600;
    int minutes = (totalDuration % 3600) / 60;
    int seconds = totalDuration % 60;
    String formattedDuration = String.format("%d:%02d:%02d", hours, minutes, seconds);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Bài hát đã thích</title>
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
            color: #e84393;
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
                <span style="font-size:18px;">❤</span>
                <span>Bài hát bạn đã like</span>
            </div>
            <h1 class="artist-name">Bài hát đã thích</h1>
            <p class="song-info"><%= songs.size() %> bài hát · Tổng thời lượng: <%= formattedDuration %></p>
            <div class="controls" style="display: flex; gap: 16px; align-items: center; margin-top: 24px;">
                <button onclick="playFirstSong()" style="background: #1DB954; border: none; border-radius: 50%; width: 56px; height: 56px; display: flex; justify-content: center; align-items: center; cursor: pointer;">
                    <i class="fa fa-play" style="color: white; font-size: 24px;"></i>
                </button>
            </div>
        </div>
        <div class="song-list">
            <% int i = 1;
            for (Songs s : songs) {
                int h = s.getDuration() / 3600;
                int m = (s.getDuration() % 3600) / 60;
                int sec = s.getDuration() % 60;
                String encodedPath = URLEncoder.encode((s.getFilePath() != null ? s.getFilePath() : ""), "UTF-8");
            %>
            <div class="song-item"
                 data-song-id="<%= s.getSongID()%>"
                 data-url="<%= request.getContextPath() %>/play?file=<%= encodedPath %>&songId=<%= s.getSongID() %>"
                 onclick="playSong(
                     '<%= request.getContextPath() %>/play?file=<%= encodedPath %>&songId=<%= s.getSongID() %>',
                     '<%= s.getTitle().replace("'", "\\'") %>',
                     '<%= s.getArtist() != null ? s.getArtist().replace("'", "\\'") : "Không rõ nghệ sĩ" %>',
                     <%= s.getSongID() %>,
                     this)">
                <div class="left">
                    <span style="width:24px;text-align:right;"><%= i++ %></span>
                    <% String imageFileName = SongDAO.toImageFileName(s.getTitle()); %>

                    <img src="songImages/<%= imageFileName %>" alt="" onerror="this.onerror=null; this.src='https://via.placeholder.com/48x48/333333/ffffff?text=♪';">
                    <div class="title"><%= s.getTitle() %></div>
                </div>
                <div class="genre"><%= s.getGenre() != null ? s.getGenre() : "Chưa xác định" %></div>
                <div class="right">
                    <div class="duration"><%= (h > 0 ? h + ":" : "") + String.format("%02d:%02d", m, sec) %></div>
                </div>
            </div>
            <% } %>
            <% if (songs.isEmpty()) { %>
                <div style="color:#aaa; text-align:center; margin-top:40px; font-size:20px;">Bạn chưa like bài hát nào.</div>
            <% } %>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layouts/player.jsp" />
<!-- Premium Popup -->
<div id="premiumPopup" style="display:none;position:fixed;bottom:100px;right:40px;z-index:99999;background:#fff;color:#222;padding:18px 28px;border-radius:12px;box-shadow:0 4px 24px rgba(0,0,0,0.18);font-size:16px;font-weight:500;align-items:center;gap:12px;min-width:260px;max-width:350px;">
    <span style="color:#e84393;font-size:22px;margin-right:10px;vertical-align:middle;"><i class="fas fa-crown"></i></span>
    Bạn cần <a href="<%= request.getContextPath() %>/payos-premium" style="color:#e84393;font-weight:bold;text-decoration:underline;margin:0 4px;">đăng ký Premium</a> để sử dụng tính năng này!
    <button onclick="document.getElementById('premiumPopup').style.display='none'" style="background:none;border:none;color:#e84393;font-size:18px;float:right;margin-left:10px;cursor:pointer;">&times;</button>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Đảm bảo biến và hàm là global
if (typeof window.currentSongList === 'undefined') window.currentSongList = [];
if (typeof window.currentSongIndex === 'undefined') window.currentSongIndex = 0;
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
function playSong(audioUrl, title, artist, songId, element) {
    const audio = document.getElementById('audioPlayer');
    const titleElem = document.getElementById('mediaTitle');
    const artistElem = document.getElementById('mediaArtist');
    const thumbnail = document.getElementById('mediaThumbnail');
    audio.src = audioUrl;
    audio.play();
    titleElem.textContent = title;
    artistElem.textContent = artist;
    thumbnail.src = "songImages/" + dao.SongDAO.toImageFileName(title);
    thumbnail.onerror = () => {
        thumbnail.src = 'https://via.placeholder.com/60x60/333333/ffffff?text=♪';
    };
    // Highlight bài hát
    highlightCurrentSong();
    window._currentSongId = songId;
    if (typeof checkLike === 'function') checkLike(songId);
}
function highlightCurrentSong() {
    const items = document.querySelectorAll('.song-item');
    const audio = document.getElementById('audioPlayer');
    items.forEach(item => {
        const url1 = new URL(item.getAttribute('data-url'), window.location.origin).href;
        const url2 = new URL(audio.src, window.location.origin).href;
        item.classList.toggle('active', url1 === url2);
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