<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Đăng ký - Pinkify</title>
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
                margin: 0;
                text-align: center;
                display: block;
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
                margin-top: 16px;
                width: 336px;
                border-radius: 4px;
            }
            .btn-pink:hover {
                background: #ff69b4;
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
            .form-group {
                display: flex;
                flex-direction: column;
                align-items: center;
                margin-bottom: 8px;
                position: relative;
            }
            .password-requirements {
                width: 336px;
                margin: 8px auto;
                font-size: 0.875rem;
                color: #a7a7a7;
            }
            .requirement {
                display: flex;
                align-items: center;
                margin: 4px 0;
            }
            .requirement.valid {
                color: #e84393;
            }
            .requirement i {
                margin-right: 8px;
                font-size: 16px;
            }
            .invalid-feedback {
                color: #e84393;
                font-size: 0.875rem;
                margin-top: 4px;
                width: 336px;
                text-align: left;
            }
            .check-icon {
                color: #e84393;
                margin-right: 8px;
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
            .login-text {
                color: #a7a7a7;
                margin-top: 24px;
                text-align: center;
            }
            .login-link {
                color: #fff;
                text-decoration: underline;
                font-weight: bold;
            }
            .login-link:hover {
                color: #e84393;
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
        </style>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    </head>
    <body>
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <span class="main-title">Đăng ký Pinkify</span>
                        </div>
                        <div class="card-body">
                            <form method="post" action="signup" id="signupForm" novalidate autocomplete="off">
                                <div class="form-group">
                                    <label for="username" class="form-label w-100">Tên đăng nhập</label>
                                    <input type="text" class="form-control" id="username" name="username" 
                                           placeholder="Tên đăng nhập" required pattern="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{3,}$"
                                           autocomplete="off" autocorrect="off" autocapitalize="none" spellcheck="false">
                                    <div class="invalid-feedback">
                                        Tên đăng nhập phải có ít nhất 3 ký tự, bao gồm cả chữ và số
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="email" class="form-label w-100">Email</label>
                                    <input type="email" class="form-control" id="email" name="email" 
                                           placeholder="Email" required>
                                    <div class="invalid-feedback">
                                        Email không hợp lệ hoặc đã được sử dụng
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="password" class="form-label w-100">Mật khẩu</label>
                                    <input type="password" class="form-control" id="password" name="password" 
                                           placeholder="Mật khẩu" required>
                                    <span class="password-toggle" onclick="togglePassword('password')">
                                        <i class="fas fa-eye"></i>
                                    </span>
                                </div>

                                <div class="password-requirements">
                                    <div class="requirement" id="req-length">
                                        <i class="fas fa-circle"></i> 10 ký tự
                                    </div>
                                    <div class="requirement" id="req-letter">
                                        <i class="fas fa-circle"></i> 1 chữ cái
                                    </div>
                                    <div class="requirement" id="req-special">
                                        <i class="fas fa-circle"></i> 1 chữ số hoặc ký tự đặc biệt (ví dụ: # ? ! &)
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="confirmPassword" class="form-label w-100">Xác nhận mật khẩu</label>
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                           placeholder="Xác nhận mật khẩu" required>
                                    <span class="password-toggle" onclick="togglePassword('confirmPassword')">
                                        <i class="fas fa-eye"></i>
                                    </span>
                                    <div class="invalid-feedback">
                                        Mật khẩu xác nhận không khớp
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-pink">Đăng ký</button>
                            </form>

                            <div class="or-divider">
                                hoặc
                            </div>

                            <a href="login-google" class="btn-google">
                                <img src="https://www.google.com/favicon.ico" alt="Google icon">
                                Đăng ký bằng Google
                            </a>

                            <a href="facebook-auth" class="btn-google">
                                <img src="https://www.facebook.com/favicon.ico" alt="Facebook icon">
                                Đăng ký bằng Facebook
                            </a>
                            <div class="login-text">
                                Bạn đã có tài khoản? <a href="login" class="login-link">Đăng nhập tại đây.</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const form = document.getElementById('signupForm');
                const username = document.getElementById('username');
                const email = document.getElementById('email');
                const password = document.getElementById('password');
                const confirmPassword = document.getElementById('confirmPassword');

                const reqLength = document.getElementById('req-length');
                const reqLetter = document.getElementById('req-letter');
                const reqSpecial = document.getElementById('req-special');

                function validatePassword() {
                    const pass = password.value;

                    if (pass.length >= 10) {
                        reqLength.classList.add('valid');
                        reqLength.querySelector('i').className = 'fas fa-check-circle check-icon';
                    } else {
                        reqLength.classList.remove('valid');
                        reqLength.querySelector('i').className = 'fas fa-circle';
                    }

                    if (/[A-Za-z]/.test(pass)) {
                        reqLetter.classList.add('valid');
                        reqLetter.querySelector('i').className = 'fas fa-check-circle check-icon';
                    } else {
                        reqLetter.classList.remove('valid');
                        reqLetter.querySelector('i').className = 'fas fa-circle';
                    }

                    if (/[\d\W]/.test(pass)) {
                        reqSpecial.classList.add('valid');
                        reqSpecial.querySelector('i').className = 'fas fa-check-circle check-icon';
                    } else {
                        reqSpecial.classList.remove('valid');
                        reqSpecial.querySelector('i').className = 'fas fa-circle';
                    }
                }

                username.addEventListener('input', function () {
                    const isValid = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{3,}$/.test(this.value);
                    this.classList.toggle('is-invalid', !isValid);
                });

                email.addEventListener('input', function () {
                    const isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.value);
                    this.classList.toggle('is-invalid', !isValid);
                });

                password.addEventListener('input', validatePassword);

                confirmPassword.addEventListener('input', function () {
                    const isValid = this.value === password.value;
                    this.classList.toggle('is-invalid', !isValid);
                });

                form.addEventListener('submit', async function (e) {
                    e.preventDefault();

                    if (!username.value.match(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{3,}$/)) {
                        username.classList.add('is-invalid');
                        return;
                    }

                    if (!email.value.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
                        email.classList.add('is-invalid');
                        return;
                    }

                    try {
                        const response = await fetch('check-email?email=' + encodeURIComponent(email.value));
                        const data = await response.json();
                        if (data.exists) {
                            email.classList.add('is-invalid');
                            return;
                        }
                    } catch (error) {
                        console.error('Error checking email:', error);
                    }

                    if (
                            password.value.length < 10 ||
                            !password.value.match(/[A-Za-z]/) ||
                            !password.value.match(/[\d\W]/)
                            ) {
                        password.classList.add('is-invalid');
                        return;
                    }

                    if (password.value !== confirmPassword.value) {
                        confirmPassword.classList.add('is-invalid');
                        return;
                    }

                    this.submit();
                });

                window.togglePassword = function (inputId) {
                    const input = document.getElementById(inputId);
                    const icon = input.nextElementSibling.querySelector('i');

                    if (input.type === 'password') {
                        input.type = 'text';
                        icon.className = 'fas fa-eye-slash';
                    } else {
                        input.type = 'password';
                        icon.className = 'fas fa-eye';
                    }
                };
            });
        </script>
    </body>
</html> 