/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public final class OtpManager {

    private static final Map<String, OtpEntry> OTP_STORE = new ConcurrentHashMap<>();
    private static final SecureRandom RND = new SecureRandom();
    private static final int EXPIRE_SEC = 300;     // 5 phút

    // Sinh OTP 6 chữ số, lưu kèm thời gian
    public static String generate(String email) {
        String otp = String.valueOf(100_000 + RND.nextInt(900_000));
        OTP_STORE.put(email, new OtpEntry(otp, Instant.now().getEpochSecond()));
        return otp;
    }

    //Kiểm tra OTP, true nếu đúng & còn hiệu lực – sau đó xoá luôn
    public static boolean verify(String email, String otpInput) {
        OtpEntry entry = OTP_STORE.get(email);
        if (entry == null) {
            return false;
        }

        long now = Instant.now().getEpochSecond();
        boolean valid = entry.otp.equals(otpInput) && (now - entry.ts) <= EXPIRE_SEC;

        if (valid || now - entry.ts > EXPIRE_SEC) {
            OTP_STORE.remove(email);              // xoá khỏi map
        }
        return valid;
    }

    /* ====== inner record ====== */
    private static class OtpEntry {

        String otp;
        long ts;

        OtpEntry(String otp, long ts) {
            this.otp = otp;
            this.ts = ts;
        }
    }

    private OtpManager() {
    }
}
