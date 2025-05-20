<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Home - Music Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            .song-card {
                transition: transform 0.2s;
                cursor: pointer;
            }
            .song-card:hover {
                transform: translateY(-5px);
            }
            .song-cover {
                width: 100%;
                height: 200px;
                object-fit: cover;
                border-radius: 5px;
            }
            .song-title {
                font-weight: bold;
                margin: 10px 0 5px 0;
            }
            .song-artist {
                color: #666;
            }
            .search-bar {
                max-width: 500px;
                margin: 20px auto;
            }
            .pagination {
                justify-content: center;
                margin-top: 30px;
            }
        </style>
    </head>
    <body>
        <%@ include file="components/navbar.jsp" %>
        
        <div class="container mt-4">
            <div class="search-bar">
                <form action="home" method="GET" class="d-flex">
                    <input type="text" name="search" class="form-control me-2" placeholder="Search songs..." value="${param.search}">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i>
                    </button>
                </form>
            </div>
            
            <div class="row g-4">
                <c:forEach items="${songs}" var="song">
                    <div class="col-md-3">
                        <div class="song-card" onclick="playSong(${song.songID})">
                            <img src="${song.coverImage}" alt="${song.title}" class="song-cover">
                            <div class="song-title">${song.title}</div>
                            <div class="song-artist">${song.artist}</div>
                            <div class="song-duration">${song.formattedDuration}</div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation">
                    <ul class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="home?page=${i}&search=${param.search}">${i}</a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>
        </div>
        
        <!-- Audio Player -->
        <div class="fixed-bottom bg-dark text-white p-3" id="audioPlayer" style="display: none;">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-4">
                        <div id="currentSongInfo"></div>
                    </div>
                    <div class="col-md-6">
                        <audio id="audioElement" controls class="w-100">
                            Your browser does not support the audio element.
                        </audio>
                    </div>
                    <div class="col-md-2 text-end">
                        <button class="btn btn-outline-light" onclick="closePlayer()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            function playSong(songId) {
                fetch('play?id=' + songId)
                    .then(response => response.json())
                    .then(song => {
                        const audioPlayer = document.getElementById('audioPlayer');
                        const audioElement = document.getElementById('audioElement');
                        const currentSongInfo = document.getElementById('currentSongInfo');
                        
                        audioElement.src = song.filePath;
                        currentSongInfo.innerHTML = `
                            <strong>${song.title}</strong><br>
                            <small>${song.artist}</small>
                        `;
                        
                        audioPlayer.style.display = 'block';
                        audioElement.play();
                    })
                    .catch(error => console.error('Error:', error));
            }
            
            function closePlayer() {
                const audioPlayer = document.getElementById('audioPlayer');
                const audioElement = document.getElementById('audioElement');
                audioElement.pause();
                audioPlayer.style.display = 'none';
            }
        </script>
    </body>
</html> 