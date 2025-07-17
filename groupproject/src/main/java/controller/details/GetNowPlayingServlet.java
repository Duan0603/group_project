package controller.details;

import dao.SongDAO;
import model.Songs;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/getNowPlaying")
public class GetNowPlayingServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Songs song = (session != null) ? (Songs) session.getAttribute("nowPlaying") : null;

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        if (song == null) {
            out.print("{}");
            return;
        }

        JsonObject json = new JsonObject();
        json.addProperty("title", song.getTitle());
        json.addProperty("artist", song.getArtist());
        json.addProperty("coverImage", song.getTitle()); // dùng cho load ảnh

        out.print(json);
    }
}
