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

            /* Nút âm lượng */
            .volume-control {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                background-color: #2d2d2d;
                padding: 10px;
                border-radius: 50px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }

            .control-btn {
                background-color: transparent;
                border: none;
                color: #e84393;
                cursor: pointer;
                padding: 8px;
                transition: transform 0.3s ease-in-out;
            }

            .control-btn:hover {
                transform: scale(1.1);
            }

            /* Đổi màu icon SVG khi hover */
            .control-btn:hover svg {
                fill: #e84393;
            }

            /* Thanh điều khiển âm lượng */
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

        <div id="queueRightPanel" class="queue-right-panel">
            <div class="queue-header" style="display:flex;justify-content:space-between;align-items:center;">
                <span style="font-weight:bold;font-size:16px;color:#ff40b0;">Danh sách chờ</span>
                <button onclick="toggleQueueRight()" style="background:none;border:none;font-size:20px;color:#ff40b0;cursor:pointer;">×</button>
            </div>
            <div class="queue-content" style="text-align:center;margin-top:20px;">
                <i class="fas fa-bars" style="font-size:28px;color:#ff40b0;margin-bottom:8px;"></i>
                <h5 style="color:#ff40b0;">Thêm vào danh sách chờ</h5>
                <p style="color:#bbb;font-size:13px;">Nhấn vào \"Thêm vào danh sách chờ\" từ menu của một bài để đưa vào đây</p>
                <button style="background-color:#ff40b0;border:none;padding:8px 16px;border-radius:18px;color:white;cursor:pointer;font-weight:bold;">Tìm nội dung để phát</button>
            </div>
        </div>
    </div>
    <div class="volume">
        <button class="control-btn" id="volumeBtn" title="Toggle Volume" style="margin-right: 8px;">
            <i class="fas fa-volume-up" id="volume-icon"></i>
        </button>
        <input type="range" id="volumeSlider" min="0" max="100" step="1" value="50">
    </div>
</div>

<!-- JS -->
<script>
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

        // Set new audio source
        audio.src = audioUrl;
        audio.play();

        // Cập nhật thông tin bài hát
        titleEl.textContent = title || "Chưa có bài hát";
        artistEl.textContent = artist || "Không rõ nghệ sĩ";

        // Xử lý ảnh từ tên bài hát
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
        const volumeIcon = document.getElementById('volume-icon');

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
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">