use rand::Rng;
use std::collections::HashMap;

/// Generates a simple captcha challenge with a math problem
pub struct CaptchaGenerator;

impl CaptchaGenerator {
    /// Generates a captcha with a simple math problem
    /// Returns (token, solution, image_base64)
    pub fn generate() -> (String, String, String) {
        let mut rng = rand::thread_rng();
        
        let num1 = rng.gen_range(1..=20);
        let num2 = rng.gen_range(1..=20);
        let operation = rng.gen_range(0..2);
        
        let (question, answer) = match operation {
            0 => (format!("{} + {}", num1, num2), (num1 + num2).to_string()),
            _ => {
                let (larger, smaller) = if num1 > num2 { (num1, num2) } else { (num2, num1) };
                (format!("{} - {}", larger, smaller), (larger - smaller).to_string())
            }
        };
        
        let token = Self::generate_token();
        let image_base64 = Self::generate_image(&question);
        
        (token, answer, image_base64)
    }
    
    /// Generates a random token
    fn generate_token() -> String {
        use rand::distributions::Alphanumeric;
        rand::thread_rng()
            .sample_iter(&Alphanumeric)
            .take(32)
            .map(char::from)
            .collect()
    }
    
    /// Generates a simple SVG image with the captcha text
    fn generate_image(text: &str) -> String {
        let svg = format!(
            r##"<svg width="200" height="80" xmlns="http://www.w3.org/2000/svg">
                <rect width="200" height="80" fill="#f0f0f0"/>
                <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="32" 
                      fill="#333" text-anchor="middle" dominant-baseline="middle">
                    {}
                </text>
                <line x1="0" y1="40" x2="200" y2="40" stroke="#ccc" stroke-width="1"/>
                <circle cx="30" cy="20" r="3" fill="#999"/>
                <circle cx="170" cy="60" r="3" fill="#999"/>
            </svg>"##,
            text
        );
        
        base64::Engine::encode(&base64::engine::general_purpose::STANDARD, svg.as_bytes())
    }
}

/// Simple in-memory rate limiter for captcha generation
#[allow(dead_code)]
pub struct RateLimiter {
    requests: HashMap<String, Vec<i64>>,
    max_requests: usize,
    window_seconds: i64,
}

impl RateLimiter {
    #[allow(dead_code)]
    pub fn new(max_requests: usize, window_seconds: i64) -> Self {
        Self {
            requests: HashMap::new(),
            max_requests,
            window_seconds,
        }
    }
    
    /// Checks if an IP address has exceeded the rate limit
    #[allow(dead_code)]
    pub fn check(&mut self, ip: &str) -> bool {
        let now = chrono::Utc::now().timestamp();
        let cutoff = now - self.window_seconds;
        
        let entry = self.requests.entry(ip.to_string()).or_insert_with(Vec::new);
        
        entry.retain(|&timestamp| timestamp > cutoff);
        
        if entry.len() >= self.max_requests {
            return false;
        }
        
        entry.push(now);
        true
    }
    
    /// Cleans up old entries
    #[allow(dead_code)]
    pub fn cleanup(&mut self) {
        let now = chrono::Utc::now().timestamp();
        let cutoff = now - self.window_seconds;
        
        self.requests.retain(|_, timestamps| {
            timestamps.retain(|&t| t > cutoff);
            !timestamps.is_empty()
        });
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_captcha_generation() {
        let (token, solution, image) = CaptchaGenerator::generate();
        
        assert!(!token.is_empty());
        assert!(!solution.is_empty());
        assert!(!image.is_empty());
        
        let solution_num: i32 = solution.parse().expect("Solution should be a number");
        assert!(solution_num >= 0 && solution_num <= 40);
    }
    
    #[test]
    fn test_rate_limiter() {
        let mut limiter = RateLimiter::new(3, 60);
        
        assert!(limiter.check("192.168.1.1"));
        assert!(limiter.check("192.168.1.1"));
        assert!(limiter.check("192.168.1.1"));
        assert!(!limiter.check("192.168.1.1"));
        
        assert!(limiter.check("192.168.1.2"));
    }
}
