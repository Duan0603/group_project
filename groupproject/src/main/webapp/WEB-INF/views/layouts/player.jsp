<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Media Player Wrapper -->
<div class="media-player-wrapper">
    <div class="media-player-container">
        <style>
            body {
                padding-bottom: 150px; /* để nội dung không bị che bởi thanh play */
            }
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

            .media-info, .now-playing-info {
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

            .media-details h3, .now-playing-details h3 {
                color: #ffffff;
                margin: 0;
                font-size: 14px;
                font-weight: 600;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                max-width: 200px; /* Adjust based on layout */
            }

            .media-details p, .now-playing-details p {
                color: #b3b3b3;
                margin: 0;
                font-size: 12px;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                max-width: 200px; /* Adjust based on layout */
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
                background: #e84393;
                font-size: 20px;
                width: 48px;
                height: 48px;
            }

            .play-btn:hover {
                background: white;
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
                position: relative;
                z-index: 1;
            }

            .progress-bar {
                width: 100%;
                height: 6px;
                max-width: 512px;
                background: #404040;
                border-radius: 3px;
                position: relative;
                cursor: pointer;
                margin-bottom: 0;
                overflow: visible;
                user-select: none;
                -webkit-user-select: none;
                -moz-user-select: none;
                -ms-user-select: none;
                pointer-events: auto;
                touch-action: none;
            }

            .progress-bar:hover {
                background: #505050;
            }

            .progress-bar:hover .progress-fill {
                background: #e84393;
            }

            .progress-tooltip {
                position: absolute;
                background: rgba(0, 0, 0, 0.9);
                color: white;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 12px;
                pointer-events: none;
                z-index: 1000;
                display: none;
                transform: translateX(-50%);
                top: -30px;
                white-space: nowrap;
            }

            .progress-fill {
                height: 100%;
                background: #b342f5;
                border-radius: 3px;
                width: 0%;
                transition: width 0.1s ease;
                position: relative;
            }

            .progress-fill::after {
                content: '';
                position: absolute;
                top: 50%;
                right: -6px;
                transform: translateY(-50%);
                width: 12px;
                height: 12px;
                background: white;
                border-radius: 50%;
                box-shadow: 0 2px 4px rgba(0,0,0,0.3);
                opacity: 0;
                transition: opacity 0.2s ease;
            }

            .progress-bar:hover .progress-fill::after {
                opacity: 1;
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

            .volume {
                flex: 1 1 20%;
                display: flex;
                align-items: center;
                gap: 10px;
                justify-content: flex-end;
                min-width: 0;
                z-index: 2;
            }

            .volume button {
                color: #e75480;
                transition: color 0.2s, background 0.2s, border-radius 0.2s;
                background: none;
                border: none;
                box-shadow: none;
            }

            .volume button:hover {
                color: #fff;
                background: none;
                border-radius: 50%;
            }

            .volume input {
                width: 100px;
            }

            .volume input[type=range] {
                accent-color: #e75480;
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

            .queue-item {
                transition: background 0.2s ease;
            }

            .queue-item:hover {
                background: #333333 !important;
            }

            #repeatBtn.active, #repeatBtn.active .icon {
                color: #e84393 !important;
                fill: #e84393 !important;
            }

            #repeatBtn .icon {
                color: #fff;
                fill: #fff;
                transition: color 0.2s, fill 0.2s;
            }

            .control-btn:disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }

            .control-btn:disabled:hover {
                background: none;
                transform: none;
            }
        </style>

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
        <audio id="audioPlayer" preload="metadata" controls hidden>
    <c:if test="${not empty mediaInfo.audioUrl}">
        <source src="${mediaInfo.audioUrl}" type="audio/mpeg">
    </c:if>
</audio>

        <!-- Controls -->
        <div class="media-controls">
            <button class="control-btn" id="prevBtn" title="Bài trước (Ctrl+←)">
                <svg class="icon" viewBox="0 0 24 24"><path d="M6 6H8V18H6V6ZM9.5 12L18 6V18L9.5 12Z"/></svg>
            </button>
            <button class="control-btn play-btn" id="playBtn" title="Play/Pause (Space)">
                <svg class="icon" id="playIcon" viewBox="0 0 24 24"><path d="M8 5V19L19 12L8 5Z"/></svg>
                <svg class="icon hidden" id="pauseIcon" viewBox="0 0 24 24"><path d="M6 4H10V20H6V4ZM14 4H18V20H14V4Z"/></svg>
            </button>
            <button class="control-btn" id="nextBtn" title="Bài tiếp theo (Ctrl+→)">
                <svg class="icon" viewBox="0 0 24 24"><path d="M16 18H18V6H16V18ZM6 6V18L14.5 12L6 6Z"/></svg>
            </button>
            <button class="control-btn" id="repeatBtn" title="Lặp lại">
                <svg class="icon" id="repeatIcon" viewBox="0 0 24 24"><path d="M7 7H17V10L21 6L17 2V5H5V11H7V7ZM17 17H7V14L3 18L7 22V19H19V13H17V17Z"/></svg>
            </button>
        </div>

        <!-- Progress Bar -->
        <div class="progress-container">
            <div class="progress-bar" id="progressBar">
                <div class="progress-fill" id="progressFill"></div>
                <div class="progress-tooltip" id="progressTooltip">0:00</div>
            </div>
            <div class="time-display">
                <span id="currentTime">0:00</span>
                <span id="totalTime">-:--</span>
            </div>
        </div>

        <!-- Queue Panel -->
        <div id="queueRightPanel" class="queue-right-panel">
            <div class="queue-header" style="display:flex;justify-content:space-between;align-items:center;">
                <span style="font-weight:bold;font-size:16px;color:#ff40b0;">Danh sách chờ</span>
                <button onclick="toggleQueueRight()" style="background:none;border:none;font-size:20px;color:#ff40b0;cursor:pointer;">×</button>
            </div>
            <div class="queue-content" style="margin-top: 20px; display: flex; flex-direction: column; gap: 20px;">
                <div id="nowPlayingSection">
                    <h5 style="color: #aaa; font-size: 13px;">Đang phát</h5>
                    <div id="nowPlaying" class="queue-item media-info">
                        <img src="https://via.placeholder.com/60x60/333333/ffffff?text=♪" alt="Now Playing Thumbnail" class="media-thumbnail" id="nowPlayingThumbnail">
                        <div class="media-details">
                            <h3 id="nowPlayingTitle">Chưa có bài hát</h3>
                            <p id="nowPlayingArtist">Không rõ nghệ sĩ</p>
                        </div>
                    </div>
                </div>
                <div id="upNextSection">
    <h5 style="color: #aaa; font-size: 13px;">Tiếp theo</h5>
    <div id="upNextList" style="display: flex; flex-direction: column; gap: 12px;"></div>
        <!-- Các bài hát tiếp theo sẽ được thêm vào đây thông qua JavaScript -->
    </div>
</div>
            </div>
        </div>

        <!-- Volume Controls -->
        <div class="volume">
            <button class="control-btn" id="queueBtn" title="Queue" style="margin-right: 8px;">
                <i class="fas fa-bars" id="queue-icon"></i>
            </button>
            <button class="control-btn" id="volumeBtn" title="Toggle Volume" style="margin-right: 8px;">
                <i class="fas fa-volume-up" id="volume-icon"></i>
            </button>
            <input type="range" id="volumeSlider" min="0" max="100" step="1" value="50">
        </div>
    </div>
</div>

<!-- JS -->
<script>
    
            // Lấy danh sách queue từ sessionStorage
        const queueList = JSON.parse(sessionStorage.getItem("songQueue") || "[]");

        // Hàm để mở/đóng panel queue
        function toggleQueue() {
            const panel = document.getElementById("queuePanel");
            panel.style.display = panel.style.display === 'flex' ? 'none' : 'flex';
        }

        // Hàm render danh sách bài hát
        function renderQueue(queueData) {
            const content = document.getElementById("queueContent");
            content.innerHTML = "";

            if (queueData.length === 0) {
                content.innerHTML = `
                    <i class="fas fa-bars queue-icon"></i>
                    <h5>Add to queue</h5>
                    <p>Tap "Add to queue" from a song menu to see it here.</p>
                    <button class="find-btn">Find something to play</button>
                `;
            } else {
                queueData.forEach(song => {
                    const songItem = document.createElement("div");
                    songItem.className = "song-item";
                    songItem.innerHTML = `
                        <strong>${song.title}</strong><br>
                        <span>${song.artist}</span>
                    `;
                    content.appendChild(songItem);
                });
            }
        }

         // Hàm gửi yêu cầu AJAX đến servlet để lấy bài hát theo loại
        function fetchQueueData(action) {
            fetch(`/queue?action=${action}`)
                .then(response => response.json())
                .then(data => renderQueue(data))
                .catch(error => console.error("Error fetching queue data:", error));
        }

        // Lắng nghe khi trang đã load xong và render dữ liệu từ session hoặc yêu cầu mới
        window.addEventListener("DOMContentLoaded", () => {
            // Nếu không có dữ liệu queue trong sessionStorage, lấy từ backend
            if (queueList.length === 0) {
                fetchQueueData("hotTrend");  // Hoặc "artist" tuỳ vào nhu cầu
            } else {
                renderQueue(queueList);
            }
        });
    
    
function selectSong(songElement) {
    // Lấy thông tin từ phần tử bài hát được nhấn
    const action = songElement.getAttribute('data-action');  // "artist" hoặc "hotTrend"
    const songTitle = songElement.querySelector('h3').textContent;

    // Gọi hàm fetchQueue với action tương ứng
    fetchQueue(action, songTitle);
}

function fetchQueue(action, songTitle) {
    // Kiểm tra xem đã có dữ liệu trong sessionStorage chưa
    let queueData = sessionStorage.getItem('queueData');

    if (queueData) {
        // Nếu có dữ liệu trong sessionStorage, parse và hiển thị
        queueData = JSON.parse(queueData);
        updateQueueList(queueData);
    } else {
        // Nếu không có, gọi API để lấy dữ liệu từ servlet
        fetch(`/queue?action=${action}`)  // Gọi đến Servlet với action là artist hoặc hotTrend
            .then(response => response.json())
            .then(data => {
                if (data && Array.isArray(data)) {
                    // Lưu dữ liệu vào sessionStorage
                    sessionStorage.setItem('queueData', JSON.stringify(data));
                    updateQueueList(data);
                } else {
                    const queueList = document.getElementById('upNextList');
                    queueList.innerHTML = '<p>Không có bài hát nào trong danh sách chờ</p>';
                }
            })
            .catch(error => console.error('Lỗi khi lấy dữ liệu:', error));
    }
}

// Hàm để cập nhật danh sách bài hát vào giao diện
function updateQueueList(data) {
    // Đang phát
    if (data.length > 0) {
        const nowPlaying = data[0];
        document.getElementById('nowPlayingTitle').textContent = nowPlaying.title || "Chưa có bài hát";
        document.getElementById('nowPlayingArtist').textContent = nowPlaying.artist || "Không rõ nghệ sĩ";
        if (nowPlaying.thumbnail) {
            document.getElementById('nowPlayingThumbnail').src = nowPlaying.thumbnail;
        } else {
            document.getElementById('nowPlayingThumbnail').src = 'default.jpg';
        }
    }
    // Tiếp theo
    const upNextList = document.getElementById('upNextList');
    upNextList.innerHTML = '';
    for (let i = 1; i < data.length; i++) {
        const song = data[i];
        const songItem = document.createElement('div');
        songItem.classList.add('queue-item');
        songItem.innerHTML = `
            <img src="${song.thumbnail || 'default.jpg'}" alt="Thumbnail" class="media-thumbnail">
            <div class="media-details">
                <h3>${song.title || "Không có tiêu đề"}</h3>
                <p>${song.artist || "Không rõ nghệ sĩ"}</p>
            </div>
        `;
        upNextList.appendChild(songItem);
    }
}

// Lắng nghe sự kiện click cho các nút chọn "Artist" và "Hot Trend"
document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('artistBtn').addEventListener('click', function () {
        fetchQueue('artist');  // Gọi fetch với action là "artist"
    });

    document.getElementById('hotTrendBtn').addEventListener('click', function () {
        fetchQueue('hotTrend');  // Gọi fetch với action là "hotTrend"
    });
});
    
    function toggleQueueRight() {
        const panel = document.getElementById('queueRightPanel');
        panel.style.display = panel.style.display === 'none' ? 'flex' : 'none';
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.getElementById('queueBtn').addEventListener('click', toggleQueueRight);
    });

    function playSong(audioUrl, title, artist) {
    const audio = document.getElementById('audioPlayer');
    const titleEl = document.getElementById('mediaTitle');
    const artistEl = document.getElementById('mediaArtist');
    const thumbnailEl = document.getElementById('mediaThumbnail');
    const nowPlayingThumbnail = document.getElementById('nowPlayingThumbnail');
    const nowPlayingTitle = document.getElementById('nowPlayingTitle');
    const nowPlayingArtist = document.getElementById('nowPlayingArtist');

    const prevTime = audio.currentTime || 0; // 🕘 Giữ lại thời gian đang phát nếu đang nghe

    // ✅ So sánh phần cuối URL để tránh reset bài nếu đang phát đúng bài đó
    const currentSrc = audio.src.split('/').pop();
    const newSrc = audioUrl.split('/').pop();

    if (currentSrc !== newSrc) {
        // 🎵 Là bài mới → set src & load lại
        audio.src = audioUrl;
        audio.load();

        // ⏱ Set lại thời gian đã tua sau khi load xong
        audio.addEventListener('loadedmetadata', function handleLoaded() {
            audio.currentTime = prevTime;
            audio.play();
            audio.removeEventListener('loadedmetadata', handleLoaded);
        });
    } else {
        // 🧠 Là bài hiện tại → giữ nguyên src, chỉ play lại nếu đang pause
        audio.currentTime = prevTime;
        audio.play();
    }

    // 🎨 Cập nhật thông tin UI
    titleEl.textContent = title || "Chưa có bài hát";
    artistEl.textContent = artist || "Không rõ nghệ sĩ";

    if (nowPlayingTitle) nowPlayingTitle.textContent = title || "Chưa có bài hát";
    if (nowPlayingArtist) nowPlayingArtist.textContent = artist || "Không rõ nghệ sĩ";

    // 🖼️ Xử lý ảnh thumbnail
    const imgName = toImageFileName(title);
    const imgSrc = '<%= request.getContextPath() %>/songImages/' + imgName;

    thumbnailEl.src = imgSrc;
    if (nowPlayingThumbnail) nowPlayingThumbnail.src = imgSrc;

    thumbnailEl.onerror = () => {
        thumbnailEl.src = '<%= request.getContextPath() %>/songImages/default.jpg';
    };
    if (nowPlayingThumbnail) {
        nowPlayingThumbnail.onerror = () => {
            nowPlayingThumbnail.src = '<%= request.getContextPath() %>/songImages/default.jpg';
        };
    }

    // 🗃️ Cập nhật session nowPlaying
    updateNowPlayingInSession(title, artist, audioUrl);
}


    function updateNowPlayingInSession(title, artist, audioUrl) {
        // Tìm bài hát trong queue hiện tại
        fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
            .then(res => res.json())
            .then(data => {
                if (data.queue && data.queue.length > 0) {
                    // Tìm bài hát có title và artist khớp
                    const currentSong = data.queue.find(song => 
                        song.title === title && song.artist === artist
                    );
                    
                    if (currentSong) {
                        // Cập nhật nowPlaying trong session
                        fetch('<%= request.getContextPath() %>/queue', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({
                                action: 'updateNowPlaying',
                                songId: currentSong.songID
                            })
                        })
                        .then(() => {
                            // Cập nhật lại danh sách tiếp theo
                            fetchUpNextSongs();
                        })
                        .catch(err => console.error('Lỗi khi cập nhật nowPlaying:', err));
                    }
                }
            })
            .catch(err => console.error('Lỗi khi lấy queue hiện tại:', err));
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
        const volumeIcon = document.getElementById('volume-icon');
        const repeatBtn = document.getElementById('repeatBtn');
        const progressTooltip = document.getElementById('progressTooltip');
        let isRepeat = false;

        audio.volume = 0.5;
        let isPlaying = false;
        let isDragging = false;
        let isSeeking = false;
        let lastSeekTime = 0;
        let savedCurrentTime = 0;
        let isAudioReady = false;

        function formatTime(seconds) {
            const mins = Math.floor(seconds / 60);
            const secs = Math.floor(seconds % 60);
            return mins + ':' + (secs < 10 ? '0' : '') + secs;
        }

        // Hàm helper để tua nhạc an toàn
        function seekToTime(newTime) {
            if (isNaN(audio.duration) || audio.duration <= 0) {
                console.log('Cannot seek: audio duration not available');
                return false;
            }
            
            if (isNaN(newTime) || newTime < 0) {
                console.log('Invalid time:', newTime);
                return false;
            }
            
            // Đảm bảo thời gian không vượt quá duration
            const clampedTime = Math.min(newTime, audio.duration);
            
            // Kiểm tra xem có phải là lần tua gần đây không
            const now = Date.now();
            if (now - lastSeekTime < 50) {
                console.log('Seek too frequent, ignoring');
                return false;
            }
            
            console.log('Seeking to:', clampedTime, 'from:', audio.currentTime, 'duration:', audio.duration);
            
            // Đánh dấu đang tua
            isSeeking = true;
            lastSeekTime = now;
            
            // Lưu trạng thái phát hiện tại
            const wasPlaying = !audio.paused;
            const currentVolume = audio.volume;
            
            try {
                // Lưu thời gian hiện tại để khôi phục nếu cần
                if (isAudioReady && audio.currentTime > 0) {
                    savedCurrentTime = clampedTime;
                }
                
                // Tạm thời pause để tránh xung đột
                if (wasPlaying) {
                    audio.pause();
                }
                
                // Set thời gian mới
                audio.currentTime = clampedTime;
                
                // Resume nếu đang phát và đảm bảo volume không bị reset
                if (wasPlaying) {
                    setTimeout(() => {
                        audio.volume = currentVolume;
                        audio.play().catch(e => console.error('Error resuming after seek:', e));
                    }, 10);
                }
                
                // Reset flag sau một chút
                setTimeout(() => {
                    isSeeking = false;
                }, 200);
                
                return true;
            } catch (error) {
                console.error('Error seeking audio:', error);
                isSeeking = false;
                return false;
            }
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

        // Xử lý khi audio load metadata
        audio.addEventListener('loadedmetadata', function () {
            totalTimeSpan.textContent = formatTime(audio.duration);
            console.log('Audio loaded, duration:', audio.duration);
            isAudioReady = true;
            
            // Khôi phục thời gian đã lưu nếu có
            if (savedCurrentTime > 0 && !isDragging && !isSeeking) {
                console.log('Restoring saved time:', savedCurrentTime);
                audio.currentTime = savedCurrentTime;
                savedCurrentTime = 0;
            }
            
            // Chỉ reset progress bar nếu không đang drag, không đang tua và audio chưa được phát
            if (!isDragging && !isSeeking && audio.currentTime === 0) {
                progressFill.style.width = '0%';
                currentTimeSpan.textContent = '0:00';
            }
        });

        // Xử lý timeupdate để cập nhật thanh tua
        audio.addEventListener('timeupdate', function () {
            if (!isDragging && !isSeeking && !isNaN(audio.duration) && audio.duration > 0) {
                const progress = (audio.currentTime / audio.duration) * 100;
                progressFill.style.width = progress + '%';
                currentTimeSpan.textContent = formatTime(audio.currentTime);
                
                // Lưu thời gian hiện tại để khôi phục nếu cần
                if (audio.currentTime > 0) {
                    savedCurrentTime = audio.currentTime;
                }
            }
        });

        // Xử lý khi audio bắt đầu load
        audio.addEventListener('loadstart', function () {
            console.log('Audio loading started');
        });

        // Xử lý khi audio load thành công
        audio.addEventListener('canplay', function () {
            console.log('Audio can play, duration:', audio.duration);
        });

        // Ngăn chặn việc audio bị reset
        audio.addEventListener('seeking', function () {
            console.log('Audio seeking to:', audio.currentTime);
        });

        audio.addEventListener('seeked', function () {
            console.log('Audio seeked to:', audio.currentTime);
        });

        // Xử lý khi có lỗi audio
        audio.addEventListener('error', function (e) {
            console.error('Audio error:', e);
        });

        // Ngăn chặn việc audio bị load lại
        audio.addEventListener('loadstart', function () {
            console.log('Audio load started - current time:', audio.currentTime);
        });

        audio.addEventListener('canplay', function () {
            console.log('Audio can play - current time:', audio.currentTime);
        });

        // Xử lý khi audio bị suspend
        audio.addEventListener('suspend', function () {
            console.log('Audio suspended - current time:', audio.currentTime);
        });

        // Xử lý khi audio bị abort
        audio.addEventListener('abort', function () {
            console.log('Audio aborted - current time:', audio.currentTime);
        });

        // Xử lý khi audio bị stalled
        audio.addEventListener('stalled', function () {
            console.log('Audio stalled - current time:', audio.currentTime);
        });

        // Xử lý khi audio bị waiting
        audio.addEventListener('waiting', function () {
            console.log('Audio waiting - current time:', audio.currentTime);
        });

        // Xử lý khi audio bị canplaythrough
        audio.addEventListener('canplaythrough', function () {
            console.log('Audio can play through - current time:', audio.currentTime);
        });

        // Xử lý click để tua nhạc
        progressBar.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            
            if (isNaN(audio.duration) || audio.duration <= 0) {
                console.log('Audio duration is not available');
                return;
            }
            
            const rect = progressBar.getBoundingClientRect();
            const clickX = e.clientX - rect.left;
            const percent = clickX / rect.width;
            
            // Đảm bảo percent trong khoảng 0-1
            const clampedPercent = Math.max(0, Math.min(1, percent));
            const newTime = clampedPercent * audio.duration;
            
            console.log('Clicking progress bar:', {
                clickX: clickX,
                rectWidth: rect.width,
                percent: percent,
                clampedPercent: clampedPercent,
                newTime: newTime,
                duration: audio.duration,
                currentTime: audio.currentTime
            });
            
            // Cập nhật thời gian ngay lập tức
            if (seekToTime(newTime)) {
                // Cập nhật giao diện
                progressFill.style.width = (clampedPercent * 100) + '%';
                currentTimeSpan.textContent = formatTime(newTime);
            }
        });

        // Xử lý drag để tua nhạc
        progressBar.addEventListener('mousedown', function (e) {
            e.preventDefault();
            e.stopPropagation();
            
            if (isNaN(audio.duration) || audio.duration <= 0) {
                console.log('Cannot drag: audio duration not available');
                return;
            }
            
            isDragging = true;
            console.log('Started dragging');
            
            const rect = progressBar.getBoundingClientRect();
            const clickX = e.clientX - rect.left;
            const percent = clickX / rect.width;
            
            const clampedPercent = Math.max(0, Math.min(1, percent));
            const newTime = clampedPercent * audio.duration;
            
            // Cập nhật ngay khi bắt đầu drag
            if (seekToTime(newTime)) {
                progressFill.style.width = (clampedPercent * 100) + '%';
                currentTimeSpan.textContent = formatTime(newTime);
            }
        });

        document.addEventListener('mousemove', function (e) {
            if (isDragging && !isNaN(audio.duration) && audio.duration > 0) {
                e.preventDefault();
                
                const rect = progressBar.getBoundingClientRect();
                const mouseX = e.clientX - rect.left;
                const percent = mouseX / rect.width;
                
                const clampedPercent = Math.max(0, Math.min(1, percent));
                const newTime = clampedPercent * audio.duration;
                
                // Cập nhật thời gian và giao diện
                if (seekToTime(newTime)) {
                    progressFill.style.width = (clampedPercent * 100) + '%';
                    currentTimeSpan.textContent = formatTime(newTime);
                }
            }
        });

        document.addEventListener('mouseup', function () {
            if (isDragging) {
                console.log('Stopped dragging');
                isDragging = false;
            }
        });

        // Hiển thị tooltip khi hover progress bar
        progressBar.addEventListener('mousemove', function (e) {
            if (isNaN(audio.duration) || audio.duration <= 0) return;
            
            const rect = progressBar.getBoundingClientRect();
            const mouseX = e.clientX - rect.left;
            const percent = mouseX / rect.width;
            const clampedPercent = Math.max(0, Math.min(1, percent));
            const timeAtPosition = clampedPercent * audio.duration;
            
            progressTooltip.textContent = formatTime(timeAtPosition);
            progressTooltip.style.left = mouseX + 'px';
            progressTooltip.style.display = 'block';
        });

        progressBar.addEventListener('mouseleave', function () {
            progressTooltip.style.display = 'none';
        });

        // Thêm debug để kiểm tra thanh tua
        progressBar.addEventListener('mouseenter', function () {
            console.log('Progress bar hovered, audio duration:', audio.duration);
        });

        // Thêm event listener để đảm bảo thanh tua có thể click
        progressBar.addEventListener('pointerdown', function (e) {
            console.log('Progress bar pointer down');
        });

        // Ngăn chặn context menu trên thanh tua
        progressBar.addEventListener('contextmenu', function (e) {
            e.preventDefault();
        });

        // Thêm event listener để debug khi audio bị thay đổi
        audio.addEventListener('ratechange', function () {
            console.log('Audio rate changed to:', audio.playbackRate);
        });

        audio.addEventListener('volumechange', function () {
            console.log('Audio volume changed to:', audio.volume);
        });

        volumeSlider.addEventListener('input', function () {
            audio.volume = this.value / 100;
            if (audio.volume === 0) {
                volumeIcon.classList.replace('fa-volume-up', 'fa-volume-mute');
            } else {
                volumeIcon.classList.replace('fa-volume-mute', 'fa-volume-up');
            }
        });

        volumeBtn.addEventListener('click', function () {
            if (audio.volume > 0) {
                audio.volume = 0;
                volumeSlider.value = 0;
                volumeIcon.classList.replace('fa-volume-up', 'fa-volume-mute');
            } else {
                audio.volume = 0.5;
                volumeSlider.value = 50;
                volumeIcon.classList.replace('fa-volume-mute', 'fa-volume-up');
            }
        });

        document.addEventListener('keydown', function (e) {
            if (e.target.tagName === 'INPUT') return; // Không xử lý khi đang nhập text
            
            switch (e.code) {
                case 'Space':
                    e.preventDefault();
                    playBtn.click();
                    break;
                case 'ArrowLeft':
                    e.preventDefault();
                    if (e.ctrlKey || e.metaKey) {
                        // Ctrl/Cmd + Left: Chuyển bài trước
                        document.getElementById('prevBtn').click();
                    } else {
                        // Tua lùi 10 giây
                        if (!isNaN(audio.duration) && audio.duration > 0) {
                            audio.currentTime = Math.max(0, audio.currentTime - 10);
                        }
                    }
                    break;
                case 'ArrowRight':
                    e.preventDefault();
                    if (e.ctrlKey || e.metaKey) {
                        // Ctrl/Cmd + Right: Chuyển bài tiếp theo
                        document.getElementById('nextBtn').click();
                    } else {
                        // Tua tới 10 giây
                        if (!isNaN(audio.duration) && audio.duration > 0) {
                            audio.currentTime = Math.min(audio.duration, audio.currentTime + 10);
                        }
                    }
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    // Tăng volume
                    const newVolumeUp = Math.min(1, audio.volume + 0.1);
                    audio.volume = newVolumeUp;
                    volumeSlider.value = newVolumeUp * 100;
                    if (newVolumeUp > 0) {
                        volumeIcon.classList.replace('fa-volume-mute', 'fa-volume-up');
                    }
                    break;
                case 'ArrowDown':
                    e.preventDefault();
                    // Giảm volume
                    const newVolumeDown = Math.max(0, audio.volume - 0.1);
                    audio.volume = newVolumeDown;
                    volumeSlider.value = newVolumeDown * 100;
                    if (newVolumeDown === 0) {
                        volumeIcon.classList.replace('fa-volume-up', 'fa-volume-mute');
                    }
                    break;
            }
        });

        document.getElementById('prevBtn').addEventListener('click', function () {
            // Thử lấy queue từ server trước
            fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
                .then(res => res.json())
                .then(data => {
                    if (data.queue && data.queue.length > 0) {
                        // Tìm bài hát hiện tại trong queue
                        const currentSongTitle = document.getElementById('mediaTitle').textContent;
                        const currentSongArtist = document.getElementById('mediaArtist').textContent;
                        
                        let currentIndex = data.queue.findIndex(song => 
                            song.title === currentSongTitle && song.artist === currentSongArtist
                        );
                        
                        // Nếu không tìm thấy, giả sử đang phát bài đầu tiên
                        if (currentIndex === -1) currentIndex = 0;
                        
                        // Chuyển về bài trước
                        if (currentIndex > 0) {
                            const prevSong = data.queue[currentIndex - 1];
                            const url = '<%= request.getContextPath() %>/play?file=' + encodeURIComponent(prevSong.filePath);
                            playSong(url, prevSong.title, prevSong.artist);
                        }
                    } else {
                        // Fallback: thử với window.currentSongList
                        if (window.currentSongList && window.currentSongIndex > 0) {
                            window.currentSongIndex--;
                            window.playSongFromList(window.currentSongList, window.currentSongIndex);
                        }
                    }
                })
                .catch(err => {
                    console.error('Lỗi khi lấy queue:', err);
                    // Fallback: thử với window.currentSongList
                    if (window.currentSongList && window.currentSongIndex > 0) {
                        window.currentSongIndex--;
                        window.playSongFromList(window.currentSongList, window.currentSongIndex);
                    }
                });
        });

        document.getElementById('nextBtn').addEventListener('click', function () {
            // Thử lấy queue từ server trước
            fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
                .then(res => res.json())
                .then(data => {
                    if (data.queue && data.queue.length > 0) {
                        // Tìm bài hát hiện tại trong queue
                        const currentSongTitle = document.getElementById('mediaTitle').textContent;
                        const currentSongArtist = document.getElementById('mediaArtist').textContent;
                        
                        let currentIndex = data.queue.findIndex(song => 
                            song.title === currentSongTitle && song.artist === currentSongArtist
                        );
                        
                        // Nếu không tìm thấy, giả sử đang phát bài đầu tiên
                        if (currentIndex === -1) currentIndex = 0;
                        
                        // Chuyển đến bài tiếp theo
                        if (currentIndex < data.queue.length - 1) {
                            const nextSong = data.queue[currentIndex + 1];
                            const url = '<%= request.getContextPath() %>/play?file=' + encodeURIComponent(nextSong.filePath);
                            playSong(url, nextSong.title, nextSong.artist);
                        }
                    } else {
                        // Fallback: thử với window.currentSongList
                        if (window.currentSongList && window.currentSongIndex < window.currentSongList.length - 1) {
                            window.currentSongIndex++;
                            window.playSongFromList(window.currentSongList, window.currentSongIndex);
                        }
                    }
                })
                .catch(err => {
                    console.error('Lỗi khi lấy queue:', err);
                    // Fallback: thử với window.currentSongList
                    if (window.currentSongList && window.currentSongIndex < window.currentSongList.length - 1) {
                        window.currentSongIndex++;
                        window.playSongFromList(window.currentSongList, window.currentSongIndex);
                    }
                });
        });

        repeatBtn.addEventListener('click', function () {
            isRepeat = !isRepeat;
            repeatBtn.classList.toggle('active', isRepeat);
        });

        audio.addEventListener('ended', function () {
            if (isRepeat) {
                audio.currentTime = 0;
                audio.play();
            } else {
                // Tự động chuyển bài tiếp theo từ queue
                fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
                    .then(res => res.json())
                    .then(data => {
                        if (data.queue && data.queue.length > 0) {
                            // Tìm bài hát hiện tại trong queue
                            const currentSongTitle = document.getElementById('mediaTitle').textContent;
                            const currentSongArtist = document.getElementById('mediaArtist').textContent;
                            
                            let currentIndex = data.queue.findIndex(song => 
                                song.title === currentSongTitle && song.artist === currentSongArtist
                            );
                            
                            // Nếu không tìm thấy, giả sử đang phát bài đầu tiên
                            if (currentIndex === -1) currentIndex = 0;
                            
                            // Chuyển đến bài tiếp theo
                            if (currentIndex < data.queue.length - 1) {
                                const nextSong = data.queue[currentIndex + 1];
                                const url = '<%= request.getContextPath() %>/play?file=' + encodeURIComponent(nextSong.filePath);
                                playSong(url, nextSong.title, nextSong.artist);
                            }
                        } else {
                            // Fallback: thử với window.currentSongList
                            if (window.currentSongList && window.currentSongIndex < window.currentSongList.length - 1) {
                                window.currentSongIndex++;
                                window.playSongFromList(window.currentSongList, window.currentSongIndex);
                            }
                        }
                    })
                    .catch(err => {
                        console.error('Lỗi khi lấy queue:', err);
                        // Fallback: thử với window.currentSongList
                        if (window.currentSongList && window.currentSongIndex < window.currentSongList.length - 1) {
                            window.currentSongIndex++;
                            window.playSongFromList(window.currentSongList, window.currentSongIndex);
                        }
                    });
            }
        });
        
        // Cập nhật trạng thái nút khi trang load
        setTimeout(updateNavigationButtons, 500);
    });

    // Đảm bảo biến và hàm là global
    if (typeof window.currentSongList === 'undefined') window.currentSongList = [];
    if (typeof window.currentSongIndex === 'undefined') window.currentSongIndex = 0;
    
    // Hàm helper để cập nhật trạng thái nút tua
    function updateNavigationButtons() {
        const prevBtn = document.getElementById('prevBtn');
        const nextBtn = document.getElementById('nextBtn');
        
        fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
            .then(res => res.json())
            .then(data => {
                if (data.queue && data.queue.length > 0) {
                    const currentSongTitle = document.getElementById('mediaTitle').textContent;
                    const currentSongArtist = document.getElementById('mediaArtist').textContent;
                    
                    let currentIndex = data.queue.findIndex(song => 
                        song.title === currentSongTitle && song.artist === currentSongArtist
                    );
                    
                    if (currentIndex === -1) currentIndex = 0;
                    
                    // Cập nhật trạng thái nút
                    prevBtn.disabled = currentIndex <= 0;
                    nextBtn.disabled = currentIndex >= data.queue.length - 1;
                } else {
                    // Fallback với window.currentSongList
                    prevBtn.disabled = !window.currentSongList || window.currentSongIndex <= 0;
                    nextBtn.disabled = !window.currentSongList || window.currentSongIndex >= window.currentSongList.length - 1;
                }
            })
            .catch(err => {
                console.error('Lỗi khi cập nhật trạng thái nút:', err);
                // Fallback với window.currentSongList
                prevBtn.disabled = !window.currentSongList || window.currentSongIndex <= 0;
                nextBtn.disabled = !window.currentSongList || window.currentSongIndex >= window.currentSongList.length - 1;
            });
    }
    
    window.playSongFromList = function(songList, index) {
        if (!songList || !songList[index]) return;
        // Nếu có .song-item trên trang, trigger click để đồng bộ mọi thứ
        const allItems = Array.from(document.querySelectorAll('.song-item'));
        if (allItems.length > 0 && allItems[index]) {
            allItems[index].click();
            return;
        }
        // Nếu không có .song-item (ví dụ ở trang home), fallback về phát nhạc trực tiếp
        const s = songList[index];
        const url = '<%= request.getContextPath() %>/play?file=' + encodeURIComponent(s.filePath);
        playSong(url, s.title, s.artist);
        
        // Cập nhật trạng thái nút sau khi phát
        setTimeout(updateNavigationButtons, 100);
    };
    
function fetchUpNextSongs() {
    fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
        .then(res => res.json())
        .then(data => {
            const upNextList = document.getElementById('upNextList');
            if (!upNextList) return;

            upNextList.innerHTML = '';

            if (!data.queue || data.queue.length === 0) {
                upNextList.innerHTML = '<p style="color:gray">Không có bài hát trong queue.</p>';
                return;
            }

            // Hiển thị tất cả bài hát trong queue
            data.queue.forEach(song => {
                const item = document.createElement('div');
                item.className = 'queue-item media-info';
                item.innerHTML = `
                    <img src="<%= request.getContextPath() %>/songImages/${song.title.replaceAll(' ', '_')}.jpg" class="media-thumbnail" onerror="this.src='https://via.placeholder.com/60x60/333333/ffffff?text=♪'" />
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

// Cập nhật queue khi click vào nút queue
function updateQueueDisplay() {
    fetch('<%= request.getContextPath() %>/queue?action=getCurrentQueue')
        .then(res => res.json())
        .then(data => {
            // Cập nhật thông tin bài hát đang phát
            if (data.nowPlaying) {
                const nowPlayingTitle = document.getElementById('nowPlayingTitle');
                const nowPlayingArtist = document.getElementById('nowPlayingArtist');
                const nowPlayingThumbnail = document.getElementById('nowPlayingThumbnail');
                
                if (nowPlayingTitle) nowPlayingTitle.textContent = data.nowPlaying.title || "Chưa có bài hát";
                if (nowPlayingArtist) nowPlayingArtist.textContent = data.nowPlaying.artist || "Không rõ nghệ sĩ";
                if (nowPlayingThumbnail) {
                    const imgName = toImageFileName(data.nowPlaying.title);
                    nowPlayingThumbnail.src = '<%= request.getContextPath() %>/songImages/' + imgName;
                    nowPlayingThumbnail.onerror = () => {
                        nowPlayingThumbnail.src = '<%= request.getContextPath() %>/songImages/default.jpg';
                    };
                }
            }
            
            // Cập nhật danh sách tiếp theo
            fetchUpNextSongs();
        })
        .catch(err => {
            console.error('Lỗi khi cập nhật queue:', err);
        });
}

document.addEventListener('DOMContentLoaded', function() {
    // Cập nhật queue khi mở panel
    const queueBtn = document.getElementById('queueBtn');
    if (queueBtn) {
        queueBtn.addEventListener('click', function() {
            // Đợi một chút để panel mở rồi mới cập nhật
            setTimeout(updateQueueDisplay, 100);
        });
    }
    
    // Cập nhật ban đầu
    updateQueueDisplay();
});

function updateQueueList(data) {
    const queueList = document.getElementById('upNextList');
    if (!queueList) return;
    queueList.innerHTML = '';
    data.forEach(song => {
        const songItem = document.createElement('div');
        songItem.classList.add('queue-item');
        songItem.innerHTML = `
            <div class="media-details">
                <h3>${song.title || "Không có tiêu đề"}</h3>
                <p>${song.artist || "Không rõ nghệ sĩ"}</p>
                ${song.hotTrend ? '<span class="hot-trend">Hot Trend</span>' : ''}
            </div>
        `;
        queueList.appendChild(songItem);
    });
}

// Khi trang load, tự động lấy queue phù hợp (artist hoặc hotTrend)
document.addEventListener('DOMContentLoaded', function() {
    // Nếu muốn lấy queue cho artist:
    fetchQueue('artist');
    // Nếu muốn lấy queue cho hotTrend, thay bằng:
    // fetchQueue('hotTrend');
});

function setQueueAndPlay(songList, startIndex) {
    fetch('/setQueue', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({queue: songList, startIndex: startIndex})
    }).then(() => {
        // Sau khi lưu queue thành công, reload hoặc fetch lại queue để hiển thị
        fetchQueue('artist'); // hoặc 'hotTrend' tùy trang
        // Optionally: play bài hát đầu tiên
    });
}
</script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">