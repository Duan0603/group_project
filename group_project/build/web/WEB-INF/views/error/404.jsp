<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>404 - Page Not Found</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            body {
                height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(120deg, #89f7fe 0%, #66a6ff 100%);
            }
            .error-container {
                text-align: center;
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 0 20px rgba(0,0,0,0.1);
            }
            .error-code {
                font-size: 120px;
                color: #66a6ff;
                font-weight: bold;
                line-height: 1;
            }
            .error-message {
                font-size: 24px;
                color: #333;
                margin: 20px 0;
            }
            .error-description {
                color: #666;
                margin-bottom: 30px;
            }
            .btn-home {
                background: #66a6ff;
                border: none;
                padding: 10px 30px;
            }
            .btn-home:hover {
                background: #5590e6;
            }
        </style>
    </head>
    <body>
        <div class="error-container">
            <div class="error-code">404</div>
            <div class="error-message">Page Not Found</div>
            <div class="error-description">
                The page you are looking for might have been removed, <br>
                had its name changed, or is temporarily unavailable.
            </div>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary btn-home">
                <i class="fas fa-home"></i> Go Home
            </a>
        </div>
    </body>
</html> 