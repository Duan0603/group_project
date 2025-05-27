<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng ký tài khoản - Pinkify</title>
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
        .form-label{
            color: white;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-5">
                <div class="card p-4">
                    <div class="card-header text-center">
                        <span class="main-title">Đăng ký Pinkify</span>
                    </div>
                    <div class="card-body">
                        <form method="post" action="signup">
                            <div class="mb-3">
                                <label for="username" class="form-label">Tên Đăng Nhập</label>
                                <input type="text" class="form-control" id="username" name="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Mật Khẩu</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                            </div>
                            <div class="mb-3">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email" required>
                            </div>
                            <div class="mb-3">
                                <label for="fullName" class="form-label">Họ và tên</label>
                                <input type="text" class="form-control" id="fullName" name="fullName" required>
                            </div>
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger">${error}</div>
                            </c:if>
                            <c:if test="${not empty success}">
                                <div class="alert alert-success">${success}</div>
                            </c:if>
                            <button type="submit" class="btn btn-pink w-100">Đăng ký</button>
                        </form>
                        <div class="mt-3 text-center">
                            <a href="login">Đã có tài khoản? Đăng nhập</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 