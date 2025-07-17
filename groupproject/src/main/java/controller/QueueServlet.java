package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Songs;
import dao.SongDAO;

import java.io.IOException;
import java.util.*;

@WebServlet("/add-to-queue")
public class QueueServlet extends HttpServlet {
    private final SongDAO songDAO = new SongDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        Songs song = songDAO.getSongByTitle(title);

        if (song != null) {
            HttpSession session = request.getSession();
            List<Songs> queue = (List<Songs>) session.getAttribute("queueList");

            if (queue == null) {
                queue = new ArrayList<>();
            }

            queue.add(song);
            session.setAttribute("queueList", queue);

            response.setStatus(200);
            response.getWriter().write("Added to queue");
        } else {
            response.setStatus(404);
            response.getWriter().write("Song not found");
        }
    }
}
