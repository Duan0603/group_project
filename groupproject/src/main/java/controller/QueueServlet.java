package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Songs;
import dao.SongDAO;

import java.io.IOException;
import java.util.*;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/queue")
public class QueueServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        String action = request.getParameter("action");

        // Tránh null gây lỗi
        if (action == null || !action.equals("getCurrentQueue")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid or missing action\"}");
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("queue") == null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"queue\": []}");
            return;
        }

        List<Songs> queue = (List<Songs>) session.getAttribute("queue");
        JSONArray jsonArray = new JSONArray();

        for (Songs song : queue) {
            if (song == null) continue; // tránh null gây lỗi JSON

            JSONObject obj = new JSONObject();
            obj.put("title", song.getTitle());
            obj.put("artist", song.getArtist());
            obj.put("filePath", song.getFilePath());
            obj.put("songId", song.getSongID());
            jsonArray.put(obj);
        }

        JSONObject responseJson = new JSONObject();
        responseJson.put("queue", jsonArray);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8"); // 👈 tránh lỗi ký tự đặc biệt
        response.getWriter().write(responseJson.toString());
    }
}
