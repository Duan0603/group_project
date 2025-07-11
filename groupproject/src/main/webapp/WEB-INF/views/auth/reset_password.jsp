<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Đặt lại mật khẩu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

        <style>
            body {
                background: #181818;
                color: #fff;
            }
            .card {
                background: #232323;
                border-radius: 20px;
                box-shadow: 0 4px 24px rgba(232,67,147,0.1);
                border: none;
                max-width: 400px;
                margin: 0 auto;
            }
            .card-header {
                background: none;
                border-bottom: none;
                padding: 24px 32px 0;
                text-align: center;
            }
            .card-body {
                padding: 24px 32px 32px;
            }
            .form-label {
                color: white;
                margin-bottom: 8px;
                font-size: 0.875rem;
            }
            .main-title {
                color: #e84393;
                font-weight: bold;
                font-size: 2rem;
                display: inline-block;
                width: 100%;
                text-align: center;
            }
            .btn-pink {
                background: #e84393;
                color: #fff;
                border: none;
                padding: 8px 12px;
                font-weight: bold;
                height: 38px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-top: 6px;
                border-radius: 4px;
                width: 336px;
            }
            .btn-pink:hover {
                background: #e84393;
                opacity: 0.9;
                color: #fff;
            }
            .form-control {
                width: 336px;
                height: 38px;
                padding: 8px 12px;
                background: white;
                border: none;
                border-radius: 4px;
                font-size: 0.875rem;
                color: #000;
            }
            .form-control::placeholder {
                color: rgba(0, 0, 0, 0.6);
                font-size: 0.875rem;
            }
            .form-control:focus {
                box-shadow: none;
                border: 1px solid #e84393;
                outline: none;
                background: white;
            }
            .btn-login-back {
                color: #fff;
                border-color: #fff;
                transition: color 0.2s ease, border-color 0.2s ease;
            }
            .btn-login-back:hover {
                color: #e84393 !important;
                border-color: #e84393 !important;
                background-color: transparent !important;
                text-decoration: none;
            }
            .password-toggle {
                position: absolute;
                top: 38px;
                right: 12px;
                cursor: pointer;
                color: #888;
                z-index: 2;
            }
            .password-toggle:hover {
                color: #e84393;
            }
        </style>
    </head>
    <body>
        <%
            String token = (String) request.getAttribute("token");
            if (token == null) {
                token = request.getParameter("token");
            }

            String message = (String) request.getAttribute("message");
            String alertClass = "alert-info";
            if (message != null) {
                if (message.toLowerCase().contains("thành công")) {
                    alertClass = "alert-success";
                } else if (message.toLowerCase().contains("không") || message.toLowerCase().contains("hết hạn")) {
                    alertClass = "alert-danger";
                }
            }
        %>

        <div class="container mt-5">
            <div class="card">
                <div class="card-header">
                    <span class="main-title">Đặt lại mật khẩu</span>
                </div>
                <div class="card-body">
                    <form method="post" action="reset-password">
                        <input type="hidden" name="token" value="<%= token%>" />

                        <div class="form-group mb-3 position-relative">
                            <label for="password" class="form-label w-100">Mật khẩu mới</label>
                            <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu mới" required>
                            <i class="fa-solid fa-eye-slash password-toggle" onclick="togglePassword('password', this)"></i>
                        </div>

                        <div class="form-group mb-3 position-relative">
                            <label for="confirmPassword" class="form-label w-100">Xác nhận mật khẩu</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu" required>
                            <i class="fa-solid fa-eye-slash password-toggle" onclick="togglePassword('confirmPassword', this)"></i>
                        </div>

                        <button type="submit" class="btn btn-pink">Đặt lại mật khẩu</button>
                    </form>

                    <a href="<%= request.getContextPath()%>/login"
                       class="btn btn-outline-light mt-2 btn-login-back"
                       style="width: 336px; transition: 0.2s;">
                        Quay về đăng nhập
                    </a>

                    <% if (message != null) {%>
                    <div class="alert <%= alertClass%> mt-3">
                        <%= message%>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>

        <script>
            function togglePassword(fieldId, iconElement) {
                const input = document.getElementById(fieldId);
                const isHidden = input.type === "password";
                input.type = isHidden ? "text" : "password";
                iconElement.classList.toggle("fa-eye");
                iconElement.classList.toggle("fa-eye-slash");
            }
        </script>
    </body>
</html>