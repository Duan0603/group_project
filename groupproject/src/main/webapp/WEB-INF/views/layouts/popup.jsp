<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Popup chat Gemini AI --%>
<style>
#gemini-popup-btn {
    position: fixed;
    bottom: 80px;
    right: 32px;
    z-index: 9999;
    background: #e84393;
    color: #fff;
    border: none;
    border-radius: 50%;
    width: 56px;
    height: 56px;
    font-size: 28px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.2);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
}
#gemini-popup-chat {
    position: fixed;
    bottom: 148px;
    right: 32px;
    width: 340px;
    max-width: 90vw;
    background: #232323;
    color: #fff;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.25);
    z-index: 10000;
    display: none;
    flex-direction: column;
    overflow: hidden;
}
#gemini-popup-header {
    background: #e84393;
    padding: 12px 16px;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
#gemini-popup-close {
    background: none;
    border: none;
    color: #fff;
    font-size: 22px;
    cursor: pointer;
}
#gemini-popup-messages {
    padding: 16px;
    height: 220px;
    overflow-y: auto;
    background: #232323;
    font-size: 15px;
}
#gemini-popup-input {
    display: flex;
    border-top: 1px solid #333;
    background: #232323;
}
#gemini-popup-textarea {
    flex: 1;
    padding: 10px;
    border: none;
    background: #232323;
    color: #fff;
    resize: none;
    font-size: 15px;
    outline: none;
}
#gemini-popup-send {
    background: #e84393;
    color: #fff;
    border: none;
    padding: 0 18px;
    font-size: 16px;
    cursor: pointer;
    border-radius: 0 0 12px 0;
}
#gemini-popup-messages span {
    color: #fff !important;
    background: #e84393 !important;
}
</style>
<%-- Không hiển thị popup trên admin.jsp --%>
<c:if test="${pageContext.request.servletPath ne '/WEB-INF/views/admin.jsp'}">
    <button id="gemini-popup-btn" title="Trợ lý AI Gemini">💬</button>
    <div id="gemini-popup-chat">
        <div id="gemini-popup-header">
            Gemini AI
            <button id="gemini-popup-close">&times;</button>
        </div>
        <div id="gemini-popup-messages"></div>
        <form id="gemini-popup-input" onsubmit="return sendGeminiMessage();">
            <input id="gemini-popup-textarea" type="text" placeholder="Nhập yêu cầu tạo playlist, xóa playlist..." required style="flex:1;padding:10px;border:none;background:#232323;color:#fff;font-size:15px;outline:none;" />
            <button type="submit" id="gemini-popup-send">Gửi</button>
        </form>
    </div>
</c:if>
<script>
    const geminiBtn = document.getElementById('gemini-popup-btn');
    const geminiChat = document.getElementById('gemini-popup-chat');
    const geminiClose = document.getElementById('gemini-popup-close');
    const geminiMessages = document.getElementById('gemini-popup-messages');
    const geminiTextarea = document.getElementById('gemini-popup-textarea');
    
    // Lưu lịch sử tin nhắn để hiển thị lại khi mở chat
    let geminiChatHistory = [];
    
    // Hàm này chỉ dùng để vẽ lại toàn bộ lịch sử khi mở popup
    function renderGeminiHistory() {
        geminiMessages.innerHTML = '';
        geminiChatHistory.forEach(msg => {
            addGeminiMessage(msg.content, msg.isUser, true); // true để không push lại vào history
        });
    }
    
    // Hàm thêm một tin nhắn mới vào giao diện
    function addGeminiMessage(content, isUser, skipHistoryPush = false) {
        if (!content || typeof content !== 'string' || content.trim() === '') return null;
    
        const msgDiv = document.createElement('div');
        msgDiv.style.margin = '8px 0';
        msgDiv.style.textAlign = isUser ? 'right' : 'left';
    
        const msgSpan = document.createElement('span');
        msgSpan.style.padding = '6px 12px';
        msgSpan.style.display = 'inline-block';
        if (isUser) {
            msgSpan.style.background = '#e84393';
            msgSpan.style.color = '#fff';
            msgSpan.style.borderRadius = '8px 8px 0 8px';
        } else {
            msgSpan.style.background = '#333';
            msgSpan.style.borderRadius = '8px 8px 8px 0';
        }
        msgSpan.innerHTML = content; // Dùng innerHTML để render các thẻ <i>, <b> nếu có
    
        msgDiv.appendChild(msgSpan);
        geminiMessages.appendChild(msgDiv);
    
        // Tự động cuộn xuống cuối
        geminiMessages.scrollTop = geminiMessages.scrollHeight;
    
        // Chỉ thêm vào lịch sử nếu đây là tin nhắn mới
        if (!skipHistoryPush) {
            geminiChatHistory.push({ content, isUser });
        }
    
        return msgDiv; // Trả về element để có thể xóa (dùng cho tin nhắn loading)
    }
    
    
    function sendGeminiMessage() {
        const text = geminiTextarea.value.trim();
        if (!text) return false;
    
        // 1. Hiển thị ngay tin nhắn của người dùng
        addGeminiMessage(text, true);
        geminiTextarea.value = '';
        geminiTextarea.focus();
    
        // 2. Hiển thị tin nhắn "đang xử lý" để người dùng biết AI đang hoạt động
        const loadingMessage = addGeminiMessage('<i>Đang xử lý...</i>', false);
    
        // 3. Gửi yêu cầu đến server
        fetch('geminiPlaylist', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'description=' + encodeURIComponent(text)
        })
        .then(res => {
            if (!res.ok) {
                throw new Error('Network response was not ok');
            }
            return res.json();
        })
        .then(data => {
            // 4. Xóa tin nhắn "đang xử lý"
            loadingMessage.remove();
            geminiChatHistory.pop(); // Xóa tin nhắn "Đang xử lý..." khỏi lịch sử
    
            // 5. Hiển thị phản hồi từ AI
            if (data.message) {
                addGeminiMessage(data.message, false);
            }
            if (data.info) {
                addGeminiMessage('<i>' + data.info + '</i>', false);
            }
        })
        .catch((err) => {
            // Xử lý khi có lỗi
            if (loadingMessage) {
                loadingMessage.remove();
                geminiChatHistory.pop();
            }
            addGeminiMessage('Lỗi kết nối hoặc có sự cố từ máy chủ.', false);
        });
    
        return false; // Ngăn form submit và reload trang
    }
    
    // Khởi tạo và các sự kiện
    if (geminiBtn) {
        geminiBtn.onclick = () => {
            geminiChat.style.display = 'flex';
            geminiBtn.style.display = 'none';
            renderGeminiHistory();
            geminiTextarea.focus();
        };
    }
    
    if (geminiClose) {
        geminiClose.onclick = () => {
            geminiChat.style.display = 'none';
            geminiBtn.style.display = 'flex';
        };
    }
    
    // Thêm tin nhắn chào mừng khi bắt đầu
    document.addEventListener('DOMContentLoaded', function() {
        if (geminiChatHistory.length === 0) {
           addGeminiMessage('Chào bạn, tôi có thể giúp gì cho bạn?', false);
        }
    });
    </script>