-- Trilogy cannot do caching_sha2_password over plain TCP. Force native
-- password even if mysqld created MYSQL_USER with the 8.0 default plugin.
ALTER USER 'otel'@'%' IDENTIFIED WITH mysql_native_password BY 'otel';
FLUSH PRIVILEGES;
