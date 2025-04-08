-- Create additional database structures if needed

-- Grant all privileges to the created user
GRANT ALL PRIVILEGES ON *.* TO 'dev'@'%';
FLUSH PRIVILEGES;

-- WordPress database setup 
-- (uncomment if you're using this specifically for WordPress)
-- CREATE DATABASE IF NOT EXISTS wordpress;
-- GRANT ALL PRIVILEGES ON wordpress.* TO 'dev'@'%';
-- FLUSH PRIVILEGES; 