CREATE DATABASE MySQL_Projects;   -- creates a new database
USE MySQL_Projects;  -- USE- Switch to that database so all future tables/queries run inside it.

CREATE TABLE Users (    -- creates a table 
	user_id INT AUTO_INCREMENT PRIMARY KEY,  -- primary key and auto incremented
    user_name VARCHAR(100) ,   -- Name of the user
    join_date DATE NOT NULL   -- the date the user joined the platform.
);
SELECT * FROM Users;   -- view inserted data

CREATE TABLE Posts (
	post_id INT AUTO_INCREMENT PRIMARY KEY,  -- primary key and auto incremented
    user_id INT, -- Foreign key (connect each post to a user)
    post_date DATETIME DEFAULT CURRENT_TIMESTAMP, -- automatically stores the date and time when the post was created
    likes_count INT DEFAULT 0,  -- Tracks how many likes a post received
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

SELECT * FROM Posts;  -- check the data

CREATE TABLE Likes(   -- create like table
	link_id INT PRIMARY KEY,  -- Unique ID for each like.
    post_id INT,   -- each like connects to both a post and a user via foreign key
    user_id INT NOT NULL,
    FOREIGN KEY (post_id ) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Comments(   -- create comments table
	comment_id INT AUTO_INCREMENT PRIMARY KEY,  -- id auto incremented
    post_id INT,     -- connects comments to both post and user
    user_id INT,
    comment_text VARCHAR(150),  -- stores comments made on post
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
SELECT * FROM Comments;  -- check the data 


-- Insert sample data 
INSERT INTO Users (user_name, join_date) VALUES  
('RajeshButti', '2016-07-08'),
('SaiKiranAdepu', '2015-09-22'),
('VarunKatta', '2014-01-01');

-- Insert sample data 
INSERT INTO Posts (user_id,likes_count) VALUES
(1, 10),
(1, 5),
(2, 15),
(2, 7),
(3, 20),
(3, 3);

-- Insert sample data 
INSERT INTO Likes (link_id, post_id, user_id)
VALUES
(1, 1, 2),   
(2, 2, 1),   
(3, 3, 3),  
(4, 4, 2),  
(5, 5, 1),   
(6, 6, 3); 

-- Insert sample data 
INSERT INTO Comments (post_id, user_id, comment_text) VALUES 
(1, 2, 'Great post, Rajesh!'),
(1, 3, 'Really inspiring project.'),
(2, 1, 'Nice explanation, Sai!'),
(3, 3, 'I love this content.'),
(4, 2, 'Interesting thoughts!');

-- Shows top-performing posts sorted by number of likes.
-- Joins Posts with Users to display post creator names.

CREATE VIEW TopPosts AS 
SELECT 
	u.user_name,
    p.post_id,
    p.likes_count
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
ORDER BY p.likes_count DESC;

SELECT * FROM TopPosts;

-- Calculates an engagement score = likes + comments.
-- Uses LEFT JOIN to include posts even if they have zero comments.
-- Groups data by post and user.
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

-- Uses the RANK() window function to assign ranks based on number of likes.
-- Highest likes → Rank 1.
SELECT post_id, user_id , likes_count,
RANK() OVER (ORDER BY likes_count DESC) AS User_post_rank
FROM Posts;

-- triggers to update like to count
-- Every time a user likes a post, the post’s likes_count increases by 1.

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
-- When a like is deleted, the likes_count decreases automatically.
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

SHOW VARIABLES LIKE 'secure_file_priv';  -- Shows the folder where MySQL allows saving exported files.

-- This exports the engagement data into a CSV file.
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

SELECT * FROM EngagementScore;  -- Displays the final calculated engagement report in MySQL.
