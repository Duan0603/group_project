package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {
    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());
    protected Connection connection;

    public DBContext() {
        try {
            String url = "jdbc:sqlserver://localhost:1433;databaseName=MusicManagement;encrypt=false;trustServerCertificate=true";
            String username = "sa";
            String password = "sa";
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

    public static void main(String[] args) {
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("Connect success");
            } else {
                System.out.println("Connect failed");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error using connection: ", e);
        }
    }
} 