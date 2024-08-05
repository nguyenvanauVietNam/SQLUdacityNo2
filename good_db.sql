-- Drop tables if they already exist to ensure clean creation
DROP TABLE IF EXISTS votes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS users;
--Fix for GPT and copilot github

-- 1. Guideline #1: Create Tables with Features and Specifications

-- a. Allow new users to register
CREATE TABLE users (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    username VARCHAR(25) UNIQUE NOT NULL,  -- Unique and non-empty username with a maximum of 25 characters
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp for user creation
);

-- b. Allow registered users to create new topics
CREATE TABLE topics (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    name VARCHAR(30) UNIQUE NOT NULL,  -- Unique and non-empty topic name with a maximum of 30 characters
    description VARCHAR(500) DEFAULT NULL,  -- Optional description with a maximum of 500 characters
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp for topic creation
);

-- c. Allow registered users to create new posts on existing topics
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    topic_id INT NOT NULL,  -- Foreign key to topics
    user_id INT DEFAULT NULL,  -- Foreign key to users, nullable to dissociate if user is deleted
    title VARCHAR(100) NOT NULL,  -- Required non-empty title with a maximum of 100 characters
    url VARCHAR(4000) DEFAULT NULL,  -- URL or text content must be provided, not both
    text_content TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for post creation
    FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE, -- Cascade delete if topic is deleted
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,  -- Set NULL if user is deleted
    CHECK ((url IS NOT NULL AND text_content IS NULL) OR (url IS NULL AND text_content IS NOT NULL)), -- Ensure only one of url or text_content is present
    CONSTRAINT chk_post_content CHECK (url IS NOT NULL OR text_content IS NOT NULL) -- Ensure at least one content is present
);

-- d. Allow registered users to comment on existing posts
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    post_id INT NOT NULL,  -- Foreign key to posts
    user_id INT DEFAULT NULL,  -- Foreign key to users, nullable to dissociate if user is deleted
    parent_id INT DEFAULT NULL,  -- Self-referential foreign key for comment threads
    text_content TEXT NOT NULL,  -- Required non-empty text content
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for comment creation
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE, -- Cascade delete if post is deleted
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL, -- Set NULL if user is deleted
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE -- Cascade delete if parent comment is deleted
);

-- e. Make sure that a given user can only vote once on a given post
CREATE TABLE votes (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    post_id INT NOT NULL,  -- Foreign key to posts
    user_id INT DEFAULT NULL,  -- Foreign key to users, nullable to dissociate if user is deleted
    value INT NOT NULL CHECK (value IN (1, -1)),  -- Vote value must be 1 (upvote) or -1 (downvote)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for vote creation
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE, -- Cascade delete if post is deleted
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL, -- Set NULL if user is deleted
    UNIQUE (post_id, user_id),  -- Ensure a user can only vote once per post
    CONSTRAINT chk_vote_value CHECK (value IN (1, -1)) -- Ensure valid vote values
);

-- 2. Guideline #2: Queries (Conceptual)

-- a. List all users who haven’t logged in in the last year.
-- b. List all users who haven’t created any post.
-- c. Find a user by their username.
-- d. List all topics that don’t have any posts.
-- e. Find a topic by its name.
-- f. List the latest 20 posts for a given topic.
-- g. List the latest 20 posts made by a given user.
-- h. Find all posts that link to a specific URL, for moderation purposes.
-- i. List all the top-level comments (those that don’t have a parent comment) for a given post.
-- j. List all the direct children of a parent comment.
-- k. List the latest 20 comments made by a given user.
-- l. Compute the score of a post, defined as the difference between the number of upvotes and the number of downvotes.

-- 3. Guideline #3: Normalization, Constraints, and Indexes

-- Indexes for optimization
CREATE INDEX idx_user_username ON users(username); -- Index for quick username lookup
CREATE INDEX idx_topic_name ON topics(name); -- Index for quick topic name lookup
CREATE INDEX idx_post_title ON posts(title); -- Index for quick post title lookup
CREATE INDEX idx_comment_hierarchy ON comments(parent_id); -- Index for quick comment hierarchy traversal
CREATE INDEX idx_vote_post_user ON votes(post_id, user_id); -- Index for quick vote lookup by post and user

-- Add comments to explain constraints
COMMENT ON CONSTRAINT chk_post_content ON posts IS 'Ensures posts have either a URL or text content, but not both.';
COMMENT ON CONSTRAINT chk_vote_value ON votes IS 'Ensures votes have a value of either 1 (upvote) or -1 (downvote).';

-- 4. Guideline #4: Use of Auto-incrementing Primary Key

-- The primary keys for all tables are set as SERIAL, which is an auto-incrementing integer in PostgreSQL.
-- Query to list all users who haven’t logged in in the last year
SELECT username
FROM users
WHERE last_login < CURRENT_DATE - INTERVAL '1 year';

-- Query to list all topics that don’t have any posts
SELECT t.name
FROM topics t
LEFT JOIN posts p ON t.id = p.topic_id
WHERE p.id IS NULL;

-- Query to list the latest 20 posts for a given topic
SELECT p.*
FROM posts p
JOIN topics t ON p.topic_id = t.id
WHERE t.name = 'topic_name'
ORDER BY p.created_at DESC
LIMIT 20;

-- Query to compute the score of a post
SELECT post_id, SUM(value) AS score
FROM votes
GROUP BY post_id;

--JSON Document Query with Nested Comments
-- Recursive CTE to retrieve comments in a nested structure
WITH RECURSIVE comment_tree AS (
    SELECT
        c.id,
        c.text_content,
        c.post_id,
        c.user_id,
        c.parent_comment_id,
        1 AS level
    FROM comments c
    WHERE c.post_id = 1 AND c.parent_comment_id IS NULL
    UNION ALL
    SELECT
        c.id,
        c.text_content,
        c.post_id,
        c.user_id,
        c.parent_comment_id,
        ct.level + 1
    FROM comments c
    JOIN comment_tree ct ON c.parent_comment_id = ct.id
)
SELECT JSON_AGG(comment)
FROM (
    SELECT
        id,
        text_content,
        user_id,
        parent_comment_id,
        level
    FROM comment_tree
    WHERE level <= 3 -- Limit to three levels of nesting
    ORDER BY level, id
) AS comment;
