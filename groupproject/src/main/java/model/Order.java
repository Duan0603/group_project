package model;

import java.util.Date;

public class Order {
    private int orderId;
    private int userId;
    private String username; // Thêm trường này để hiển thị tên người dùng trong trang admin
    private Date orderDate;
    private double amount;
    private String description;

    // Constructors
    public Order() {
    }

    public Order(int orderId, int userId, String username, Date orderDate, double amount, String description) {
        this.orderId = orderId;
        this.userId = userId;
        this.username = username;
        this.orderDate = orderDate;
        this.amount = amount;
        this.description = description;
    }

    // Getters and Setters
    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
