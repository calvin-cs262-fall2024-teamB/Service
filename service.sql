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
    emailAddress varchar(50) NOT NULL,
    name varchar(50),
    password varchar(50)
);

CREATE TABLE Items (
    ItemID integer PRIMARY KEY,
    OwnerAccount integer REFERENCES Account(ID),
    Description text
);

CREATE TABLE Interests (
    Account integer REFERENCES Account(ID),
    Interest varchar(50),
    PRIMARY KEY (Account, Interest)
);

CREATE TABLE RatingReview (
    ReviewedAccount integer REFERENCES Account(ID),
    ReviewerAccount integer REFERENCES Account(ID),
    Rating integer,
    PRIMARY KEY (ReviewedAccount, ReviewerAccount)
);

CREATE TABLE Trade (
    Account1 integer REFERENCES Account(ID),
    Account2 integer REFERENCES Account(ID),
    PRIMARY KEY (Account1, Account2)
);

CREATE TABLE LikeSave (
    ItemID integer REFERENCES Items(ItemID),
    Account integer REFERENCES Account(ID),
    PRIMARY KEY (ItemID, Account)
);

CREATE TABLE ChatMessage (
    Account1 integer REFERENCES Account(ID),
    Account2 integer REFERENCES Account(ID),
    Content text,
    TimeSent TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Account1, Account2, TimeSent)
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