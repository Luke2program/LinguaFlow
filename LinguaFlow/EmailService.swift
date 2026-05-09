import Foundation

// MARK: - Email Service
// Uses Resend API for transactional emails
// Sign up at resend.com, verify domain, get API key

final class EmailService {
    static let shared = EmailService()
    
    private let baseURL = "https://api.resend.com/v1"
    private var apiKey: String {
        // Store in secure keychain or environment in production
        UserDefaults.standard.string(forKey: "resend_api_key") ?? ""
    }
    
    private let fromEmail = "LinguaFlow <linguaflow@lukaskoprolin.com>"
    private let replyTo = "support@lukaskoprolin.com"
    
    private init() {}
    
    // MARK: - Send Email
    func sendEmail(to: String, subject: String, html: String, completion: @escaping (Bool) -> Void) {
        guard !apiKey.isEmpty else {
            print("Resend API key not configured")
            completion(false)
            return
        }
        
        let payload: [String: Any] = [
            "from": fromEmail,
            "to": to,
            "subject": subject,
            "html": html,
            "reply_to": replyTo
        ]
        
        guard let url = URL(string: "\(baseURL)/emails"),
              let body = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }
    
    // MARK: - Password Reset
    func sendPasswordReset(to email: String, resetToken: String, completion: @escaping (Bool) -> Void) {
        let resetURL = "https://lukaskoprolin.com/linguaflow/reset?token=\(resetToken)"
        let html = """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><title>Reset Password</title></head>
        <body style="font-family: -apple-system, sans-serif; max-width: 600px; margin: 0 auto; padding: 40px 20px;">
            <div style="text-align: center; margin-bottom: 30px;">
                <span style="font-size: 48px;">🦉</span>
                <h1 style="color: #00D4AA; margin-top: 10px;">LinguaFlow</h1>
            </div>
            <div style="background: #f8f9fa; border-radius: 16px; padding: 32px;">
                <h2 style="margin-top: 0;">Reset Your Password</h2>
                <p>Hi there,</p>
                <p>We received a request to reset your LinguaFlow password. Click the button below to choose a new one:</p>
                <div style="text-align: center; margin: 32px 0;">
                    <a href="\(resetURL)" style="background: #00D4AA; color: white; text-decoration: none; padding: 14px 32px; border-radius: 12px; font-weight: 600; display: inline-block;">Reset Password</a>
                </div>
                <p style="color: #6c757d; font-size: 14px;">Or copy this link: <br><code style="background: white; padding: 8px; border-radius: 6px; word-break: break-all;">\(resetURL)</code></p>
                <p style="color: #6c757d; font-size: 14px; margin-top: 24px;">If you didn't request this, you can safely ignore this email.</p>
            </div>
            <p style="text-align: center; color: #adb5bd; font-size: 12px; margin-top: 24px;">
                LinguaFlow by Lukas Koprolin<br>
                <a href="https://lukaskoprolin.com/linguaflow-privacy" style="color: #adb5bd;">Privacy Policy</a>
            </p>
        </body>
        </html>
        """
        
        sendEmail(to: email, subject: "Reset your LinguaFlow password", html: html, completion: completion)
    }
    
    // MARK: - Welcome Email
    func sendWelcome(to email: String, name: String, completion: @escaping (Bool) -> Void) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><title>Welcome to LinguaFlow</title></head>
        <body style="font-family: -apple-system, sans-serif; max-width: 600px; margin: 0 auto; padding: 40px 20px;">
            <div style="text-align: center; margin-bottom: 30px;">
                <span style="font-size: 48px;">🦉</span>
                <h1 style="color: #00D4AA; margin-top: 10px;">Welcome to LinguaFlow!</h1>
            </div>
            <div style="background: #f8f9fa; border-radius: 16px; padding: 32px;">
                <h2 style="margin-top: 0;">Hi \(name),</h2>
                <p>Your language learning journey starts now! Here's what you can do:</p>
                <ul style="line-height: 1.8;">
                    <li>📚 Practice vocabulary with spaced repetition</li>
                    <li>🎙️ Speak your answers for pronunciation practice</li>
                    <li>⏱️ Use Pomodoro timers to stay focused</li>
                    <li>🐾 Keep your pet happy by learning daily</li>
                </ul>
                <div style="text-align: center; margin: 32px 0;">
                    <a href="https://lukaskoprolin.com/linguaflow" style="background: #00D4AA; color: white; text-decoration: none; padding: 14px 32px; border-radius: 12px; font-weight: 600; display: inline-block;">Open LinguaFlow</a>
                </div>
                <p style="color: #6c757d; font-size: 14px;">Your account is synced across all devices. Sign in on any iPhone or iPad to continue learning.</p>
            </div>
            <p style="text-align: center; color: #adb5bd; font-size: 12px; margin-top: 24px;">
                LinguaFlow by Lukas Koprolin<br>
                <a href="https://lukaskoprolin.com/linguaflow-privacy" style="color: #adb5bd;">Privacy Policy</a>
            </p>
        </body>
        </html>
        """
        
        sendEmail(to: email, subject: "Welcome to LinguaFlow, \(name)!", html: html, completion: completion)
    }
    
    // MARK: - Study Reminder
    func sendStudyReminder(to email: String, streak: Int, completion: @escaping (Bool) -> Void) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><title>Daily Learning Reminder</title></head>
        <body style="font-family: -apple-system, sans-serif; max-width: 600px; margin: 0 auto; padding: 40px 20px;">
            <div style="text-align: center; margin-bottom: 30px;">
                <span style="font-size: 48px;">🔥</span>
                <h1 style="color: #FF6B6B; margin-top: 10px;">Keep Your Streak Alive!</h1>
            </div>
            <div style="background: #f8f9fa; border-radius: 16px; padding: 32px;">
                <p>You're on a <strong>\(streak)-day streak</strong>! Don't break it now.</p>
                <p>Just 5 minutes of practice keeps your pet happy and your streak burning.</p>
                <div style="text-align: center; margin: 32px 0;">
                    <a href="https://lukaskoprolin.com/linguaflow" style="background: #FF6B6B; color: white; text-decoration: none; padding: 14px 32px; border-radius: 12px; font-weight: 600; display: inline-block;">Practice Now</a>
                </div>
            </div>
        </body>
        </html>
        """
        
        sendEmail(to: email, subject: "🔥 Keep your \(streak)-day streak alive!", html: html, completion: completion)
    }
}
