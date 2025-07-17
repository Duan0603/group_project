<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Kết quả thanh toán Premium</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
<div class="container mt-5">
    <div class="card">
        <div class="card-body text-center">
            <h2>Kết quả thanh toán Premium</h2>
            <c:if test="${not empty message}">
                <div class="alert alert-success mt-3">${message}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger mt-3">${error}</div>
            </c:if>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary mt-4">Về trang chủ</a>
        </div>
    </div>
</div>
</body>
</html> 