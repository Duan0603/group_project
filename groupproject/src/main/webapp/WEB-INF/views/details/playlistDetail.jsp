<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="model.Songs" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.SongDAO" %>
<%@ page import="java.net.URLEncoder" %>

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
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết Playlist</title>
        <style>
            body { background: #121212; color: white; font-family: sans-serif; }
            .playlist-container { display: flex; }
            .sidebar { width: 260px; background: #181818; padding: 16px; min-height: 100vh; }
            .main-content { flex: 1; padding: 24px; }
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
                transition: background 0.3s, transform 0.2s, box-shadow 0.2s;
            }
            .song-item:hover {
                background: #232323;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255,255,255,0.05);
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
            .song-item .title {
                font-weight: 500;
                font-size: 1.05em;
            }
            .song-item .artist {
                margin-left: 16px;
                color: #aaa;
                font-size: 0.98em;
            }
            .song-item .right {
                display: flex;
                align-items: center;
                gap: 16px;
            }
            .song-item .duration {
                width: 60px;
                text-align: right;
                color: #bbb;
                font-size: 0.98em;
            }
            .song-item .remove-btn {
                background: #e74c3c;
                color: white;
                border: none;
                border-radius: 4px;
                padding: 6px 16px;
                cursor: pointer;
                font-size: 0.98em;
                transition: background 0.2s;
            }
            .song-item .remove-btn:hover {
                background: #c0392b;
            }
            .add-btn { background: #e84393; color: white; border: none; border-radius: 4px; padding: 6px 12px; cursor: pointer; }
            .add-btn:hover { background: #ff69b4; }
            .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.7); align-items: center; justify-content: center; }
            .modal-content { background: #222; padding: 24px; border-radius: 8px; min-width: 320px; }
            .close { float: right; color: #fff; font-size: 24px; cursor: pointer; }
        </style>
    </head>
    <body>

        <div class="playlist-container">
            <!-- Sidebar: Danh sách playlist -->
            <jsp:include page="/WEB-INF/views/layouts/sidebar.jsp" />
            <!-- Main content -->
            <div class="main-content">
                <h2>📃 Danh sách bài hát trong Playlist</h2>
                <h3>${playlist.name}</h3>
                <p>${playlist.description}</p>
                <button class="add-btn" onclick="document.getElementById('addSongModal').style.display='flex'">+ Thêm bài hát</button>
                <div class="song-list">
                    <c:forEach var="song" items="${songsInPlaylist}" varStatus="status">
                        <% String imageFileName = SongDAO.toImageFileName(((model.Songs)pageContext.findAttribute("song")).getTitle()); %>
                        <div class="song-item" 
                             data-song-id="${song.songID}"
                             data-title="${song.title}"
                             data-artist="${song.artist}"
                             data-file="${song.filePath}"
                             onclick="playSongFromDiv(this)">
                            <div class="left">
                                <span style="width:24px;text-align:right;">${status.index + 1}</span>
                                <img src="songImages/<%= imageFileName %>" alt="" onerror="this.onerror=null; this.src='https://via.placeholder.com/48x48/333333/ffffff?text=♪';">
                                <div class="title">${song.title}</div>
                                <span class="artist">${song.artist}</span>
                            </div>
                            <div class="right">
                                <div class="duration">
                                    <c:set var="minutes" value="${fn:substringBefore((song.duration/60.0), '.')}" />
                                    <c:set var="seconds" value="${fn:substringBefore((song.duration%60.0), '.')}" />
                                    ${minutes}:${seconds lt 10 ? '0' : ''}${seconds}
                                </div>
                                <form method="post" action="removeSongFromPlaylist" style="display:inline;">
                                    <input type="hidden" name="playlistId" value="${playlist.playlistID}" />
                                    <input type="hidden" name="songId" value="${song.songID}" />
                                    <button type="submit" class="remove-btn">Xóa</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
        <!-- Modal thêm bài hát -->
        <div class="modal" id="addSongModal">
            <div class="modal-content">
                <span class="close" onclick="document.getElementById('addSongModal').style.display='none'">&times;</span>
                <h3>Thêm bài hát vào playlist</h3>
                <form method="post" action="addSongsToPlaylist">
                    <input type="hidden" name="playlistId" value="${playlist.playlistID}" />
                    <div style="max-height:300px; overflow-y:auto;">
                        <c:forEach var="song" items="${allSongs}">
                            <div>
                                <input type="checkbox" name="selectedSongIds" value="${song.songID}" id="song${song.songID}" />
                                <label for="song${song.songID}">${song.title} - ${song.artist}</label>
                            </div>
                        </c:forEach>
                    </div>
                    <button type="submit" class="add-btn" style="margin-top:12px;">Thêm vào playlist</button>
                </form>
            </div>
        </div>
        <jsp:include page="/WEB-INF/views/layouts/player.jsp" />
        <script>
        function playSongFromDiv(div) {
            var file = div.dataset.file;
            var title = div.dataset.title;
            var artist = div.dataset.artist;
            var img = 'songImages/' + title.replace(/ /g, '') + '.jpg';
            // Gọi hàm playSong nếu có
            if (typeof playSong === 'function') {
                playSong(file, title, artist, img, div);
            }
        }
        // Đóng modal khi click ra ngoài
        window.onclick = function(event) {
            var modal = document.getElementById('addSongModal');
            if (event.target === modal) {
                modal.style.display = "none";
            }
        }
        </script>
    </body>
</html>
