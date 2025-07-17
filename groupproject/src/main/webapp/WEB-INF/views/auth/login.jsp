<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Đăng nhập - Pinkify</title>
        <meta charset="UTF-8">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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
            .error-message {
                width: 336px;
                margin: 0 auto 16px auto;
                color: #ff4081;
                font-size: 0.875rem;
                text-align: center;
                padding: 8px 12px;
                background: rgba(255, 64, 129, 0.1);
                border-radius: 4px;
            }
            .signup-text {
                color: #a7a7a7;
                margin-top: 24px;
                text-align: center;
            }
            .signup-link {
                color: #fff;
                text-decoration: underline;
                font-weight: bold;
            }
            .signup-link:hover {
                color: #e84393;
            }
            .form-group {
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 8px;
            }
            .form-group.remember-me {
                align-items: flex-start;
                padding-left: 32px;
            }
            .form-group:last-of-type {
                margin-bottom: 8px;
            }
            .password-toggle {
                position: absolute;
                right: 12px;
                top: 38px;
                cursor: pointer;
                color: #666;
            }
            .password-toggle:hover {
                color: #e84393;
            }
            .remember-me-group {
                flex-direction: row;
                margin: 0px;
                align-items: flex-start;
                justify-content: flex-start;
                width: 336px;
                padding-bottom: 6px;
            }
            .remember-me-checkbox {
                margin-right: 8px;
            }
            .remember-me-label {
                color: white;
                margin: 0;
            }
            .password-group {
                position: relative;
            }
            /* Checkbox styling */
            .form-check-input {
                cursor: pointer;
            }
            .form-check-input:checked {
                background-color: #e84393;
                border-color: #e84393;
            }
            .form-check-input:focus {
                border-color: #e84393;
                box-shadow: 0 0 0 0.25rem rgba(232,67,147,0.25);
            }
            .btn-google {
                width: 336px;
                height: 40px;
                background: #202124;
                border: 1px solid #5f6368;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #fff;
                font-size: 0.875rem;
                font-weight: 500;
                text-decoration: none;
                transition: all 0.2s;
                margin-top: 16px;
                padding: 0 12px;
            }

            .btn-google:hover {
                background: #303134;
                color: #fff;
                text-decoration: none;
                border-color: #8e918f;
            }

            .btn-google img {
                width: 18px;
                height: 18px;
                margin-right: 24px;
            }

            .or-divider {
                display: flex;
                align-items: center;
                text-align: center;
                color: #a7a7a7;
                font-size: 0.875rem;
                margin: 16px 0;
            }

            .or-divider::before,
            .or-divider::after {
                content: '';
                flex: 1;
                border-bottom: 1px solid #404040;
            }

            .or-divider::before {
                margin-right: 16px;
            }

            .or-divider::after {
                margin-left: 16px;
            }

            .forgot-password-link {
                color: #e84393;
                font-weight: bold;
                text-decoration: underline;
                transition: color 0.2s;
                display: inline-block;
            }
            .forgot-password-link:hover {
                color: #ff69b4;
            }
            .forgot-password-container {
                text-align: right;
                margin-bottom: 4px;
            }

        </style>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <span class="main-title">Đăng nhập Pinkify</span>
                        </div>
                        <div class="card-body">
                            <%
                                String error = request.getParameter("error");
                                String errorMessage = null;

                                if ("like".equals(error)) {
                                    errorMessage = "Vui lòng đăng nhập để thích bài hát!";
                                } else if (request.getAttribute("error") != null) {
                                    errorMessage = (String) request.getAttribute("error");
                                }
                            %>

                            <% if (errorMessage != null) {%>
                            <div class="error-message">
                                <i class="fas fa-exclamation-circle"></i>
                                <%= errorMessage%>
                            </div>
                            <% }%>

                            <form method="post" action="login" id="loginForm">
                                <div class="form-group">
                                    <label for="username" class="form-label w-100">Tên đăng nhập</label>
                                    <input type="text" class="form-control" id="username" name="username" 
                                           placeholder="Email hoặc tên người dùng" required
                                           autocomplete="off"
                                           autocorrect="off"
                                           autocapitalize="none"
                                           spellcheck="false"
                                           value="${param.username}">
                                </div>
                                <div class="form-group password-group">
                                    <label for="password" class="form-label w-100">Mật khẩu</label>
                                    <input type="password" class="form-control" id="password" name="password" 
                                           placeholder="Mật khẩu" required>
                                    <span class="password-toggle" onclick="togglePassword()">
                                        <i class="fas fa-eye"></i>
                                    </span>
                                </div>
                                <div class="form-group remember-me-group">
                                    <input type="checkbox" class="form-check-input remember-me-checkbox" id="rememberMe" name="rememberMe">
                                    <label class="form-check-label remember-me-label" for="rememberMe">
                                        Ghi nhớ đăng nhập
                                    </label>
                                </div>
                                <div class="forgot-password-container">
                                    <a href="forgot-password" class="forgot-password-link">Quên mật khẩu?</a>
                                </div>
                                <button type="submit" class="btn btn-pink">Đăng nhập</button>
                            </form>

                            <div class="or-divider">
                                hoặc
                            </div>

                            <a href="login-google" class="btn-google">
                                <img src="https://www.google.com/favicon.ico" alt="Google icon">
                                Đăng nhập bằng Google
                            </a>

                            <a href="https://www.facebook.com/v20.0/dialog/oauth?client_id=724548546615720&redirect_uri=http://localhost:9999/groupproject/facebook-auth&scope=email"
                               class="btn-google btn-facebook">
                                <img src="https://www.facebook.com/favicon.ico" alt="Facebook icon">
                                Đăng nhập bằng Facebook
                            </a>

                            <div class="signup-text">
                                Bạn chưa có tài khoản? <a href="signup" class="signup-link">Đăng ký tại đây.</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function togglePassword() {
                const passwordInput = document.getElementById('password');
                const icon = document.querySelector('.password-toggle i');

                if (passwordInput.type === 'password') {
                    passwordInput.type = 'text';
                    icon.className = 'fas fa-eye-slash';
                } else {
                    passwordInput.type = 'password';
                    icon.className = 'fas fa-eye';
                }
            }
        </script>
    </body>
</html> 