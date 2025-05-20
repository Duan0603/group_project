package controller;

import dao.SongDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Song;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchQuery = request.getParameter("search");
        String pageStr = request.getParameter("page");
        int page = 1;
        int pageSize = 12;
        
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) {
                    page = 1;
                }
            } catch (NumberFormatException e) {
                // Keep default page value
            }
        }
        
        SongDAO songDAO = new SongDAO();
        List<Song> songs;
        int totalSongs;
        
        if (searchQuery != null && !searchQuery.isEmpty()) {
            songs = songDAO.searchSongs(searchQuery, page, pageSize);
            totalSongs = songDAO.getTotalSearchResults(searchQuery);
        } else {
            songs = songDAO.getAllSongs(page, pageSize);
            totalSongs = songDAO.getTotalSongs();
        }
        
        int totalPages = (int) Math.ceil((double) totalSongs / pageSize);
        
        request.setAttribute("songs", songs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("WEB-INF/views/home.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
} 