# Database Schema

## Account Table
Stores information about user accounts.

| Column         | Type       | Constraints                |
|----------------|------------|----------------------------|
| ID             | integer    | PRIMARY KEY                |
| emailAddress   | varchar(50) | NOT NULL                   |
| name           | varchar(50) |                            |
| password       | varchar(50) |                            |

---

## Items Table
Stores items owned by users.

| Column         | Type       | Constraints                |
|----------------|------------|----------------------------|
| ItemID         | integer    | PRIMARY KEY                |
| OwnerAccount   | integer    | REFERENCES Account(ID)     |
| Description    | text       |                            |

---

## Interests Table
Stores user interests.

| Column         | Type       | Constraints                |
|----------------|------------|----------------------------|
| Account        | integer    | REFERENCES Account(ID)     |
| Interest       | varchar(50) |                            |
| **Primary Key**|            | (Account, Interest)        |

---

## RatingReview Table
Stores ratings and reviews given by one user to another.

| Column         | Type       | Constraints                |
|----------------|------------|----------------------------|
| ReviewedAccount | integer   | REFERENCES Account(ID)     |
| ReviewerAccount | integer   | REFERENCES Account(ID)     |
| Rating         | integer    |                            |
| **Primary Key**|            | (ReviewedAccount, ReviewerAccount) |

---

## Trade Table
Stores information about trades between users.

| Column         | Type       | Constraints                |
|----------------|------------|----------------------------|
| Account1       | integer    | REFERENCES Account(ID)     |
| Account2       | integer    | REFERENCES Account(ID)     |
| **Primary Key**|            | (Account1, Account2)       |

---

## LikeSave Table
Stores items liked or saved by users.

| Column         | Type       | Constraints                |
|----------------|------------|----------------------------|
| ItemID         | integer    | REFERENCES Items(ItemID)   |
| Account        | integer    | REFERENCES Account(ID)     |
| **Primary Key**|            | (ItemID, Account)          |

---

## ChatMessage Table
Stores messages exchanged between users.

| Column         | Type       | Constraints                |
|----------------|------------|----------------------------|
| Account1       | integer    | REFERENCES Account(ID)     |
| Account2       | integer    | REFERENCES Account(ID)     |
| Content        | text       |                            |
| TimeSent       | TIMESTAMP  | DEFAULT CURRENT_TIMESTAMP  |
| **Primary Key**|            | (Account1, Account2, TimeSent) |
