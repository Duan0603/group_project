<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    String email = (String) session.getAttribute("pendingEmail");
    if (email == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Xác minh OTP</title>
        <meta charset="UTF-8">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <style>
            body {
                background-color: #111;
                font-family: 'Segoe UI', sans-serif;
                color: #fff;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }

            .otp-container {
                background-color: #1c1c1c;
                padding: 40px 30px;
                border-radius: 20px;
                box-shadow: 0 0 15px rgba(232, 67, 147, 0.2);
                width: 400px;
            }

            .otp-container h2 {
                color: #e84393;
                font-weight: bold;
                text-align: center;
                margin-bottom: 20px;
            }

            .otp-container p {
                text-align: center;
                color: #bbb;
                font-size: 0.95rem;
                margin-bottom: 30px;
            }

            .otp-inputs {
                display: flex;
                justify-content: space-between;
                gap: 10px;
                margin-bottom: 25px;
            }

            .otp-inputs input {
                width: 48px;
                height: 58px;
                text-align: center;
                font-size: 24px;
                border-radius: 10px;
                border: 2px solid #333;
                background-color: #222;
                color: #fff;
            }

            .otp-inputs input:focus {
                border-color: #e84393;
                outline: none;
            }

            .btn-pink {
                background-color: #e84393;
                border: none;
                color: #fff;
                width: 100%;
                padding: 12px;
                border-radius: 12px;
                font-weight: bold;
                font-size: 1rem;
            }

            .btn-pink:hover {
                background-color: #ff69b4;
            }

            .resend-link {
                display: block;
                text-align: center;
                margin-top: 15px;
                color: #e84393;
                font-size: 0.9rem;
            }

            .resend-link:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <div class="otp-container">
            <h2>Xác minh OTP</h2>
            <p>Mã xác nhận đã được gửi tới <strong><%= email.replaceAll("(?<=.).(?=[^@]*?@)", "*")%></strong></p>

            <form action="<%=request.getContextPath()%>/verify-otp" method="post" id="otpForm">
                <div class="otp-inputs">
                    <input type="text" maxlength="1" name="digit1" required autocomplete="off" inputmode="numeric">
                    <input type="text" maxlength="1" name="digit2" required autocomplete="off" inputmode="numeric">
                    <input type="text" maxlength="1" name="digit3" required autocomplete="off" inputmode="numeric">
                    <input type="text" maxlength="1" name="digit4" required autocomplete="off" inputmode="numeric">
                    <input type="text" maxlength="1" name="digit5" required autocomplete="off" inputmode="numeric">
                    <input type="text" maxlength="1" name="digit6" required autocomplete="off" inputmode="numeric">
                </div>
                <input type="hidden" name="otp" id="otpField">
                
                <% if (request.getAttribute("error") != null) {%>
                <div class="alert alert-danger text-center mb-3" style="font-size: 0.9rem;">
                    <%= request.getAttribute("error")%>
                </div>
                <% }%>
                
                <button type="submit" class="btn btn-pink">Xác nhận</button>
                <a href="#" class="resend-link">Chưa nhận được mã? Gửi lại</a>
            </form>
        </div>

        <script>
            const inputs = document.querySelectorAll(".otp-inputs input");
            const otpField = document.getElementById("otpField");
            const form = document.getElementById("otpForm");

            inputs.forEach((input, i) => {
                input.addEventListener("input", () => {
                    if (input.value.length === 1 && i < inputs.length - 1) {
                        inputs[i + 1].focus();
                    }
                });
            });

            form.addEventListener("submit", function (e) {
                let otp = "";
                inputs.forEach(input => otp += input.value);
                otpField.value = otp;
            });
        </script>
    </body>
</html>