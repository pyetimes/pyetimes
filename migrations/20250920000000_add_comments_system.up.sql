-- Create comments table with moderation system
CREATE TABLE IF NOT EXISTS public.comments (
    id SERIAL PRIMARY KEY,
    article_id INT NOT NULL,
    author_name VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    captcha_token VARCHAR(255) NOT NULL,
    approved BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    approved_at TIMESTAMP,
    CONSTRAINT comments_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.articles(id) ON DELETE CASCADE
);

-- Create index for faster queries on article_id and approved status
CREATE INDEX idx_comments_article_approved ON public.comments(article_id, approved);

-- Create captcha_tokens table for validation
CREATE TABLE IF NOT EXISTS public.captcha_tokens (
    id SERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    solution VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE NOT NULL,
    expires_at TIMESTAMP NOT NULL
);

-- Create index for captcha token lookup
CREATE INDEX idx_captcha_tokens_token ON public.captcha_tokens(token);
CREATE INDEX idx_captcha_tokens_expires ON public.captcha_tokens(expires_at);
