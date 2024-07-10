-- Just for testing
CREATE DATABASE IF NOT EXISTS secureapi;
USE secureapi;

CREATE TABLE IF NOT EXISTS v2_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(255) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO v2_user (uuid, token) VALUES ('user1-uuid', 'user1-token');
INSERT INTO v2_user (uuid, token) VALUES ('user2-uuid', 'user2-token');
