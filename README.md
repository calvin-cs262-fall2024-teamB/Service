# Service
App service repo. More details can be found [here](https://github.com/calvin-cs262-fall2024-teamB/Project)
Domain: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net

- login authentication: /login              takes in the email and (...plaintext) password from the json body 

- Market item fetching: /market/:id         //id of account
- User Item fetching: /items/:id            //id of account
### Example Outputs of readMarket and readAccount Items:
{
  "items": [
      {
          "ItemID": 1,
          "Name": "Laptop",
          "Description": "A used laptop in good condition",
          "Location": "(12.34, 56.78)",
          "DatePosted": "2024-11-01T10:00:00",
          "Tags": ["Electronics"],
          "LookingFor": ["Wanted"]
      },
      {
          "ItemID": 2,
          "Name": "Sofa",
          "Description": "A comfortable 3-seater sofa",
          "Location": "(22.34, 45.67)",
          "DatePosted": "2024-11-02T11:00:00",
          "Tags": ["Furniture"],
          "LookingFor": ["Free"]
      }
  ]
}

# Database Schema

## Account Table
Stores user account information.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ID             | integer      | PRIMARY KEY               | Unique identifier for each account.      |
| EmailAddress   | varchar(50)  | NOT NULL                  | Email address of the account holder.     |
| Name           | varchar(50)  |                           | Name of the account holder.              |
| Password       | varchar(50)  |                           | Encrypted or hashed password for the account. |

---

## Item Table
Stores items owned by users.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ID             | integer      | PRIMARY KEY               | Unique identifier for each item.         |
| OwnerAccount   | integer      | REFERENCES Account(ID)    | ID of the user who owns the item.        |
| Name           | text         |                           | Name of the item.                        |
| Description    | text         |                           | Brief description of the item.           |
| Location       | point        |                           | Geographical location of the item.       |
| DatePosted     | timestamp    | DEFAULT CURRENT_TIMESTAMP | Timestamp when the item was posted.      |

---

## Tag Table
Stores tags for categorization purposes.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ID             | integer      | PRIMARY KEY               | Unique identifier for each tag.          |
| Name           | varchar(15)  |                           | Name of the tag.                         |

---

## AccountTag Table
Stores relationships between users and tags.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| AccountID      | integer      | REFERENCES Account(ID)    | ID of the user.                          |
| TagID          | integer      | REFERENCES Tag(ID)        | ID of the tag associated with the user.  |
| **Primary Key**|              | (AccountID, TagID)        | Composite key to ensure uniqueness.      |

---

## ItemTag Table
Stores relationships between items and tags.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ItemID         | integer      | REFERENCES Item(ID)       | ID of the item.                          |
| TagID          | integer      | REFERENCES Tag(ID)        | ID of the tag associated with the item.  |
| **Primary Key**|              | (ItemID, TagID)           | Composite key to ensure uniqueness.      |

---

## ItemLookingFor Table
Stores tags that represent what an item is being traded for.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ItemID         | integer      | REFERENCES Item(ID)       | ID of the item.                          |
| LookingForID   | integer      | REFERENCES Tag(ID)        | ID of the desired tag for the trade.     |
| **Primary Key**|              | (ItemID, LookingForID)    | Composite key to ensure uniqueness.      |

---

## Trade Table
Stores trade relationships between users.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ID             | integer      | PRIMARY KEY               | Unique identifier for the trade.         |
| Account1       | integer      | REFERENCES Account(ID)    | ID of the first user involved in the trade. |
| Account2       | integer      | REFERENCES Account(ID)    | ID of the second user involved in the trade. |
| Accepted       | boolean      |                           | Indicates if the trade was accepted.     |

---

## ChatMessage Table
Stores messages exchanged between users.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| Account1       | integer      | REFERENCES Account(ID)    | ID of the sender.                        |
| Account2       | integer      | REFERENCES Account(ID)    | ID of the recipient.                     |
| Content        | text         |                           | Message content.                         |
| TimeSent       | timestamp    | DEFAULT CURRENT_TIMESTAMP | Timestamp when the message was sent.     |
| **Primary Key**|              | (Account1, Account2, TimeSent) | Composite key to ensure uniqueness.      |

---

## RatingReview Table
Stores ratings and reviews given by one user to another.

| Column            | Type       | Constraints               | Description                              |
|-------------------|------------|---------------------------|------------------------------------------|
| ReviewedAccount   | integer    | REFERENCES Account(ID)    | ID of the user being reviewed.           |
| ReviewerAccount   | integer    | REFERENCES Account(ID)    | ID of the user giving the review.        |
| Rating            | integer    |                           | Rating score provided by the reviewer.   |
| **Primary Key**   |            | (ReviewedAccount, ReviewerAccount) | Composite key to ensure uniqueness.      |

---

## LikeSave Table
Stores items that users have liked or saved.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ItemID         | integer      | REFERENCES Item(ID)       | ID of the liked or saved item.           |
| AccountID      | integer      | REFERENCES Account(ID)    | ID of the user who liked or saved the item. |
| **Primary Key**|              | (ItemID, AccountID)       | Composite key to ensure uniqueness.      |

---
