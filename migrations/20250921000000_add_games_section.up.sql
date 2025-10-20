-- Add 'games' section
INSERT INTO sections (priority, title) VALUES (5, 'Games')
ON CONFLICT DO NOTHING;
