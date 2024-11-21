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
GRANT SELECT ON RatingReview TO PUBLIC;
GRANT SELECT ON Trade TO PUBLIC;
GRANT SELECT ON LikeSave TO PUBLIC;
GRANT SELECT ON ChatMessage TO PUBLIC;


-- SAMPLE DATA ----------------------------------------------------------------
-- Account table sample data
INSERT INTO Account (ID, EmailAddress, Name, Password) VALUES 
(4, 'alice@gmail.com', 'Alice Wonderland', 'alice123'),
(5, 'bob@gmail.com', 'Bob Builder', 'bobthebuilder'),
(6, 'eve@gmail.com', 'Eve Lution', 'evolution');

-- Item table sample data
INSERT INTO Item (ID, OwnerAccount, Name, Description, Location) VALUES 
(4, 1, 'Guitar', 'An acoustic guitar with great sound quality.', '(12, 20)'),
(5, 2, 'Laptop', 'High-performance gaming laptop.', '(14, 22)'),
(6, 3, 'Tent', 'A 4-person camping tent.', '(16, 30)'),
(7, 4, 'Desk Chair', 'Ergonomic office chair.', '(20, 25)'),
(8, 5, 'Cookware Set', 'Stainless steel pots and pans.', '(18, 24)'),
(9, 6, 'Painting', 'A beautiful landscape painting.', '(22, 28)');

-- Tag table sample data
INSERT INTO Tag (ID, Name) VALUES 
(1, 'Electronics'),
(2, 'Furniture'),
(3, 'Music'),
(4, 'Sports'),
(5, 'Books'),
(6, 'Art'),
(7, 'Outdoor');

-- AccountTag table sample data
INSERT INTO AccountTag (AccountID, TagID) VALUES 
(1, 3), -- Account 1 is interested in Music
(1, 5), -- Account 1 is interested in Books
(2, 4), -- Account 2 is interested in Sports
(3, 7), -- Account 3 is interested in Outdoor activities
(4, 2), -- Account 4 is interested in Furniture
(5, 6), -- Account 5 is interested in Art
(6, 1); -- Account 6 is interested in Electronics

-- ItemTag table sample data
INSERT INTO ItemTag (ItemID, TagID) VALUES 
(4, 3), -- Guitar tagged as Music
(5, 1), -- Laptop tagged as Electronics
(6, 7), -- Tent tagged as Outdoor
(7, 2), -- Desk Chair tagged as Furniture
(8, 4), -- Cookware Set tagged as Sports (used for outdoor cooking)
(9, 6); -- Painting tagged as Art

-- ItemLookingFor table sample data
INSERT INTO ItemLookingFor (ItemID, LookingForID) VALUES 
(4, 1), -- Guitar owner is looking for Electronics
(5, 7), -- Laptop owner is looking for Outdoor gear
(6, 3), -- Tent owner is looking for Music instruments
(7, 6), -- Desk Chair owner is looking for Art
(8, 5), -- Cookware Set owner is looking for Books
(9, 4); -- Painting owner is looking for Sports equipment

-- Trade table sample data
INSERT INTO Trade (ID, Account1, Account2, Accepted) VALUES 
(3, 4, 1, TRUE),  -- Alice traded with Account One
(4, 5, 2, FALSE), -- Bob attempted a trade with The King, but it was declined
(5, 6, 3, TRUE);  -- Eve successfully traded with Dogbreath

-- ChatMessage table sample data
INSERT INTO ChatMessage (Account1, Account2, Content) VALUES 
(4, 5, 'Hi Bob, interested in a trade?'),
(5, 4, 'Hey Alice, yes I am!'),
(6, 3, 'Hello, is the tent still available?'),
(3, 6, 'Yes, it is. Let me know what you can offer.');

-- RatingReview table sample data
INSERT INTO RatingReview (ReviewedAccount, ReviewerAccount, Rating) VALUES 
(4, 5, 5), -- Alice received a 5-star rating from Bob
(5, 4, 4), -- Bob received a 4-star rating from Alice
(6, 3, 3), -- Eve got a 3-star rating from Dogbreath
(3, 6, 5), -- Dogbreath gave a 5-star rating to Eve
(2, 1, 4); -- The King received a 4-star rating from Account One

-- LikeSave table sample data
INSERT INTO LikeSave (ItemID, AccountID) VALUES 
(4, 1), -- Account One liked Guitar
(5, 2), -- The King liked Laptop
(6, 3), -- Dogbreath liked Tent
(7, 4), -- Alice liked Desk Chair
(8, 5), -- Bob liked Cookware Set
(9, 6); -- Eve liked Painting


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