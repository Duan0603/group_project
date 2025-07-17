/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;

import java.util.Properties;

public class EmailUtility {

    private static final String SENDER_EMAIL = "tunguyencao11925@gmail.com"; 
    private static final String APP_PASSWORD = "cyri yxal dmfu rqbj";   

    public static boolean sendEmail(String to, String subject, String htmlContent) {
        if (to == null || to.trim().isEmpty()) {
            System.out.println(" Email người nhận bị null hoặc rỗng.");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, APP_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL, "Pinkify Support")); // <--- Tên hiển thị
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println("✅ Đã gửi email tới: " + to);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}