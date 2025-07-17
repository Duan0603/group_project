<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    model.User user = (model.User) session.getAttribute("user");
    String avatarInitial = "U";
    if (user != null && user.getUsername() != null && !user.getUsername().isEmpty()) {
        avatarInitial = user.getUsername().substring(0, 1).toUpperCase();
    }
%>

<!-- Bootstrap & FontAwesome -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<style>
    .navbar {
        background: #111;
    }

    .navbar .navbar-brand {
        color: #e84393 !important;
        font-weight: bold;
        font-size: 2rem;
        letter-spacing: 2px;
    }

    .custom-search-bar {
        background-color: #1f1f1f;
        border-radius: 30px;
        padding: 6px 12px;
        display: flex;
        align-items: center;
        gap: 10px;
        width: 100%;
        max-width: 600px;
        border: 1px solid #333;
        margin-top: 2px;
    }

    .search-box {
        background-color: #1f1f1f;
        border-radius: 30px;
        flex-grow: 1;
        display: flex;
        align-items: center;
        padding: 6px 12px;
        gap: 10px;
        border: 1px solid #333;
    }

    .search-box input {
        background: transparent;
        border: none;
        color: white;
        flex-grow: 1;
        outline: none;
        font-size: 0.9rem;
        padding: 4px 2px;
    }

    .search-box input::placeholder {
        color: #aaa;
    }

    .icon-btn {
        width: 36px;
        height: 36px;
        background-color: #2b2b2b;
        border-radius: 50%;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        text-decoration: none;
        transition: 0.2s;
    }

    .icon-btn:hover {
        background-color: #444;
        color: #e84393;
    }

    .navbar .nav-link {
        color: #fff !important;
        font-weight: 500;
        padding: 8px 15px;
        border-radius: 20px;
        transition: background-color 0.3s, color 0.3s;
        text-decoration: none;
    }

    .navbar .nav-link:hover {
        background-color: #e84393;
        color: #fff !important;
    }

    .btn-pill {
        border-radius: 999px;
        padding: 6px 16px;
        font-weight: 500;
    }

    .user-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: #e84393;
        color: black;
        font-weight: bold;
        font-size: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
    }
    
    .dropdown-item.logout-item {
    color: white !important;
    font-weight: 500;
}

.dropdown-item.logout-item:hover {
    background-color: #e84393;
    color: white !important;
}
</style>

<nav class="navbar navbar-expand-lg px-3">
    <div class="d-flex w-100 align-items-center justify-content-between gap-3 flex-wrap">

        <!-- Logo -->
        <a class="navbar-brand mb-2 mb-lg-0" href="${pageContext.request.contextPath}/home">Pinkify</a>

        <!-- Search bar -->
        <div class="custom-search-bar flex-grow-1 mx-2" style="min-width: 250px;">
            <a href="${pageContext.request.contextPath}/home" class="icon-btn" title="Trang chủ">
                <i class="fas fa-home"></i>
            </a>
            <div class="search-box flex-grow-1">
                <i class="fas fa-search"></i>
                <input type="text" placeholder="Bạn muốn phát nội dung gì?">
                <a href="${pageContext.request.contextPath}/genres" class="icon-btn" title="Duyệt thể loại">
                    <i class="fas fa-layer-group"></i>
                </a>
            </div>
        </div>

        <!-- Menu bên phải -->
        <div class="d-flex align-items-center gap-2 flex-shrink-0 flex-wrap">

            <li class="nav-item">
                <form action="payos-premium" method="get" style="display:inline;">
                    <button type="submit" class="btn btn-warning" style="margin-left: 10px;">Premium</button>
                </form>
            </li>
            <a class="nav-link" href="#">Hỗ&nbsp;trợ</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/signup">Đăng&nbsp;ký</a>

            <c:choose>
                <c:when test="${user != null}">
                    <!-- Nếu đã đăng nhập thì hiện chuông + avatar -->
                    <button class="icon-btn" title="Thông báo">
                        <i class="fas fa-bell"></i>
                    </button>
       <div class="dropdown">
    <div class="user-avatar" id="userMenu" data-bs-toggle="dropdown" aria-expanded="false" title="${user.username}" style="cursor: pointer;">
        <%= avatarInitial %>
    </div>
    <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end mt-2" aria-labelledby="userMenu">
       <li><a class="dropdown-item logout-item" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
    </ul>
</div>               </c:when>
                <c:otherwise>
                    <!-- Nếu chưa đăng nhập thì hiện nút đăng nhập -->
                    <a class="btn btn-light text-dark btn-pill" href="${pageContext.request.contextPath}/login">Đăng&nbsp;nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>
