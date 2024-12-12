
/* eslint-disable no-template-curly-in-string */
/* eslint-disable no-console */
/* eslint-disable no-use-before-define */
/* eslint-disable no-undef */
/**
 * This module implements a REST-inspired webservice for the Bombastic database and is run on an Azure App Service instance.
 *
 * Based on the cs262 monopoly service found at https://github.com/calvin-cs262-organization/ monopoly-service
 * 
 * @date: Fall, 2024
 * 
 */
// ----------------- For local testing --------------------
require('dotenv').config();

// Set up the database connection.

const pgp = require('pg-promise')();
const bcrypt = require('bcrypt');


// Database connection
const db = pgp({
  host: process.env.DB_SERVER,
  port: process.env.DB_PORT,
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: { rejectUnauthorized: false, }
});

// Server setup
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;
const router = express.Router();
app.use(express.json()); // Apply middleware to parse JSON globally

// Routes
app.get('/', readHelloMessage);
app.post('/login', authenticateLogin);
app.get('/market/:id', readMarket); //Fetches all of the items not owned by a user
app.get('/items/:id', readAccountItems); //Fetches all of the items owned by a user
app.get('/trades/:id', readTrades); //Fetches all of the trades involving a user
app.get('/updateTrades/:id1/:id2', createOrUpdateTrade) //creates a new trade involving both users or updates the accepted field to true
app.post('/items', createItem); //creates a new item
app.put('/items', updateItem); //updates the field of an item

app.use(router);
app.listen(port, () => console.log(`Listening on port ${port}`));

// CRUD Operations
function returnDataOr404(res, data) {
  if (!data || data.length === 0) {
    res.sendStatus(404);
  } else {
    res.send(data);
  }
}

async function authenticateLogin(req, res, next) {
  const { email, password } = req.body;
  try {
    const user = await db.oneOrNone('SELECT * FROM Account WHERE emailAddress = $1', [email]);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }
    res.status(200).json({ message: 'Login successful' });
  } catch (err) {
    next(err);
  }
}

function readMarket(req, res, next) {
  const id = req.params.id;
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing ID' });
  }
  db.any(`SELECT 
    i.ID AS ItemID,
    i.OwnerAccount AS ItemOwnerID,
    i.Name AS ItemName,
    i.Description AS ItemDescription,
    i.Location AS ItemLocation,
    i.DatePosted AS DatePosted,
    JSON_AGG(DISTINCT jt.Name) AS ItemTags,
    JSON_AGG(DISTINCT lt.Name) AS LookingForTags,
    JSON_AGG(
        DISTINCT JSONB_BUILD_OBJECT(
            'ImageData', ii.ImageData,
            'Description', ii.Description
        )
    ) AS ItemImages
    FROM 
        Item i
    LEFT JOIN 
        ItemTag it ON i.ID = it.ItemID
    LEFT JOIN 
        Tag jt ON it.TagID = jt.ID
    LEFT JOIN 
        ItemLookingFor ilf ON i.ID = ilf.ItemID
    LEFT JOIN 
        Tag lt ON ilf.LookingForID = lt.ID
    LEFT JOIN
        ItemImage ii ON i.ID = ii.ItemID
    WHERE
        i.OwnerAccount != $1
    GROUP BY 
        i.ID;
    `, [ id ])
    .then((data) => returnDataOr404(res, data))
    .catch(next);
}

function readAccountItems(req, res, next) {
  const id = req.params.id;
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing ID' });
  }
  db.any(`SELECT 
    i.ID AS ItemID,
    i.OwnerAccount AS ItemOwnerID,
    i.Name AS ItemName,
    i.Description AS ItemDescription,
    i.Location AS ItemLocation,
    i.DatePosted AS DatePosted,
    JSON_AGG(DISTINCT jt.Name) AS ItemTags,
    JSON_AGG(DISTINCT lt.Name) AS LookingForTags,
    JSON_AGG(
        DISTINCT JSONB_BUILD_OBJECT(
            'ImageData', ii.ImageData,
            'Description', ii.Description
        )
    ) AS ItemImages
    FROM 
        Item i
    LEFT JOIN 
        ItemTag it ON i.ID = it.ItemID
    LEFT JOIN 
        Tag jt ON it.TagID = jt.ID
    LEFT JOIN 
        ItemLookingFor ilf ON i.ID = ilf.ItemID
    LEFT JOIN 
        Tag lt ON ilf.LookingForID = lt.ID
    LEFT JOIN
        ItemImage ii ON i.ID = ii.ItemID
    WHERE
        i.OwnerAccount = $1
    GROUP BY 
        i.ID;
    `, [ id ])
    .then((data) => returnDataOr404(res, data))
    .catch(next);
}

function readHelloMessage(req, res) {
  res.send('MWAHAHAHAHA THE APP SERVICE WORKS!!!');
}

function readTrades(req, res, next) {
  const id = req.params.id;
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing ID' });
  }
  db.any(`
    SELECT 
      t.ID AS TradeID,
      t.Account1 AS User1ID,
      t.Account2 AS User2ID,
      CASE 
        WHEN t.Account1 = $1 THEN t.Account2
        WHEN t.Account2 = $1 THEN t.Account1
      END AS OtherUserID,
      t.Accepted AS TradeAccepted
    FROM 
      Trade t
    WHERE 
      t.Account1 = $1 OR t.Account2 = $1;`, [id])
    .then((data) => returnDataOr404(res, data))
    .catch(next);
}

async function createOrUpdateTrade(req, res, next) {
  const { id1, id2 } = req.params; // Extract user IDs from route parameters

  if (!id1 || !id2) {
    return res.status(400).send({ message: 'Invalid or missing user IDs' });
  }

  try {
    //Check if a trade already exists between the two users
    const existingTrade = await db.oneOrNone(
      `SELECT * FROM Trade 
       WHERE (Account1 = $1 AND Account2 = $2) 
          OR (Account1 = $2 AND Account2 = $1);`,
      [id1, id2]
    );

    if (existingTrade) {
      //If a trade exists, update its Accepted field to true
      const updatedTrade = await db.one(
        `UPDATE Trade 
         SET Accepted = true 
         WHERE (Account1 = $1 AND Account2 = $2) 
            OR (Account1 = $2 AND Account2 = $1) 
         RETURNING *;`,
        [id1, id2]
      );

      res.status(200).send({ message: 'Trade updated successfully', trade: updatedTrade });
    } else {
      //If no trade exists, create a new trade with Accepted = false
      const newTrade = await db.one(
        `INSERT INTO Trade (Account1, Account2, Accepted) 
         VALUES ($1, $2, $3) 
         RETURNING *;`,
        [id1, id2, false]
      );  

      res.status(201).send({ message: 'Trade created successfully', trade: newTrade });
    }
  } catch (err) {
    next(err);
  }
}

// Route to create a new item entry
async function createItem(req, res, next) {
  const { ownerAccount, name, description, location, imageData, itemTags, lookingForTags } = req.body;

  // Validate required fields
  if (!ownerAccount || !name || !location) {
    return res.status(400).send({ message: 'Invalid or missing required fields: ownerAccount, name, and location are required.' });
  }

  try {
    // Begin a transaction for consistent inserts
    await db.tx(async (t) => {
      // Insert the item
      const newItem = await t.one(
        `INSERT INTO Item (OwnerAccount, Name, Description, Location, DatePosted) 
         VALUES ($1, $2, $3, $4, NOW()) 
         RETURNING ID;`,
        [ownerAccount, name, description, location]
      );

      const itemId = newItem.id;

      // Insert tags if provided
      if (itemTags && Array.isArray(itemTags)) {
        const itemTagQueries = itemTags.map((tag) =>
          t.none(
            `INSERT INTO ItemTag (ItemID, TagID) 
             VALUES ($1, (SELECT ID FROM Tag WHERE Name = $2));`,
            [itemId, tag]
          )
        );
        await t.batch(itemTagQueries); // Execute all tag inserts
      }

      // Insert "looking for" tags if provided
      if (lookingForTags && Array.isArray(lookingForTags)) {
        const lookingForTagQueries = lookingForTags.map((tag) =>
          t.none(
            `INSERT INTO ItemLookingFor (ItemID, LookingForID) 
             VALUES ($1, (SELECT ID FROM Tag WHERE Name = $2));`,
            [itemId, tag]
          )
        );
        await t.batch(lookingForTagQueries); // Execute all "looking for" tag inserts
      }

      // Insert images if provided
      if (imageData && Array.isArray(imageData)) {
        const imageQueries = imageData.map((image) =>
          t.none(
            `INSERT INTO ItemImage (ItemID, ImageData, Description) 
             VALUES ($1, $2, $3);`,
            [itemId, image.data, image.description || null]
          )
        );
        await t.batch(imageQueries); // Execute all image inserts
      }
    });

    // Return a success response
    res.status(201).send({ message: 'Item created successfully.' });
  } catch (err) {
    next(err); // Pass the error to error-handling middleware
  }
};

async function updateItem(req, res, next) {
  const { id, name, description, location, itemTags, lookingForTags, imageData } = req.body;

  // Validate the item ID
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing item ID.' });
  }

  try {
    // Ensure the ID cannot be modified and is only used for identifying the item
    const itemExists = await db.oneOrNone('SELECT 1 FROM Item WHERE ID = $1', [id]);
    if (!itemExists) {
      return res.status(404).send({ message: 'Item not found.' });
    }

    // Begin a transaction for consistent updates
    await db.tx(async (t) => {
      // Update basic fields of the item
      await t.none(
        `UPDATE Item 
         SET Name = COALESCE($2, Name), 
             Description = COALESCE($3, Description), 
             Location = COALESCE($4, Location) 
         WHERE ID = $1;`,
        [id, name, description, location]
      );

      // Update item tags if provided
      if (itemTags && Array.isArray(itemTags)) {
        // Delete existing tags for the item
        await t.none(`DELETE FROM ItemTag WHERE ItemID = $1;`, [id]);

        // Insert new tags
        const itemTagQueries = itemTags.map((tag) =>
          t.none(
            `INSERT INTO ItemTag (ItemID, TagID) 
             VALUES ($1, (SELECT ID FROM Tag WHERE Name = $2));`,
            [id, tag]
          )
        );
        await t.batch(itemTagQueries); // Execute all tag inserts
      }

      // Update "looking for" tags if provided
      if (lookingForTags && Array.isArray(lookingForTags)) {
        // Delete existing "looking for" tags for the item
        await t.none(`DELETE FROM ItemLookingFor WHERE ItemID = $1;`, [id]);

        // Insert new "looking for" tags
        const lookingForTagQueries = lookingForTags.map((tag) =>
          t.none(
            `INSERT INTO ItemLookingFor (ItemID, LookingForID) 
             VALUES ($1, (SELECT ID FROM Tag WHERE Name = $2));`,
            [id, tag]
          )
        );
        await t.batch(lookingForTagQueries); // Execute all "looking for" tag inserts
      }

      // Update item images if provided
      if (imageData && Array.isArray(imageData)) {
        // Delete existing images for the item
        await t.none(`DELETE FROM ItemImage WHERE ItemID = $1;`, [id]);

        // Insert new images
        const imageQueries = imageData.map((image) =>
          t.none(
            `INSERT INTO ItemImage (ItemID, ImageData, Description) 
             VALUES ($1, $2, $3);`,
            [id, image.data, image.description || null]
          )
        );
        await t.batch(imageQueries); // Execute all image inserts
      }
    });

    // Return a success response
    res.status(200).send({ message: 'Item updated successfully.' });
  } catch (err) {
    next(err); // Pass the error to error-handling middleware
  }
}
