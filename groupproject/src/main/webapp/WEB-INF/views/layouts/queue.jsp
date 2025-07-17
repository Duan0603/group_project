<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Queue</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            height: 100vh;
            background-color: #181818;
            display: flex;
            justify-content: flex-end;
        }

        .queue-sidebar {
            width: 360px;
            background-color: #0d0d0d;
            color: white;
            padding: 16px;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            box-shadow: -2px 0 10px rgba(0,0,0,0.8);
        }

        .queue-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .queue-header span {
            font-size: 16px;
            font-weight: bold;
            color: #ff40b0;
        }

        .close-btn {
            background: none;
            border: none;
            font-size: 20px;
            color: #ff40b0;
            cursor: pointer;
        }

        .queue-content {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
        }

        .queue-content i.queue-icon {
            font-size: 28px;
            margin-bottom: 8px;
            color: #ff40b0;
        }

        .queue-content h5 {
            color: #ff40b0;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 8px;
        }

        .queue-content p {
            font-size: 13px;
            color: #ccc;
            margin-bottom: 20px;
            padding: 0 12px;
        }

        .find-btn {
            background-color: #ff40b0;
            border: none;
            padding: 10px 18px;
            border-radius: 20px;
            font-weight: bold;
            color: white;
            cursor: pointer;
            font-size: 14px;
        }

        .menu-btn {
            position: fixed;
            top: 16px;
            right: 370px;
            font-size: 20px;
            color: #ff40b0;
            background: none;
            border: none;
            cursor: pointer;
            z-index: 3000;
        }

        .song-item {
            text-align: left;
            width: 100%;
            padding: 8px 0;
            border-bottom: 1px solid #2a2a2a;
        }

        .song-item strong {
            color: #ff40b0;
            font-size: 14px;
        }

        .song-item span {
            color: #b3b3b3;
            font-size: 13px;
        }
    </style>
</head>
<body>

    <!-- Queue Open Button -->
    <button class="menu-btn" onclick="toggleQueue()" title="Open queue">
        <i class="fas fa-bars"></i>
    </button>

    <!-- Queue Sidebar -->
    <div id="queuePanel" class="queue-sidebar" style="display: none;">
        <div class="queue-header">
            <span>Queue</span>
            <button onclick="toggleQueue()" class="close-btn">×</button>
        </div>
        <div class="queue-content" id="queueContent">
            <!-- Rendered by JS -->
        </div>
    </div>

    <script>
        const queueList = JSON.parse(sessionStorage.getItem("songQueue") || "[]");

        function toggleQueue() {
            const panel = document.getElementById("queuePanel");
            panel.style.display = panel.style.display === 'flex' ? 'none' : 'flex';
        }

        function renderQueue() {
            const content = document.getElementById("queueContent");
            content.innerHTML = "";

            if (queueList.length === 0) {
                content.innerHTML = `
                    <i class="fas fa-bars queue-icon"></i>
                    <h5>Add to queue</h5>
                    <p>Tap "Add to queue" from a song menu to see it here.</p>
                    <button class="find-btn">Find something to play</button>
                `;
            } else {
                queueList.forEach(song => {
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

        window.addEventListener("DOMContentLoaded", renderQueue);
    </script>

</body>
</html>