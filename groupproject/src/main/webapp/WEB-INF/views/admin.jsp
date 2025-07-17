<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Pinkify</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #1a1a1a; color: #ff69b4; }
        .content { padding: 20px; background-color: #1a1a1a; }
        h2, h3, h5 { color: #ff69b4; }
        .sidebar { min-height: 100vh; background-color: #2d2d2d; padding: 20px; border-right: 1px solid #ff69b4; }
        .nav-link { color: #ff69b4; margin-bottom: 10px; border: 1px solid #ff69b4; border-radius: 5px; transition: all 0.3s ease; }
        .nav-link:hover { background-color: #ff69b4; color: #1a1a1a; transform: scale(1.05); }
        .nav-pills .nav-link.active, .nav-pills .show>.nav-link { background-color: #fd0d95; color: #1a1a1a; border-color: #ff69b4; }
        .card { background-color: #2d2d2d; border: 1px solid #ff69b4; transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(253, 13, 149, 0.2); }
        .card-title { color: #ff69b4; }
        .card.bg-primary { background-color: #ff69b4 !important; }
        .card.bg-success, .card.bg-warning, .card.bg-info { background-color: #2d2d2d !important; border: 1px solid #ff69b4; }
        .card.bg-primary .card-title, .card.bg-primary .card-text { color: #1a1a1a !important; }
        .text-white { color: #ff69b4 !important; }
        .table { --bs-table-color: #e0e0e0; --bs-table-bg: #2d2d2d; --bs-table-border-color: #444; --bs-table-striped-color: #e0e0e0; --bs-table-striped-bg: #343434; --bs-table-hover-color: #ffffff; --bs-table-hover-bg: #3f3f3f; color: var(--bs-table-color); }
        .table thead th { color: #ff69b4; border-bottom: 2px solid #ff69b4; }
        .badge.bg-success { background-color: #28a745 !important; color: white; }
        .badge.bg-danger { background-color: #dc3545 !important; color: white; }
        .badge.bg-info { background-color: #8A2BE2 !important; color: white; }
        .badge.bg-secondary { background-color: #6c757d !important; color: white; }
        .btn-primary { background-color: #ff69b4; border-color: #ff69b4; color: #1a1a1a; font-weight: bold; }
        .btn-primary:hover { background-color: #ff1493; border-color: #ff1493; color: #1a1a1a; }
        .btn-danger { font-weight: bold; }
        .modal-content { background-color: #2d2d2d; color: #e0e0e0; border: 1px solid #ff69b4;}
        .modal-header { border-bottom-color: #ff69b4; }
        .modal-footer { border-top-color: #ff69b4; }
        .form-control { background-color: #3f3f3f; color: #e0e0e0; border-color: #444; }
        .form-control:focus { background-color: #3f3f3f; color: #e0e0e0; border-color: #ff69b4; box-shadow: 0 0 0 0.25rem rgba(255,105,180,.25); }
        .form-label { color: #ff69b4; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-3 col-lg-2 sidebar">
                <h3 class="mb-4"><i class="fas fa-headphones-alt me-2"></i>Pinkify</h3>
                <div class="nav flex-column nav-pills">
                    <a class="nav-link active" href="#dashboard" data-bs-toggle="pill">
                        <i class="fas fa-chart-line me-2"></i>Dashboard
                    </a>
                    <a class="nav-link" href="#songs" data-bs-toggle="pill">
                        <i class="fas fa-music me-2"></i>Quản lý bài hát
                    </a>
                    <a class="nav-link" href="#accounts" data-bs-toggle="pill">
                        <i class="fas fa-users me-2"></i>Quản lý tài khoản
                    </a>
                    <a class="nav-link" href="#orders" data-bs-toggle="pill">
                        <i class="fas fa-shopping-cart me-2"></i>Đơn hàng
                    </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/logout" style="margin-top: 20px;">
                        <i class="fas fa-sign-out-alt me-2"></i>Đăng xuất
                    </a>
                </div>
            </div>

            <div class="col-md-9 col-lg-10 content">
                <div class="tab-content">
                    <div class="tab-pane fade show active" id="dashboard">
                        <h2>Dashboard</h2>
                        <div class="row mt-4">
                            <div class="col-md-3 mb-4">
                                <div class="card bg-primary text-white">
                                    <div class="card-body">
                                        <h5 class="card-title">Tổng đơn hàng</h5>
                                        <h2 class="card-text">${totalOrders}</h2>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 mb-4">
                                <div class="card bg-success text-white">
                                    <div class="card-body">
                                        <h5 class="card-title">Tổng người dùng</h5>
                                        <h2 class="card-text">${totalUsers}</h2>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 mb-4">
                                <div class="card bg-warning text-white">
                                    <div class="card-body">
                                        <h5 class="card-title">Tổng bài hát</h5>
                                        <h2 class="card-text">${totalSongs}</h2>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 mb-4">
                                <div class="card bg-info text-white">
                                    <div class="card-body">
                                        <h5 class="card-title">Doanh thu</h5>
                                        <h2 class="card-text">
                                            <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="" maxFractionDigits="0" />đ
                                        </h2>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row mt-4">
                             <div class="col-md-12">
                                <div class="card">
                                    <div class="card-body">
                                        <h5 class="card-title">Doanh thu theo tháng</h5>
                                        <canvas id="revenueChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="tab-pane fade" id="songs">
                        <h2>Quản lý bài hát</h2>
                        <div class="mt-4">
                            <button class="btn btn-primary mb-3" data-bs-toggle="modal" data-bs-target="#addSongModal">
                                <i class="fas fa-plus me-2"></i>Thêm bài hát mới
                            </button>
                            <table class="table table-striped table-hover">
                                <thead>
                                    <tr>
                                        <th>Tên bài hát</th>
                                        <th>Nghệ sĩ</th>
                                        <th>Album</th>
                                        <th>Ngày phát hành</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="s" items="${songList}">
                                        <tr>
                                            <td>${s.title}</td>
                                            <td>${s.artist}</td>
                                            <td>${s.album}</td>
                                            <td><fmt:formatDate value="${s.releaseDate}" pattern="dd-MM-yyyy" /></td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/admin/songs" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa bài hát này?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="songId" value="${s.songID}">
                                                    <button type="submit" class="btn btn-sm btn-danger">Xóa</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="accounts">
                        <h2>Quản lý tài khoản</h2>
                        <div class="mt-4">
                            <table class="table table-striped table-hover">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Tên người dùng</th>
                                        <th>Email</th>
                                        <th>Vai trò</th>
                                        <th>Premium</th>
                                        <th>Trạng thái</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="u" items="${userList}">
                                        <tr>
                                            <td>${u.userId}</td>
                                            <td><c:out value="${u.username}"/></td>
                                            <td><c:out value="${u.email}"/></td>
                                            <td><c:out value="${u.role}"/></td>
                                            <td>
                                                <c:if test="${u.premium}"><span class="badge bg-info">Premium</span></c:if>
                                                <c:if test="${not u.premium}"><span class="badge bg-secondary">Thường</span></c:if>
                                            </td>
                                            <td>
                                                <c:if test="${u.status}"><span class="badge bg-success">Hoạt động</span></c:if>
                                                <c:if test="${not u.status}"><span class="badge bg-danger">Bị khóa</span></c:if>
                                            </td>
                                            <td>
                                                <c:if test="${u.role ne 'ADMIN'}">
                                                    <button class="btn btn-sm btn-info edit-user-btn" 
                                                            data-bs-toggle="modal" 
                                                            data-bs-target="#editUserModal"
                                                            data-userid="${u.userId}"
                                                            data-username="<c:out value='${u.username}'/>"
                                                            data-email="<c:out value='${u.email}'/>"
                                                            data-role="${u.role}">Sửa</button>
                                                    
                                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="toggleStatus">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <input type="hidden" name="currentStatus" value="${u.status}">
                                                        <c:choose>
                                                            <c:when test="${u.status}"><button type="submit" class="btn btn-sm btn-warning">Khóa</button></c:when>
                                                            <c:otherwise><button type="submit" class="btn btn-sm btn-success">Mở</button></c:otherwise>
                                                        </c:choose>
                                                    </form>
                                                    
                                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="togglePremium">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <input type="hidden" name="currentPremiumStatus" value="${u.premium}">
                                                        <c:choose>
                                                            <c:when test="${u.premium}"><button type="submit" class="btn btn-sm btn-secondary">Hủy Premium</button></c:when>
                                                            <c:otherwise><button type="submit" class="btn btn-sm btn-primary">Nâng cấp</button></c:otherwise>
                                                        </c:choose>
                                                    </form>

                                                    <form action="${pageContext.request.contextPath}/admin/users" method="post" style="display:inline;" onsubmit="return confirm('CẢNH BÁO: Xóa vĩnh viễn tài khoản này? Mọi dữ liệu liên quan sẽ bị mất và không thể khôi phục.');">
                                                        <input type="hidden" name="action" value="delete">
                                                        <input type="hidden" name="userId" value="${u.userId}">
                                                        <button type="submit" class="btn btn-sm btn-danger">Xóa</button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="orders">
                        <h2>Quản lý đơn hàng</h2>
                        <div class="mt-4">
                            <table class="table table-striped table-hover">
                                <thead>
                                    <tr>
                                        <th>ID Đơn hàng</th>
                                        <th>Tên người dùng</th>
                                        <th>Ngày đặt</th>
                                        <th>Mô tả</th>
                                        <th class="text-end">Số tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${orderList}">
                                        <tr>
                                            <td>${order.orderId}</td>
                                            <td><c:out value="${order.username}"/></td>
                                            <td><fmt:formatDate value="${order.orderDate}" pattern="HH:mm:ss dd-MM-yyyy" /></td>
                                            <td><c:out value="${order.description}"/></td>
                                            <td class="text-end">
                                                <fmt:formatNumber value="${order.amount}" type="currency" currencySymbol="" maxFractionDigits="0" />đ
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty orderList}">
                                        <tr>
                                            <td colspan="5" class="text-center">Chưa có đơn hàng nào.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/users" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="userId" id="editUserId">
                    <div class="modal-header">
                        <h5 class="modal-title" id="editUserModalLabel">Chỉnh sửa thông tin người dùng</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="editUsername" class="form-label">Tên người dùng</label>
                            <input type="text" class="form-control" id="editUsername" name="username" required>
                        </div>
                        <div class="mb-3">
                            <label for="editEmail" class="form-label">Email</label>
                            <input type="email" class="form-control" id="editEmail" name="email" required>
                        </div>
                        <div class="mb-3">
                            <label for="editRole" class="form-label">Vai trò</label>
                            <select class="form-select" id="editRole" name="role" required>
                                <option value="USER">USER</option>
                                <option value="ADMIN">ADMIN</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <div class="modal fade" id="addSongModal" tabindex="-1" aria-labelledby="addSongModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/admin/songs" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header">
                        <h5 class="modal-title" id="addSongModalLabel">Thêm bài hát mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="title" class="form-label">Tên bài hát</label>
                                <input type="text" class="form-control" id="title" name="title" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="artist" class="form-label">Nghệ sĩ</label>
                                <input type="text" class="form-control" id="artist" name="artist" required>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="album" class="form-label">Album</label>
                                <input type="text" class="form-control" id="album" name="album">
                            </div>
                             <div class="col-md-6 mb-3">
                                <label for="genre" class="form-label">Thể loại</label>
                                <input type="text" class="form-control" id="genre" name="genre">
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="duration" class="form-label">Thời lượng (giây)</label>
                                <input type="number" class="form-control" id="duration" name="duration" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="releaseDate" class="form-label">Ngày phát hành</label>
                                <input type="date" class="form-control" id="releaseDate" name="releaseDate" required>
                            </div>
                        </div>
                         <div class="mb-3">
                            <label for="filePath" class="form-label">Đường dẫn file nhạc</label>
                            <input type="text" class="form-control" id="filePath" name="filePath" placeholder="/songs/TenBaiHat.mp3" required>
                        </div>
                        <div class="mb-3">
                            <label for="coverImage" class="form-label">Đường dẫn ảnh bìa</label>
                            <input type="text" class="form-control" id="coverImage" name="coverImage" placeholder="/coverImages/TenNgheSi.jpg">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-primary">Lưu bài hát</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var hash = window.location.hash;
            if (hash) {
                var triggerEl = document.querySelector('.nav-pills a[href="' + hash + '"]');
                if (triggerEl) {
                    var tab = new bootstrap.Tab(triggerEl);
                    tab.show();
                }
            }

            var editUserModal = document.getElementById('editUserModal');
            editUserModal.addEventListener('show.bs.modal', function (event) {
                var button = event.relatedTarget;
                var userId = button.getAttribute('data-userid');
                var username = button.getAttribute('data-username');
                var email = button.getAttribute('data-email');
                var role = button.getAttribute('data-role');

                var modalTitle = editUserModal.querySelector('.modal-title');
                var userIdInput = editUserModal.querySelector('#editUserId');
                var usernameInput = editUserModal.querySelector('#editUsername');
                var emailInput = editUserModal.querySelector('#editEmail');
                var roleSelect = editUserModal.querySelector('#editRole');

                modalTitle.textContent = 'Chỉnh sửa người dùng: ' + username;
                userIdInput.value = userId;
                usernameInput.value = username;
                emailInput.value = email;
                roleSelect.value = role;
            });

            const chartDataJSON = '${monthlyRevenueData}';
            const chartData = JSON.parse(chartDataJSON);
            
            const revenueCtx = document.getElementById('revenueChart').getContext('2d');
            new Chart(revenueCtx, {
                type: 'line',
                data: {
                    labels: chartData.labels,
                    datasets: [{
                        label: 'Doanh thu (VND)',
                        data: chartData.data,
                        borderColor: '#ff69b4',
                        backgroundColor: 'rgba(255, 105, 180, 0.2)',
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: { ticks: { color: '#e0e0e0' } },
                        x: { ticks: { color: '#e0e0e0' } }
                    },
                    plugins: {
                        legend: { labels: { color: '#e0e0e0' } }
                    }
                }
            });
        });
    </script>
</body>
</html>
