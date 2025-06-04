package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {
    protected Connection connection;
    
    public DBContext() {
        try {
            String url = "jdbc:sqlserver://localhost:1433;databaseName=MusicManagement;encrypt=false;trustServerCertificate=true";
            String username = "sa";
            String password = "th15092004";
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, username, password);
            System.out.println(connection);
        } catch (ClassNotFoundException | SQLException ex) {
            System.out.println("Connection error! " + ex.getMessage());
        }
    }
    
    public Connection getConnection() {
        return connection;
    }
   
} 