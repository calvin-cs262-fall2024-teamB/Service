# Service
App service repo. More details can be found [here](https://github.com/calvin-cs262-fall2024-teamB/Project)
Domain: bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net

- **Login Authentication:**  
  `POST bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/login`  
  - **Example Input:**
    ```json
    {
        "email": "tester@gmail.com",
        "password": "tester"
    }
    ```
  - **Example Output:**
    ```json
    {
        "message": "Login successful"
    }
    ```

- **Account Creation:**  
  `POST bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/account`  
  - **Example Input:**
    ```json
    {
        "name": "tester",
        "email": "tester@gmail.com",
        "password": "tester"
    }
    ```
  - **Example Output:**
    ```json
    {
        "message": "Account created successfully.",
        "account": {
            "id": 11,
            "emailaddress": "testing@abc.com",
            "name": "testing TESTING"
        }
    }
    ```

- **Market Item Fetching:**  
  `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/market/:id`

- **User Items:**  
  `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/items/:id`

### Example Outputs of `readMarket` and `readAccount Items`:
```json
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
        "itemtags": ["Furniture"],
        "lookingfortags": ["Free", "Furniture"]
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
        "itemtags": ["Furniture"],
        "lookingfortags": [null]
    }
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
        "itemtags": ["Furniture"],
        "lookingfortags": ["Free", "Furniture"]
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
        "itemtags": ["Furniture"],
        "lookingfortags": [null]
    }
]
```

- **User Item Creation:**  
  Endpoint: `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/items`  
  - Request body: `{ ownerAccount, name, description, location, imageData, itemTags, lookingForTags }`  
    (first 4 fields required)  
  - **Example Input:**
    ```json
    {
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
    ```

- **Update Item:**  
  Endpoint: `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/items`  
  - Request body: `{ id, name, description, location, itemTags, lookingForTags, imageData }` (only ID is required).

- **Delete Item:**  
  Endpoint: `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/items`  
  - Request body: `{ id }`

- **Trade Fetching:**  
  `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/trades/:id`  
  - ID of the account associated with the trade.
  - **Example Output** for id=2
    ```json
    [
        {
            "tradeid": 7,
            "user1id": 1,
            "user2id": 2,
            "otheruserid": 1,
            "tradeaccepted": true,
            "tradeitems": [
                {
                    "itemid": 2,
                    "itemownerid": 2,
                    "itemname": "Sofa"
                },
                {
                    "itemid": 1,
                    "itemownerid": 1,
                    "itemname": "Laptop"
                }
            ]
        },
        {
            "tradeid": 9,
            "user1id": 1,
            "user2id": 2,
            "otheruserid": 1,
            "tradeaccepted": false,
            "tradeitems": [
                {
                    "itemid": 1,
                    "itemownerid": 1,
                    "itemname": "Laptop"
                },
                {
                    "itemid": 3,
                    "itemownerid": 3,
                    "itemname": "Programming 101"
                }
            ]
        },
    ]
    ```

- **Trade Updating:**  
  Endpoint: `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/updateTrades/`  
  - **Example Input:**
    ```json
    {
        "account1_id": 1,
        "account2_id": 2,
        "accepted": false,
        "item_ids": [101, 102, 103]
    }
    ```
  - **Example Output:**
    ```json
    {
        "message": "Trade updated successfully",
        "trade": {
            "id": 10,
            "account1": 4,
            "account2": 2,
            "accepted": true,
            "items": [4, 2]
        }
    }
    ```

    - **Behavior:**
      - If the trade exists (in either direction): Updates the `accepted` field to `true` (both users are interested).
      - If the trade does not exist: Creates a new trade entry with the `accepted` field as `false`.

- **Message Creation:**  
  Endpoint: `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/messages`  
  - **Example Input:**
    ```json
    {
      "id1": 1,
      "id2": 2,
      "content": "Hello! How are you?"
    }
    ```
- **Message Reading:**  
  Endpoint: `bombasticweb-dmenc3dmg9hhcxgk.canadaeast-01.azurewebsites.net/messages`  
  - **Example Input:**
    ```json
    {
      "id1": 1,
      "id2": 2,
    }
    ```
  - **Example Output:**
    ```json
    [
      {
        "Account1": 1,
        "Account2": 2,
        "Content": "Hello! How are you?",
        "TimeSent": "2024-12-01T15:30:00Z"
      },
      {
        "Account1": 2,
        "Account2": 1,
        "Content": "I’m doing well, thanks!",
        "TimeSent": "2024-12-01T15:31:00Z"
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
| Location       | point        |                           | Location of the account.                 |
| Password       | varchar(255) | NOT NULL                  | Encrypted or hashed password for the account.|

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
