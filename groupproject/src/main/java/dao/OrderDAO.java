package dao;

import com.google.gson.Gson;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Order;

public class OrderDAO extends DBContext {

    /**
     * Lấy tất cả các đơn hàng từ CSDL, sắp xếp theo ngày mới nhất.
     * @return Một danh sách các đối tượng Order.
     */
    public List<Order> getAllOrders() {
        List<Order> orderList = new ArrayList<>();
        // Dùng JOIN để lấy thêm Username từ bảng Users
        String sql = "SELECT o.OrderID, o.UserID, u.Username, o.OrderDate, o.Amount, o.Description " +
                     "FROM Orders o JOIN Users u ON o.UserID = u.UserID " +
                     "ORDER BY o.OrderDate DESC";
        
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Order order = new Order();
                order.setOrderId(rs.getInt("OrderID"));
                order.setUserId(rs.getInt("UserID"));
                order.setUsername(rs.getString("Username"));
                order.setOrderDate(rs.getTimestamp("OrderDate"));
                order.setAmount(rs.getDouble("Amount"));
                order.setDescription(rs.getString("Description"));
                orderList.add(order);
            }
        } catch (SQLException e) {
            System.out.println("Get all orders error: " + e.getMessage());
        }
        return orderList;
    }

    /**
     * Lấy dữ liệu doanh thu của 6 tháng gần nhất để vẽ biểu đồ.
     * @return Một chuỗi JSON chứa nhãn (labels) và dữ liệu (data).
     */
    public String getMonthlyRevenueForChart() {
        List<String> labels = new ArrayList<>();
        List<Double> data = new ArrayList<>();
        
        String sql = "SELECT FORMAT(OrderDate, 'MM-yyyy') AS MonthYear, SUM(Amount) AS MonthlyRevenue " +
                     "FROM Orders " +
                     "WHERE OrderDate >= DATEADD(month, -6, GETDATE()) " +
                     "GROUP BY FORMAT(OrderDate, 'MM-yyyy') " +
                     "ORDER BY MIN(OrderDate)";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                labels.add("Tháng " + rs.getString("MonthYear"));
                data.add(rs.getDouble("MonthlyRevenue"));
            }
        } catch (SQLException e) {
            System.out.println("Get monthly revenue error: " + e.getMessage());
        }

        Map<String, Object> chartData = new HashMap<>();
        chartData.put("labels", labels);
        chartData.put("data", data);

        return new Gson().toJson(chartData);
    }

    /**
     * Tạo một đơn hàng mới trong cơ sở dữ liệu.
     * @param userId ID của người dùng thực hiện.
     * @param amount Số tiền của đơn hàng.
     * @param description Mô tả về đơn hàng.
     * @return true nếu tạo thành công.
     */
    public boolean createOrder(int userId, double amount, String description) {
        String sql = "INSERT INTO Orders (UserID, Amount, Description) VALUES (?, ?, ?)";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            st.setDouble(2, amount);
            st.setString(3, description);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Create order error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Đếm tổng số đơn hàng trong hệ thống.
     * @return Tổng số đơn hàng.
     */
    public int countTotalOrders() {
        String sql = "SELECT COUNT(*) FROM Orders";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.out.println("Count orders error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Tính tổng doanh thu từ tất cả các đơn hàng.
     * @return Tổng doanh thu.
     */
    public double calculateTotalRevenue() {
        String sql = "SELECT SUM(Amount) FROM Orders";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            System.out.println("Calculate revenue error: " + e.getMessage());
        }
        return 0.0;
    }
}
