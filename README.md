# Service
App service repo. More details can be found [here](https://github.com/calvin-cs262-fall2024-teamB/Project)

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
| **Primary Key**|    
