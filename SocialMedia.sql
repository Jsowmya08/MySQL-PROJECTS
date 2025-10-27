CREATE DATABASE MySQL_Projects;
USE MySQL_Projects;

CREATE TABLE Users (
	user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) ,
    join_date DATE NOT NULL
);
SELECT * FROM Users;

CREATE TABLE Posts (
	post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    post_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    likes_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

SELECT * FROM Posts;

CREATE TABLE Likes(
	link_id INT PRIMARY KEY,
    post_id INT, 
    user_id INT NOT NULL,
    FOREIGN KEY (post_id ) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Comments(
	comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment_text VARCHAR(150),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
SELECT * FROM Comments;

INSERT INTO Users (user_name, join_date) VALUES
('RajeshButti', '2016-07-08'),
('SaiKiranAdepu', '2015-09-22'),
('VarunKatta', '2014-01-01');

INSERT INTO Posts (user_id,likes_count) VALUES
(1, 10),
(1, 5),
(2, 15),
(2, 7),
(3, 20),
(3, 3);

INSERT INTO Likes (link_id, post_id, user_id)
VALUES
(1, 1, 2),   
(2, 2, 1),   
(3, 3, 3),  
(4, 4, 2),  
(5, 5, 1),   
(6, 6, 3); 

INSERT INTO Comments (post_id, user_id, comment_text) VALUES 
(1, 2, 'Great post, Rajesh!'),
(1, 3, 'Really inspiring project.'),
(2, 1, 'Nice explanation, Sai!'),
(3, 3, 'I love this content.'),
(4, 2, 'Interesting thoughts!');

CREATE VIEW TopPosts AS 
SELECT 
	u.user_name,
    p.post_id,
    p.likes_count
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
ORDER BY p.likes_count DESC;

SELECT * FROM TopPosts;

CREATE VIEW EngagementScore AS 
SELECT 
    p.post_id, 
    u.user_id,
    u.user_name,
    (p.likes_count + COUNT(c.comment_id)) AS engagement_score
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
LEFT JOIN Comments c ON p.post_id = c.post_id
GROUP BY p.post_id, u.user_id, u.user_name, p.likes_count;

SELECT * FROM EngagementScore;

SELECT post_id, user_id , likes_count,
RANK() OVER (ORDER BY likes_count DESC) AS User_post_rank
FROM Posts;


-- triggers to update like to count

DELIMITER //
CREATE TRIGGER update_like_count_after_insert
AFTER INSERT ON Likes 
FOR EACH ROW
BEGIN 
	UPDATE Posts
    SET likes_count = likes_count + 1
    WHERE post_id = NEW.post_id;
END;
//
DELIMITER ; 
DROP TRIGGER update_like_count_after_insert;

-- before trigger
SELECT post_id, likes_count FROM Posts;
-- After Trigger
INSERT INTO Likes(link_id, post_id, user_id ) VALUES (7, 1, 3);
-- chechking likes after trigger
SELECT post_id, likes_count FROM Posts WHERE post_id = 1;

-- trigger for deleting likes

DELIMITER //
CREATE TRIGGER deleting_likes
AFTER DELETE ON Likes
FOR EACH ROW 
BEGIN
	UPDATE Posts 
    SET likes_count = likes_count-1
    WHERE post_id = OLD.post_id;
END ;
//
DELIMITER ;
-- Before trigger
SELECT post_id, likes_count FROM Posts;
-- remove a like 
DELETE FROM Likes WHERE link_id= 7;
-- after trigger 
SELECT post_id, likes_count FROM Posts WHERE post_id = 1;

SHOW VARIABLES LIKE 'secure_file_priv';

SELECT 
    e.user_id,
    e.user_name,
    e.post_id,
    e.engagement_score
FROM EngagementScore e
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Engagement_Report.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n';

SELECT * FROM EngagementScore;




