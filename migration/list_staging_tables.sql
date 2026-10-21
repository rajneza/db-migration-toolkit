-- List all tables in staging schema
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'staging' 
ORDER BY table_name;
