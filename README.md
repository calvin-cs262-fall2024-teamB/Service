# Service
App service repo. More details can be found [here](https://github.com/calvin-cs262-fall2024-teamB/Project)
Domain: bombastic-service-adeka8bebuhphycn.canadacentral-01.azurewebsites.net

- login authentication: /login              takes in the email and (...plaintext) password from the json body 
- Market item fetching: /market/:id         //id of account
- User Item fetching: /items/:id            //id of account

# Database Schema

## Account Table
Stores information about user accounts.

| Column         | Type         | Constraints               | Description                      |
|----------------|--------------|---------------------------|----------------------------------|
| ID             | integer      | PRIMARY KEY               | Unique identifier for each user. |
| emailAddress   | varchar(50)  | NOT NULL                  | User's email address.            |
| name           | varchar(50)  |                           | Name of the account holder.      |
| password       | varchar(50)  |                           | User's account password.         |

---

## Items Table
Stores items owned by users.

| Column         | Type         | Constraints               | Description                             |
|----------------|--------------|---------------------------|-----------------------------------------|
| ItemID         | integer      | PRIMARY KEY               | Unique identifier for each item.        |
| OwnerAccount   | integer      | REFERENCES Account(ID)    | ID of the user who owns the item.       |
| Description    | text         |                           | Brief description of the item.          |

---

## Interests Table
Stores user interests.

| Column         | Type         | Constraints               | Description                             |
|----------------|--------------|---------------------------|-----------------------------------------|
| Account        | integer      | REFERENCES Account(ID)    | ID of the user with the interest.       |
| Interest       | varchar(50)  |                           | Specific interest of the user.          |
| **Primary Key**|              | (Account, Interest)       | Composite key to ensure uniqueness.     |

---

## RatingReview Table
Stores ratings and reviews given by one user to another.

| Column            | Type       | Constraints               | Description                             |
|-------------------|------------|---------------------------|-----------------------------------------|
| ReviewedAccount   | integer    | REFERENCES Account(ID)    | ID of the user being reviewed.          |
| ReviewerAccount   | integer    | REFERENCES Account(ID)    | ID of the user giving the review.       |
| Rating            | integer    |                           | Rating score provided by the reviewer.  |
| **Primary Key**   |            | (ReviewedAccount, ReviewerAccount) | Composite key to prevent duplicate reviews. |

---

## Trade Table
Stores trade relationships between users.

| Column         | Type         | Constraints               | Description                             |
|----------------|--------------|---------------------------|-----------------------------------------|
| Account1       | integer      | REFERENCES Account(ID)    | ID of one participant in the trade.     |
| Account2       | integer      | REFERENCES Account(ID)    | ID of the other participant in the trade.|
| **Primary Key**|              | (Account1, Account2)      | Composite key to ensure unique trades.  |

---

## LikeSave Table
Stores information about items that users have liked or saved.

| Column         | Type         | Constraints               | Description                             |
|----------------|--------------|---------------------------|-----------------------------------------|
| ItemID         | integer      | REFERENCES Items(ItemID)  | ID of the liked or saved item.          |
| Account        | integer      | REFERENCES Account(ID)    | ID of the user who liked/saved the item.|
| **Primary Key**|              | (ItemID, Account)         | Composite key to prevent duplicates.    |

---

## ChatMessage Table
Stores messages sent between users.

| Column         | Type         | Constraints               | Description                             |
|----------------|--------------|---------------------------|-----------------------------------------|
| Account1       | integer      | REFERENCES Account(ID)    | ID of the sender.                       |
| Account2       | integer      | REFERENCES Account(ID)    | ID of the recipient.                    |
| Content        | text         |                           | The text content of the message.        |
| TimeSent       | TIMESTAMP    | DEFAULT CURRENT_TIMESTAMP | Timestamp when the message was sent.    |
| **Primary Key**|              | (Account1, Account2, TimeSent) | Composite key to ensure unique messages. |
