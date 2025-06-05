<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Admin Pinkify</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #1a1a1a;
                color: #ff69b4;
            }
            .sidebar {
                min-height: 100vh;
                background-color: #2d2d2d;
                padding: 20px;
                border-right: 1px solid #ff69b4;
            }
            .nav-link {
                color: #ff69b4;
                margin-bottom: 10px;
                border: 1px solid #ff69b4;
                border-radius: 5px;
            }
            .nav-link:hover {
                background-color: #ff69b4;
                color: #1a1a1a;
            }
            .nav-link.active {
                background-color: #ff1493;
                color: #1a1a1a;
                border-color: #ff69b4;
            }
            .content {
                padding: 20px;
            }
            .card {
                background-color: #2d2d2d;
                border: 1px solid #ff69b4;
            }
            .card-title {
                color: #ff69b4;
            }
            .table {
                color: #ff69b4;
            }
            .table thead th {
                border-bottom: 2px solid #ff69b4;
            }
            .table td, .table th {
                border-top: 1px solid #ff69b4;
            }
            .btn-primary {
                background-color: #ff69b4;
                border-color: #ff69b4;
                color: #1a1a1a;
            }
            .btn-primary:hover {
                background-color: #ff1493;
                border-color: #ff1493;
                color: #1a1a1a;
            }
            h2, h3, h5 {
                color: #ff69b4;
            }
            .bg-primary {
                background-color: #ff69b4 !important;
            }
            .bg-success {
                background-color: #2d2d2d !important;
                border: 1px solid #ff69b4;
            }
            .bg-warning {
                background-color: #2d2d2d !important;
                border: 1px solid #ff69b4;
            }
            .bg-info {
                background-color: #2d2d2d !important;
                border: 1px solid #ff69b4;
            }
            .text-white {
                color: #ff69b4 !important;
            }
            .nav-pills .nav-link.active, .nav-pills .show>.nav-link {
                color: var(--bs-nav-pills-link-active-color);
                background-color: #fd0d95;
            }
        </style>
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-3 col-lg-2 sidebar">
                    <h3 class="mb-4">Pinkify Admin</h3>
                    <div class="nav flex-column nav-pills">
                        <a class="nav-link active" href="#dashboard" data-bs-toggle="pill">
                            <i class="fas fa-chart-line me-2"></i>Dashboard
                        </a>
                        <a class="nav-link" href="#categories" data-bs-toggle="pill">
                            <i class="fas fa-list me-2"></i>Danh mục nhạc
                        </a>
                        <a class="nav-link" href="#accounts" data-bs-toggle="pill">
                            <i class="fas fa-users me-2"></i>Quản lý tài khoản
                        </a>
                        <a class="nav-link" href="#orders" data-bs-toggle="pill">
                            <i class="fas fa-shopping-cart me-2"></i>Đơn hàng
                        </a>
                        <a class="nav-link" href="#products" data-bs-toggle="pill">
                            <i class="fas fa-music me-2"></i>Sản phẩm
                        </a>
                        <a class="nav-link" href="#statistics" data-bs-toggle="pill">
                            <i class="fas fa-chart-bar me-2"></i>Thống kê
                        </a>
                        <a class="nav-link" href="${pageContext.request.contextPath}/logout" style="margin-top: 20px;">
                            <i class="fas fa-sign-out-alt me-2"></i>Đăng xuất
                        </a>
                    </div>
                </div>

                <!-- Main Content -->
                <div class="col-md-9 col-lg-10 content">
                    <div class="tab-content">
                        <!-- Dashboard -->
                        <div class="tab-pane fade show active" id="dashboard">
                            <h2>Dashboard</h2>
                            <div class="row mt-4">
                                <div class="col-md-3">
                                    <div class="card bg-primary text-white">
                                        <div class="card-body">
                                            <h5 class="card-title">Tổng đơn hàng</h5>
                                            <h2 class="card-text">0</h2>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card bg-success text-white">
                                        <div class="card-body">
                                            <h5 class="card-title">Tổng người dùng</h5>
                                            <h2 class="card-text">0</h2>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card bg-warning text-white">
                                        <div class="card-body">
                                            <h5 class="card-title">Tổng sản phẩm</h5>
                                            <h2 class="card-text">0</h2>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="card bg-info text-white">
                                        <div class="card-body">
                                            <h5 class="card-title">Doanh thu</h5>
                                            <h2 class="card-text">0đ</h2>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Categories -->
                        <div class="tab-pane fade" id="categories">
                            <h2>Quản lý danh mục nhạc</h2>
                            <div class="mt-4">
                                <button class="btn btn-primary mb-3">
                                    <i class="fas fa-plus me-2"></i>Thêm danh mục mới
                                </button>
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Tên danh mục</th>
                                            <th>Mô tả</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Dữ liệu danh mục sẽ được thêm vào đây -->
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Accounts -->
                        <div class="tab-pane fade" id="accounts">
                            <h2>Quản lý tài khoản</h2>
                            <div class="mt-4">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Tên người dùng</th>
                                            <th>Email</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Dữ liệu người dùng sẽ được thêm vào đây -->
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Orders -->
                        <div class="tab-pane fade" id="orders">
                            <h2>Quản lý đơn hàng</h2>
                            <div class="mt-4">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>Mã đơn hàng</th>
                                            <th>Khách hàng</th>
                                            <th>Ngày đặt</th>
                                            <th>Tổng tiền</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Dữ liệu đơn hàng sẽ được thêm vào đây -->
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Products -->
                        <div class="tab-pane fade" id="products">
                            <h2>Quản lý sản phẩm</h2>
                            <div class="mt-4">
                                <button class="btn btn-primary mb-3">
                                    <i class="fas fa-plus me-2"></i>Thêm sản phẩm mới
                                </button>
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Danh mục</th>
                                            <th>Giá</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Dữ liệu sản phẩm sẽ được thêm vào đây -->
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Statistics -->
                        <div class="tab-pane fade" id="statistics">
                            <h2>Thống kê</h2>
                            <div class="row mt-4">
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-body">
                                            <h5 class="card-title">Doanh thu theo tháng</h5>
                                            <canvas id="revenueChart"></canvas>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-body">
                                            <h5 class="card-title">Sản phẩm bán chạy</h5>
                                            <canvas id="productsChart"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script>
            // Khởi tạo các biểu đồ thống kê
            const revenueCtx = document.getElementById('revenueChart').getContext('2d');
            const productsCtx = document.getElementById('productsChart').getContext('2d');

            // Biểu đồ doanh thu
            new Chart(revenueCtx, {
                type: 'line',
                data: {
                    labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6'],
                    datasets: [{
                        label: 'Doanh thu',
                        data: [0, 0, 0, 0, 0, 0],
                        borderColor: 'rgb(75, 192, 192)',
                        tension: 0.1
                    }]
                }
            });

            // Biểu đồ sản phẩm bán chạy
            new Chart(productsCtx, {
                type: 'bar',
                data: {
                    labels: ['Sản phẩm 1', 'Sản phẩm 2', 'Sản phẩm 3', 'Sản phẩm 4', 'Sản phẩm 5'],
                    datasets: [{
                        label: 'Số lượng bán',
                        data: [0, 0, 0, 0, 0],
                        backgroundColor: 'rgba(54, 162, 235, 0.5)'
                    }]
                }
            });
        </script>
    </body>
</html>
