<%@ page contentType="text/html" pageEncoding="UTF-8"%>
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
        }
        .card-header {
            background: none;
            border-bottom: none;
        }
         .form-label{
            color: white;
        }
        .main-title {
            color: #e84393;
            font-weight: bold;
            font-size: 2rem;
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
        a {
            color: #e84393;
        }
        a:hover {
            color: #ff69b4;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-4">
                <div class="card p-4">
                    <div class="card-header text-center">
                        <span class="main-title">Đăng nhập Pinkify</span>
                    </div>
                    <div class="card-body">
                        <form method="post" action="login">
                            <div class="mb-3">
                                <label for="username" class="form-label">Tên đăng nhập</label>
                                <input type="text" class="form-control" id="username" name="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Mật khẩu</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger">${error}</div>
                            </c:if>
                            <button type="submit" class="btn btn-pink w-100">Đăng nhập</button>
                        </form>
                        <div class="mt-3 text-center">
                            <a href="signup">Chưa có tài khoản? Đăng ký ngay</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 