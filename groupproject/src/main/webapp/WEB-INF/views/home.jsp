<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("user");
    String displayName = (user != null ? user.getUsername() : "");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Trang chủ nghe nhạc</title>
        <meta charset="UTF-8">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background: #181818;
                color: #fff;
                min-height: 100vh;
            }
            .navbar {
                background: #222;
                border-bottom: 2px solid #e84393;
            }
            .navbar-brand {
                color: #e84393 !important;
                font-weight: bold;
                font-size: 2rem;
                letter-spacing: 2px;
            }
            .nav-link, .navbar-nav .nav-link.active {
                color: #fff !important;
                font-weight: 500;
            }
            .nav-link:hover {
                color: #e84393 !important;
            }
            .btn-pink {
                background: #e84393;
                color: #fff;
                border: none;
            }
            .btn-pink:hover {
                background: #ff69b4;
                color: #fff;
            }
            .main-title {
                font-size: 2.5rem;
                font-weight: bold;
                color: #e84393;
                margin-top: 60px;
            }
            .card {
                background: #232323;
                border: none;
                border-radius: 20px;
                box-shadow: 0 4px 24px rgba(232,67,147,0.1);
            }
        </style>
    </head>
    <body>
        <nav class="navbar navbar-expand-lg">
            <div class="container">
                <a class="navbar-brand" href="<%=request.getContextPath()%>/home">Pinkify</a>
                <div class="collapse navbar-collapse justify-content-end">
                    <ul class="navbar-nav">

                        <% if (user == null) {%>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/login">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/signup">Signup</a>
                        </li>
                        <% } else {%>

                        <li class="nav-item">
                            <span class="nav-link">Hello <%= displayName%></span>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%=request.getContextPath()%>/logout">Logout</a>
                        </li>
                        <% }%>

                    </ul>
                </div>
            </div>
        </nav>

        <div class="container text-center">
            <div class="main-title">Chào mừng bạn đến với Pinkify!</div>
            <p class="mt-3" style="color:#ff69b4;">Hãy đăng nhập để trải nghiệm nghe nhạc với tone màu hồng hiện đại.</p>
        </div>
    </body>
</html>