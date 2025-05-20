package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {
    protected Connection connection;
    
    public DBContext() {
        try {
            // Edit these parameters according to your database configuration
            String url = "jdbc:sqlserver://localhost:1433;databaseName=MusicManagement";
            String username = "sa";
            String password = "sa";
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException | SQLException ex) {
            System.out.println("Connection error! " + ex.getMessage());
        }
    }
    
    public Connection getConnection() {
        return connection;
    }
} 