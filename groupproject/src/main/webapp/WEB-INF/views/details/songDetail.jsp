<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.Songs" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<jsp:include page="/WEB-INF/views/layouts/header.jsp" />

<%
    List<Songs> songs = (List<Songs>) request.getAttribute("songs");
    String albumName = (String) request.getAttribute("albumName");
    String coverImage = (String) request.getAttribute("coverImage");
    Songs songToPlay = (Songs) request.getAttribute("songToPlay");
    List<Songs> sameGenreSongs = (List<Songs>) request.getAttribute("sameGenreSongs");

    List<Songs> allSongs = new ArrayList<>();
    if (songs != null) allSongs.addAll(songs);
    if (sameGenreSongs != null) allSongs.addAll(sameGenreSongs);

    int totalSeconds = 0;
    for (Songs song : allSongs) {
        totalSeconds += song.getDuration();
    }
    int totalMinutes = totalSeconds / 60;
    int totalHours = totalMinutes / 60;
    int remainingMinutes = totalMinutes % 60;
    int remainingSeconds = totalSeconds % 60;

    Set<String> uniqueArtists = new HashSet<>();
    for (Songs song : allSongs) {
        uniqueArtists.add(song.getArtist());
    }
    List<String> artists = new ArrayList<>(uniqueArtists);
    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><%= albumName %></title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: #181818; color: white; padding: 20px; font-family: sans-serif; }
        .container { max-width: 1200px; margin: auto; background: rgba(0, 0, 0, 0.7); border-radius: 20px; padding: 40px; }
        .album-header { background: linear-gradient(135deg, #e84393, #d72f7e); padding: 40px; display: flex; gap: 30px; border-radius: 15px; }
        .cover-image { width: 200px; height: 200px; object-fit: cover; border-radius: 15px; }
        .play-button { background: #e84393; padding: 10px 20px; border: none; border-radius: 20px; cursor: pointer; font-weight: bold; }
        .now-playing { margin-top: 30px; padding: 20px; background: rgba(255,255,255,0.05); border-radius: 10px; }
        table { width: 100%; margin-top: 20px; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; }
        tr:hover { background: rgba(255,255,255,0.1); }
        .song-item { cursor: pointer; }
        .song-item-play { border: none; background: none; color: #e84393; cursor: pointer; }
    </style>
</head>
<body>
<div class="container">
    <div class="album-header">
        <img src="albumImages/<%= coverImage %>" class="cover-image" alt="cover">
        <div class="album-info">
            <p>Danh sách phát công khai</p>
            <h1><%= albumName %></h1>
            <p>Pinkify • <%= allSongs.size() %> bài hát • <%= totalHours %> giờ <%= remainingMinutes %> phút</p>
            <p>Nghệ sĩ: <%= String.join(", ", artists) %></p>
        </div>
    </div>

    <div class="control-buttons" style="margin-top: 20px;">
        <button class="play-button" onclick="playThisSongFromList(0)">
            <i class="fas fa-play"></i> Phát bài đầu tiên
        </button>
    </div>

    <% if (songToPlay != null) {
        String rawPath = songToPlay.getFilePath();
        String fileName = "";
        if (rawPath != null && rawPath.contains("/")) {
            fileName = URLEncoder.encode(rawPath.substring(rawPath.lastIndexOf("/") + 1), "UTF-8");
        } else if (rawPath != null) {
            fileName = URLEncoder.encode(rawPath, "UTF-8");
        }
    %>
    <div class="now-playing" id="now-playing">
        <h3>🎧 Đang phát: <%= songToPlay.getTitle() %></h3>
        <p>Ca sĩ: <%= songToPlay.getArtist() %></p>
        <p>Thể loại: <%= songToPlay.getGenre() %></p>
        <audio id="audio-player" controls autoplay style="width: 100%;">
            <source src="<%= contextPath %>/play?file=<%= fileName %>" type="audio/mpeg">
            Trình duyệt không hỗ trợ audio.
        </audio>
    </div>
    <% } else { %>
    <audio id="audio-player" style="display: none;"></audio>
    <% } %>

    <div class="song-list">
        <h3>Danh sách bài hát</h3>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Tiêu đề</th>
                    <th>Album</th>
                    <th>Ca sĩ</th>
                    <th>Thời lượng</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <% int index = 0;
               for (Songs song : allSongs) {
                   int min = song.getDuration() / 60;
                   int sec = song.getDuration() % 60;
                   String path = song.getFilePath();
                   String file = "";
                   if (path != null && path.contains("/")) {
                       file = URLEncoder.encode(path.substring(path.lastIndexOf("/") + 1), "UTF-8");
                   } else if (path != null) {
                       file = URLEncoder.encode(path, "UTF-8");
                   }
            %>
            <tr class="song-item" onclick="selectSong(this)" 
                data-title="<%= song.getTitle() %>" 
                data-artist="<%= song.getArtist() %>" 
                data-genre="<%= song.getGenre() %>" 
                data-file="<%= file %>">
                <td><%= ++index %></td>
                <td><%= song.getTitle() %></td>
                <td><%= song.getAlbum() %></td>
                <td><%= song.getArtist() %></td>
                <td><%= String.format("%d:%02d", min, sec) %></td>
                <td><button class="song-item-play" onclick="event.stopPropagation(); playThisSong(this)"><i class="fas fa-play"></i></button></td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<script>
    const contextPath = "<%= contextPath %>";

    function selectSong(el) {
        const title = el.getAttribute('data-title');
        const artist = el.getAttribute('data-artist');
        const genre = el.getAttribute('data-genre');
        const file = el.getAttribute('data-file');

        if (!file || file.trim() === "") {
            alert("Không tìm thấy đường dẫn file bài hát.");
            return;
        }

        const nowPlaying = document.getElementById("now-playing");
        if (nowPlaying) nowPlaying.remove();

        const html = `
        <div class="now-playing" id="now-playing">
            <h3>🎧 Đang phát: ${title}</h3>
            <p>Ca sĩ: ${artist}</p>
            <p>Thể loại: ${genre}</p>
            <audio id="audio-player" controls autoplay style="width: 100%;">
                <source src="${contextPath}/play?file=${file}" type="audio/mpeg">
                Trình duyệt không hỗ trợ audio.
            </audio>
        </div>`;
        document.querySelector(".control-buttons").insertAdjacentHTML("afterend", html);
    }

    function playThisSong(button) {
        const row = button.closest('.song-item');
        selectSong(row);
    }

    function playThisSongFromList(index) {
        const rows = document.querySelectorAll('.song-item');
        if (rows[index]) {
            selectSong(rows[index]);
        }
    }
</script>
</body>
</html>