-- Drop comments system tables
DROP INDEX IF EXISTS idx_captcha_tokens_expires;
DROP INDEX IF EXISTS idx_captcha_tokens_token;
DROP TABLE IF EXISTS public.captcha_tokens;

DROP INDEX IF EXISTS idx_comments_article_approved;
DROP TABLE IF EXISTS public.comments;
