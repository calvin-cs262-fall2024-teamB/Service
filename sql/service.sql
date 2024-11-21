--
-- This SQL script was based on the monopoly.sql script found at https://github.com/kvlinden-courses/cs262-code/blob/master/lab07/monopoly.sql 
-- 

-- Drop previous versions of the tables if they exist, in reverse order of foreign keys.
DROP TABLE IF EXISTS ChatMessage;
DROP TABLE IF EXISTS LikeSave;
DROP TABLE IF EXISTS Trade;
DROP TABLE IF EXISTS RatingReview;
DROP TABLE IF EXISTS Interests;
DROP TABLE IF EXISTS Items;
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
-- Linked to Accounts (their interests), Items (their tags and lookingFor)
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
    TagID integer REFERENCES Tag(ID)
    PRIMARY Key (ItemID, TagID)
);

CREATE TABLE ItemLookingFor (
    ItemID integer REFERENCES Item(ID),
    LookingForID integer REFERENCES Tag(ID)
    PRIMARY Key (ItemID, LookingForID)
);

-- TRADE SECTION -------------------------------------------------------------
CREATE TABLE Trade (
    ID integer PRIMARY KEY, --Allows for multiple trades between two users
    Account1 integer REFERENCES Account(ID), --Initiator
    Account2 integer REFERENCES Account(ID),
    Accepted boolean,  --Accepted by Account2
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
    ItemID integer REFERENCES Items(ID),
    AccountID integer REFERENCES Account(ID),
    PRIMARY KEY (ItemID, Account)
);

-- Allow Accounts to select data from the tables.
GRANT SELECT ON Account TO PUBLIC;
GRANT SELECT ON Items TO PUBLIC;
GRANT SELECT ON Interests TO PUBLIC;
GRANT SELECT ON RatingReview TO PUBLIC;
GRANT SELECT ON Trade TO PUBLIC;
GRANT SELECT ON LikeSave TO PUBLIC;
GRANT SELECT ON ChatMessage TO PUBLIC;

INSERT INTO Account (ID, emailAddress, name, password) VALUES 
(1, 'me@calvin.edu', 'Account One', 'password123'),
(2, 'king@gmail.com', 'The King', 'kingpass'),
(3, 'dog@gmail.com', 'Dogbreath', 'dogpass');

INSERT INTO Items (ItemID, OwnerAccount, Description) VALUES 
(1, 1, 'Vintage camera'),
(2, 2, 'Mountain bike'),
(3, 3, 'Old books collection');

-- Add sample records for Interests table
INSERT INTO Interests (Account, Interest) VALUES 
(1, 'Electronics'),
(1, 'Photography'),
(1, 'Travel'),
(2, 'Furniture'),
(2, 'Cycling'),
(3, 'Clothing'),
(3, 'Reading'),
(3, 'History');

INSERT INTO RatingReview (ReviewedAccount, ReviewerAccount, Rating) VALUES 
(1, 2, 5),
(2, 3, 4),
(1, 3, 3),
(2, 1, 4),
(3, 1, 3);

INSERT INTO Trade (Account1, Account2) VALUES 
(1, 2),
(2, 3);

INSERT INTO LikeSave (ItemID, Account) VALUES 
(1, 1),
(2, 2),
(3, 3);

INSERT INTO ChatMessage (Account1, Account2, Content) VALUES 
(1, 2, 'Hello!'),
(2, 1, 'Hi there!'),
(3, 1, 'What up?');


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