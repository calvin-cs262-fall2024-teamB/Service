--
-- This SQL script was based on the monopoly.sql script found at https://github.com/kvlinden-courses/cs262-code/blob/master/lab07/monopoly.sql 
-- 
--
--
-- Drop previous versions of the tables if they exist, in reverse order of foreign keys.
DROP TABLE IF EXISTS ChatMessage;
DROP TABLE IF EXISTS LikeSave;
DROP TABLE IF EXISTS Trade;
DROP TABLE IF EXISTS RatingReview;
DROP TABLE IF EXISTS AccountTag;
DROP TABLE IF EXISTS ItemTag;
DROP TABLE IF EXISTS ItemLookingFor;
DROP TABLE IF EXISTS Tag;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS Account;

CREATE TABLE Account (
    ID SERIAL PRIMARY KEY,
    EmailAddress varchar(50) NOT NULL,
    Name varchar(50),
    Password varchar(50)
);

CREATE TABLE Item (
    ID SERIAL PRIMARY KEY,
    OwnerAccount integer REFERENCES Account(ID),
    Name text,
    Description text,
    Location point,
    DatePosted timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ItemImage (
    ID SERIAL PRIMARY KEY,
    ItemID INTEGER REFERENCES Item(ID),
    ImageData TEXT NOT NULL, -- Base64-encoded image data
    Description TEXT -- Optional description for the image
);

CREATE TABLE AccountImage (
    ID SERIAL PRIMARY KEY,
    AccountID INTEGER REFERENCES Account(ID),
    ImageData TEXT NOT NULL, -- Base64-encoded image data
    Description TEXT -- Optional description for the image
);

-- TAG SECTION -------------------------------------------------------------
CREATE TABLE Tag (
    ID SERIAL PRIMARY KEY,
    Name varchar(15)
);

CREATE TABLE AccountTag (
    AccountID integer REFERENCES Account(ID),
    TagID integer REFERENCES Tag(ID),
    PRIMARY KEY (AccountID, TagID)
);

CREATE TABLE ItemTag (
    ItemID integer REFERENCES Item(ID),
    TagID integer REFERENCES Tag(ID),
    PRIMARY KEY (ItemID, TagID)
);

CREATE TABLE ItemLookingFor (
    ItemID integer REFERENCES Item(ID),
    LookingForID integer REFERENCES Tag(ID),
    PRIMARY KEY (ItemID, LookingForID)
);

-- TRADE SECTION -------------------------------------------------------------
CREATE TABLE Trade (
    Account1 integer REFERENCES Account(ID),
    Account2 integer REFERENCES Account(ID),
    Accepted boolean,
    PRIMARY KEY (Account1, Account2)
);

CREATE TABLE ChatMessage (
    Account1 integer REFERENCES Account(ID),
    Account2 integer REFERENCES Account(ID),
    Content text,
    TimeSent TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Account1, Account2, TimeSent)
);

CREATE TABLE RatingReview (
    ReviewedAccount integer REFERENCES Account(ID),
    ReviewerAccount integer REFERENCES Account(ID),
    Rating integer,
    PRIMARY KEY (ReviewedAccount, ReviewerAccount)
);

CREATE TABLE LikeSave (
    ItemID integer REFERENCES Item(ID),
    AccountID integer REFERENCES Account(ID),
    PRIMARY KEY (ItemID, AccountID)
);

-- Allow Accounts to select data from the tables.
GRANT SELECT ON Account TO PUBLIC;
GRANT SELECT ON Item TO PUBLIC;
GRANT SELECT ON ItemImage TO PUBLIC;
GRANT SELECT ON AccountImage TO PUBLIC;
GRANT SELECT ON Tag TO PUBLIC;
GRANT SELECT ON ItemLookingFor TO PUBLIC;
GRANT SELECT ON ItemTag TO PUBLIC;
GRANT SELECT ON AccountTag TO PUBLIC;
GRANT SELECT ON RatingReview TO PUBLIC;
GRANT SELECT ON Trade TO PUBLIC;
GRANT SELECT ON LikeSave TO PUBLIC;
GRANT SELECT ON ChatMessage TO PUBLIC;

-- SAMPLE DATA ----------------------------------------------------------------
-- Insert data into Account
INSERT INTO Account (EmailAddress, Name, Password) VALUES
('alice@example.com', 'Alice Smith', 'password123'),
('bob@example.com', 'Bob Johnson', 'password456'),
('charlie@example.com', 'Charlie Brown', 'password789'),
('david@example.com', 'David Clark', 'password101'),
('ellen@example.com', 'Ellen White', 'password102'),
('frank@example.com', 'Frank Green', 'password103'),
('grace@example.com', 'Grace Lee', 'password104'),
('hannah@example.com', 'Hannah Black', 'password105');


-- Insert data into Tag
INSERT INTO Tag (Name) VALUES
('books'), ('decor'), ('kitchenware'), ('furniture'), ('appliances'), 
('electronics'), ('toys'), ('games');

-- Insert data into AccountTag
INSERT INTO AccountTag (AccountID, TagID) VALUES
(1, 1), (2, 2), (3, 3), (1, 4), (4, 1),
(5, 7), (6, 6), (7, 2), (8, 3), (1, 5),
(2, 6), (3, 4), (4, 5);

-- Insert data into Item
INSERT INTO Item (OwnerAccount, Name, Description, Location, DatePosted) VALUES
(1, 'Laptop', 'A used laptop in good condition', '(12.34, 56.78)', '2024-11-01 10:00:00'),
(2, 'Sofa', 'A comfortable 3-seater sofa', '(22.34, 45.67)', '2024-11-02 11:00:00'),
(3, 'Book: Programming 101', 'A beginner programming book', '(33.34, 23.45)', '2024-11-03 12:00:00'),
(4, 'Soccer Ball', 'A used soccer ball for sale', '(15.12, 35.22)', '2024-11-04 09:00:00'),
(5, 'Winter Coat', 'A warm winter coat, size M', '(20.33, 45.55)', '2024-11-05 10:00:00'),
(6, 'Toy Train', 'A collectible toy train in good condition', '(23.44, 50.66)', '2024-11-06 11:00:00'),
(7, 'Garden Tools', 'A set of gardening tools, lightly used', '(27.55, 33.77)', '2024-11-07 12:00:00'),
(8, 'Guitar', 'An acoustic guitar for beginners', '(30.66, 40.88)', '2024-11-08 13:00:00'),
(2, 'Smartphone', 'A new smartphone, 128GB, unlocked', '(35.11, 25.22)', '2024-11-09 14:00:00'),
(2, 'Dining Table', 'A large wooden dining table, 6 seats', '(37.22, 20.33)', '2024-11-10 15:00:00');


-- Insert data into ItemTag
INSERT INTO ItemTag (ItemID, TagID) VALUES
(1, 1),  -- Laptop tagged as 'Electronics'
(1, 6),  -- Laptop tagged as 'School Supplies'
(2, 2),  -- Sofa tagged as 'Furniture'
(3, 3),  -- Book tagged as 'Books'
(4, 1),  -- Soccer Ball tagged as 'Sports'
(5, 7),  -- Winter Coat tagged as 'Clothing'
(6, 6),  -- Toy Train tagged as 'Toys'
(7, 1),  -- Garden Tools tagged as 'Gardening'
(8, 3), -- Guitar tagged as 'Music'
(9, 1),  -- Smartphone tagged as 'Electronics'
(10, 2); -- Dining Table tagged as 'Furniture'

-- Insert data into ItemLookingFor
INSERT INTO ItemLookingFor (ItemID, LookingForID) VALUES
(1, 4),  -- Laptop is looking for 'Wanted'
(2, 5),  -- Sofa is looking for 'Free'
(2, 2),  -- Sofa is looking for 'Furniture'
(4, 6),  -- Soccer Ball is looking for 'Wanted Items'
(5, 5),   -- Winter Coat is looking for 'Free Stuff'
(6, 3),  -- Toy Train is looking for 'Free Stuff'
(7, 1),   -- Garden Tools are looking for 'Gardening'
(8, 2);  -- Guitar is looking for 'Music'

-- Insert data into Trade
INSERT INTO Trade (Account1, Account2, Accepted) VALUES
(1, 2, TRUE),  -- Alice and Bob made a trade, accepted
(3, 1, FALSE),  -- Charlie and Alice made a trade, not accepted
(1, 4, TRUE),  -- Alice and David made a trade, accepted
(2, 6, FALSE), -- Bob and Frank made a trade, not accepted
(3, 5, TRUE),  -- Charlie and Ellen made a trade, accepted
(7, 8, TRUE);  -- Grace and Hannah made a trade, accepted

-- Insert data into ChatMessage
INSERT INTO ChatMessage (Account1, Account2, Content, TimeSent) VALUES
(1, 2, 'Is the sofa still available?', '2024-11-02 12:00:00'),
(2, 1, 'Yes, it is! Let me know if you are interested.', '2024-11-02 13:00:00'),
(3, 1, 'Can I ask about the laptop?', '2024-11-01 14:00:00'),
(1, 4, 'I am interested in the soccer ball. Can you send more pictures?', '2024-11-04 09:30:00'),
(4, 1, 'Sure! Here they are. Let me know if you want to proceed.', '2024-11-04 10:00:00'),
(2, 6, 'Is the toy train still available?', '2024-11-06 11:30:00'),
(6, 2, 'Yes, it is! Let me know if you are interested.', '2024-11-06 12:00:00'),
(3, 5, 'Do you still have the winter coat?', '2024-11-05 10:30:00'),
(5, 3, 'Yes, I do! It is still available.', '2024-11-05 11:00:00'),
(7, 8, 'Is the guitar available for trade?', '2024-11-08 13:30:00'),
(8, 7, 'Yes, I am interested in the gardening tools.', '2024-11-08 14:00:00');

-- Insert data into RatingReview
INSERT INTO RatingReview (ReviewedAccount, ReviewerAccount, Rating) VALUES
(1, 2, 4),  -- Bob rates Alice 4/5
(2, 1, 5),  -- Alice rates Bob 5/5
(3, 1, 3),  -- Alice rates Charlie 3/5
(1, 4, 5),  -- David rates Alice 5/5
(2, 6, 4),  -- Frank rates Bob 4/5
(3, 5, 5),  -- Ellen rates Charlie 5/5
(4, 8, 3),  -- Hannah rates David 3/5
(5, 7, 4);  -- Grace rates Ellen 4/5

-- Insert data into LikeSave
INSERT INTO LikeSave (ItemID, AccountID) VALUES
(1, 2),  -- Bob likes Alice's laptop
(2, 3),  -- Charlie likes Bob's sofa
(3, 1),  -- Alice likes Charlie's book
(4, 5),  -- Ellen likes David's soccer ball
(5, 6),  -- Frank likes Ellen's winter coat
(6, 1),  -- Alice likes Frank's toy train
(7, 2),  -- Bob likes Grace's gardening tools
(8, 3),  -- Charlie likes Hannah's guitar
(9, 7),  -- Grace likes Alice's smartphone
(10, 4); -- David likes Bob's dining table