<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Quên mật khẩu</title>
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
        </style>
    </head>
    <body>
        <%
            String email = request.getParameter("email") != null ? request.getParameter("email") : "";
            String message = (String) request.getAttribute("message");
            String alertClass = "";
            if (message != null) {
                alertClass = message.toLowerCase().contains("không") ? "alert-danger" : "alert-success";
            }
        %>
        <div class="container mt-5">
            <div class="card">
                <div class="card-header">
                    <span class="main-title">Quên mật khẩu</span>
                </div>
                <div class="card-body">
                    <form method="post" action="forgot-password">
                        <div class="form-group mb-3">
                            <label for="email" class="form-label w-100">Nhập email của bạn</label>
                            <input type="email" class="form-control" id="email" name="email" required value="<%= email%>">
                        </div>
                        <button type="submit" class="btn btn-pink"> Gửi yêu cầu</button>
                    </form>

                    <% if (message != null) {%>
                    <div class="alert <%= alertClass%> mt-3">
                        <%= message%>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>
    </body>
</html>
