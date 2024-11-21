--
-- This SQL script was based on the monopoly.sql script found at https://github.com/kvlinden-courses/cs262-code/blob/master/lab07/monopoly.sql 
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
    ID integer PRIMARY KEY,
    EmailAddress varchar(50) NOT NULL,
    Name varchar(50),
    Password varchar(50)
);

CREATE TABLE Item (
    ID integer PRIMARY KEY,
    OwnerAccount integer REFERENCES Account(ID),
    Name text,
    Description text,
    Location point,
    DatePosted timestamp DEFAULT CURRENT_TIMESTAMP
);

-- TAG SECTION -------------------------------------------------------------
CREATE TABLE Tag (
    ID integer PRIMARY KEY,
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
    ID integer PRIMARY KEY,
    Account1 integer REFERENCES Account(ID),
    Account2 integer REFERENCES Account(ID),
    Accepted boolean
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
INSERT INTO Account (ID, EmailAddress, Name, Password) VALUES
(1, 'alice@example.com', 'Alice Smith', 'password123'),
(2, 'bob@example.com', 'Bob Johnson', 'password456'),
(3, 'charlie@example.com', 'Charlie Brown', 'password789');

-- Insert data into Tag
INSERT INTO Tag (ID, Name) VALUES
(1, 'Electronics'),
(2, 'Furniture'),
(3, 'Books'),
(4, 'Wanted'),
(5, 'Free');

-- Insert data into AccountTag
INSERT INTO AccountTag (AccountID, TagID) VALUES
(1, 1),  -- Alice is associated with 'Electronics'
(2, 2),  -- Bob is associated with 'Furniture'
(3, 3),  -- Charlie is associated with 'Books'
(1, 4);  -- Alice is also associated with 'Wanted'

-- Insert data into Item
INSERT INTO Item (ID, OwnerAccount, Name, Description, Location, DatePosted) VALUES
(1, 1, 'Laptop', 'A used laptop in good condition', '(12.34, 56.78)', '2024-11-01 10:00:00'),
(2, 2, 'Sofa', 'A comfortable 3-seater sofa', '(22.34, 45.67)', '2024-11-02 11:00:00'),
(3, 3, 'Book: Programming 101', 'A beginner programming book', '(33.34, 23.45)', '2024-11-03 12:00:00');

-- Insert data into ItemTag
INSERT INTO ItemTag (ItemID, TagID) VALUES
(1, 1),  -- Laptop tagged as 'Electronics'
(2, 2),  -- Sofa tagged as 'Furniture'
(3, 3);  -- Book tagged as 'Books'

-- Insert data into ItemLookingFor
INSERT INTO ItemLookingFor (ItemID, LookingForID) VALUES
(1, 4),  -- Laptop is looking for 'Wanted'
(2, 5);  -- Sofa is looking for 'Free'

-- Insert data into Trade
INSERT INTO Trade (ID, Account1, Account2, Accepted) VALUES
(1, 1, 2, TRUE),  -- Alice and Bob made a trade, accepted
(2, 3, 1, FALSE);  -- Charlie and Alice made a trade, not accepted

-- Insert data into ChatMessage
INSERT INTO ChatMessage (Account1, Account2, Content, TimeSent) VALUES
(1, 2, 'Is the sofa still available?', '2024-11-02 12:00:00'),
(2, 1, 'Yes, it is! Let me know if you are interested.', '2024-11-02 13:00:00'),
(3, 1, 'Can I ask about the laptop?', '2024-11-01 14:00:00');

-- Insert data into RatingReview
INSERT INTO RatingReview (ReviewedAccount, ReviewerAccount, Rating) VALUES
(1, 2, 4),  -- Bob rates Alice 4/5
(2, 1, 5),  -- Alice rates Bob 5/5
(3, 1, 3);  -- Alice rates Charlie 3/5

-- Insert data into LikeSave
INSERT INTO LikeSave (ItemID, AccountID) VALUES
(1, 2),  -- Bob likes Alice's laptop
(2, 3),  -- Charlie likes Bob's sofa
(3, 1);  -- Alice likes Charlie's book


-- -- List all items and their owners' email addresses:

-- SELECT i.ItemID, i.Description, a.emailAddress 
-- FROM Items i
-- JOIN Account a ON i.OwnerAccount = a.ID;


-- -- Find all interests for each account, showing the account's name and their interests:

-- SELECT a.name, i.Interest 
-- FROM Interests i
-- JOIN Account a ON i.Account = a.ID
-- ORDER BY a.name;


-- -- Retrieve all ratings and reviews, including reviewer and reviewed account names, along with their ratings:

-- SELECT a1.name AS Reviewer, a2.name AS Reviewed, rr.Rating
-- FROM RatingReview rr
-- JOIN Account a1 ON rr.ReviewerAccount = a1.ID
-- JOIN Account a2 ON rr.ReviewedAccount = a2.ID;


-- -- Display all trades, showing the names of both accounts involved in each trade:

-- SELECT a1.name AS Account1, a2.name AS Account2 
-- FROM Trade t
-- JOIN Account a1 ON t.Account1 = a1.ID
-- JOIN Account a2 ON t.Account2 = a2.ID;


-- -- Find all items liked or saved by each account, showing the account name and item description:

-- SELECT a.name AS AccountName, i.Description AS ItemLiked 
-- FROM LikeSave ls
-- JOIN Account a ON ls.Account = a.ID
-- JOIN Items i ON ls.ItemID = i.ItemID;


-- -- List all messages between accounts, including the sender, receiver, message content, and time sent:

-- SELECT a1.name AS Sender, a2.name AS Receiver, cm.Content, cm.TimeSent 
-- FROM ChatMessage cm
-- JOIN Account a1 ON cm.Account1 = a1.ID
-- JOIN Account a2 ON cm.Account2 = a2.ID
-- ORDER BY cm.TimeSent;


-- -- Get the average rating received by each account, displaying the account name and their average rating:

-- SELECT a.name, AVG(rr.Rating) AS AverageRating 
-- FROM RatingReview rr
-- JOIN Account a ON rr.ReviewedAccount = a.ID
-- GROUP BY a.name;


-- -- Identify accounts that have received ratings of 4 or higher, showing their names and the high ratings received:

-- SELECT a.name, rr.Rating 
-- FROM RatingReview rr
-- JOIN Account a ON rr.ReviewedAccount = a.ID
-- WHERE rr.Rating >= 4;


-- -- List all items owned by accounts with the interest in 'Cycling', showing the account name and item description:

-- SELECT a.name, i.Description 
-- FROM Items i
-- JOIN Account a ON i.OwnerAccount = a.ID
-- JOIN Interests it ON a.ID = it.Account
-- WHERE it.Interest = 'Cycling';


-- -- Find the number of items each account has liked or saved, displaying the account name and the count of liked items:

-- SELECT a.name, COUNT(ls.ItemID) AS ItemsLiked
-- FROM LikeSave ls
-- JOIN Account a ON ls.Account = a.ID
-- GROUP BY a.name;