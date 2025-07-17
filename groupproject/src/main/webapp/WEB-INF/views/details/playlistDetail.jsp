<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết Playlist</title>
    </head>
    <body style="background:#121212; color:white; font-family:sans-serif;">
        <h2 style="margin:16px;">📃 Danh sách bài hát trong Playlist</h2>

        <!-- Hiển thị tên playlist -->
        <h3>${playlist.name}</h3>
        <p>${playlist.description}</p>

        <!-- Hiển thị danh sách các bài hát -->
        <c:forEach var="song" items="${songs}">
            <div style="margin: 12px; padding: 12px; background: #181818; border-radius: 8px;">
                <div><strong>${song.title}</strong> - ${song.artist}</div>
                <audio controls src="${pageContext.request.contextPath}/play?file=${song.filePath}"></audio>
            </div>
        </c:forEach>
    </body>
</html>
