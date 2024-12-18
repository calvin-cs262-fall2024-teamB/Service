# Service
App service repo. More details can be found [here](https://github.com/calvin-cs262-fall2024-teamB/Project)
Domain: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net

- login authentication: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/login              
  - takes in the email and (...plaintext) password from the json body 

- Market item fetching: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/market/:id

- User Items: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/items/:id
- User Item Creation: /items, { ownerAccount, name, description, location, imageData, itemTags, lookingForTags } in request body, first 4 fields required.
  - Example input:
    - {
        "ownerAccount": 1,
        "name": "Placeholder Item",
        "description": "This is a sample item for testing purposes.",
        "location": "(40.7128, -74.0060)",
        "imageData": [
          {
            "data": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA...",
            "description": "Placeholder image for testing."
          }
        ],
        "itemTags": ["toys", "games"],
        "lookingForTags": ["decor", "kitchenware"]
      }
- Update Item: /items, { id, name, description, location, itemTags, lookingForTags, imageData } in request body, only ID required
- Delete Item: /items, {id} in request body

- Trade fetching: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/trades/:id
  - id of account associated with trade
- Trade Updating: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/updateTrades/:id1/:id2
  - id1: initiator, id2: receiver
  - If the trade exists (in either direction): updates the accepted field to true (both users are interested)
  - If the trade does not exist: creates a new trade entry with the accepted field as false

### Example Outputs of readMarket and readAccount Items:
```
[
  {
    "itemid": 2,
    "itemownerid": 2,
    "itemname": "Sofa",
    "itemdescription": "A comfortable 3-seater sofa",
    "itemlocation": {
      "x": 22.34,
      "y": 45.67
    },
    "dateposted": "2024-11-02T15:00:00.000Z",
    "itemtags": [
      "Furniture"
    ],
    "lookingfortags": [
      "Free",
      "Furniture"
    ]
  },
  {
    "itemid": 10,
    "itemownerid": 2,
    "itemname": "Dining Table",
    "itemdescription": "A large wooden dining table, 6 seats",
    "itemlocation": {
      "x": 37.22,
      "y": 20.33
    },
    "dateposted": "2024-11-10T20:00:00.000Z",
    "itemtags": [
      "Furniture"
    ],
    "lookingfortags": [null]
  }
]
```

### Example Output of readTrades (for userID=2):
```
[
  {
    "tradeid": 1,
    "user1id": 1,
    "user2id": 2,
    "otheruserid": 1,
    "tradeaccepted": true
  },
  {
    "tradeid": 4,
    "user1id": 2,
    "user2id": 6,
    "otheruserid": 6,
    "tradeaccepted": false
  }
]
```

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

## ItemImage Table
Stores images related to items.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ID             | integer      | PRIMARY KEY               | Unique identifier for each item image.   |
| ItemID         | integer      | REFERENCES Item(ID)       | ID of the associated item.               |
| ImageData      | text         | NOT NULL                  | Base64-encoded image data.               |
| Description    | text         |                           | Optional description for the image.      |

---

## AccountImage Table
Stores images related to user accounts.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ID             | integer      | PRIMARY KEY               | Unique identifier for each account image.|
| AccountID      | integer      | REFERENCES Account(ID)    | ID of the associated account.            |
| ImageData      | text         | NOT NULL                  | Base64-encoded image data.               |
| Description    | text         |                           | Optional description for the image.      |

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
| Account1       | integer      | REFERENCES Account(ID)    | ID of the first user involved in the trade. |
| Account2       | integer      | REFERENCES Account(ID)    | ID of the second user involved in the trade. |
| Accepted       | boolean      |                           | Indicates if the trade was accepted.     |
| **Primary Key**|              | (Account1, Account2)      | Composite key to ensure uniqueness.      |

---

## ChatMessage Table
Stores messages exchanged between users.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| Account1       | integer      | REFERENCES Account(ID)    | ID of the sender.                        |
| Account2       | integer      | REFERENCES Account(ID)    | ID of the recipient.                     |
| Content        | text         |                           | Message content.                         |
| TimeSent       | timestamp    | DEFAULT CURRENT_TIMESTAMP | Timestamp when the message was sent.     |
| **Primary Key**|              | (Account1, Account2, TimeSent) | Composite key to ensure uniqueness.    |

---

## RatingReview Table
Stores ratings and reviews given by one user to another.

| Column            | Type       | Constraints               | Description                              |
|-------------------|------------|---------------------------|------------------------------------------|
| ReviewedAccount   | integer    | REFERENCES Account(ID)    | ID of the user being reviewed.           |
| ReviewerAccount   | integer    | REFERENCES Account(ID)    | ID of the user giving the review.        |
| Rating            | integer    |                           | Rating score provided by the reviewer.   |
| **Primary Key**   |            | (ReviewedAccount, ReviewerAccount) | Composite key to ensure uniqueness.    |

---

## LikeSave Table
Stores items that users have liked or saved.

| Column         | Type         | Constraints               | Description                              |
|----------------|--------------|---------------------------|------------------------------------------|
| ItemID         | integer      | REFERENCES Item(ID)       | ID of the liked or saved item.           |
| AccountID      | integer      | REFERENCES Account(ID)    | ID of the user who liked or saved the item. |
| **Primary Key**|              | (ItemID, AccountID)       | Composite key to ensure uniqueness.      |
