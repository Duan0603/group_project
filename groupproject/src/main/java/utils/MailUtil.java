/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.UnsupportedEncodingException;

import java.util.Date;
import java.util.Properties;

public final class MailUtil {

    private static final String SENDER_EMAIL = "tunguyencao11925@gmail.com";
    private static final String APP_PASSWORD = "cyri yxal dmfu rqbj";

    private static Session createSession() {

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, APP_PASSWORD);
            }
        });
    }

    public static void send(String toEmail, String subject,
            String content, boolean isHtml) throws MessagingException, UnsupportedEncodingException {

        Session session = createSession();

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(SENDER_EMAIL, "Pinkify"));
        msg.setRecipients(Message.RecipientType.TO,
                InternetAddress.parse(toEmail, false));
        msg.setSubject(subject);
        msg.setSentDate(new Date());

        if (isHtml) {
            msg.setContent(content, "text/html; charset=UTF-8");
        } else {
            msg.setContent(content, "text/plain; charset=UTF-8");
        }

        Transport.send(msg);
    }

   public static void sendOtp(String toEmail, String name, String otp) throws MessagingException, UnsupportedEncodingException {
    String html = "<div style=\"max-width: 500px; margin: auto; background: #fff; border: 1px solid #ddd;"
            + "border-radius: 12px; box-shadow: 0 0 20px rgba(0,0,0,0.1); padding: 32px;"
            + "font-family: Arial, sans-serif; color: #333;\">"
            + "<h2 style=\"color: #e84393; margin-top: 0;\">Xác nhận OTP</h2>"
            + "<p style=\"font-size: 15px;\">Xin chào, <strong>" + name + "</strong></p>"
            + "<p style=\"font-size: 15px;\">Đây là mã xác nhận đăng nhập tài khoản Pinkify của bạn:</p>"
            + "<div style=\"margin: 24px auto; text-align: center;\">"
            + "<span style=\"font-size: 28px; font-weight: bold;"
            + "background: #000; color: #fff; padding: 14px 28px; border-radius: 8px;"
            + "letter-spacing: 5px;\">" + otp + "</span>"
            + "</div>"
            + "<p style=\"font-size: 13px; color: #666;\">Mã OTP có hiệu lực trong 5 phút.</p>"
            + "<p style=\"font-size: 13px; color: #666;\">Nếu bạn không yêu cầu, vui lòng bỏ qua email này.</p>"
            + "<hr style=\"margin: 30px 0;\">"
            + "<p style=\"font-size: 13px; color: #aaa;\">Pinkify Team</p>"
            + "</div>";

    send(toEmail, "Mã xác nhận đăng nhập Pinkify", html, true);
}

    private MailUtil() {
    }
}
