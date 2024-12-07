
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
app.post('/items', createItem);
app.get('/market/:id', readMarket); //Fetches all of the items not owned by a user
app.get('/items/:id', readAccountItems); //Fetches all of the items owned by a user
app.get('/trades/:id', readTrades); //Fetches all of the trades involving a user
app.get('/updateTrades/:id1/:id2', createOrUpdateTrade) //creates a new trade involving both users or updates the accepted field to true

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

async function createItem(req, res, next) {
  const { ownerAccount, name, description, location, datePosted, tags, lookingForTags } = req.body;

  // Validate required fields
  if (!ownerAccount || !name || !description || !location || !datePosted) {
    return res.status(400).send({ message: 'Missing required fields' });
  }

  try {
    // Insert the new item
    const newItem = await db.one(
      `INSERT INTO Item (OwnerAccount, Name, Description, Location, DatePosted)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *;`,
      [ownerAccount, name, description, location, datePosted]
    );

    // Insert associated tags (if provided)
    if (tags && tags.length > 0) {
      await Promise.all(
        tags.map(tag =>
          db.none(
            `INSERT INTO ItemTag (ItemID, TagID)
             VALUES ($1, (SELECT ID FROM Tag WHERE Name = $2));`,
            [newItem.id, tag]
          )
        )
      );
    }

    // Insert associated "looking for" tags (if provided)
    if (lookingForTags && lookingForTags.length > 0) {
      await Promise.all(
        lookingForTags.map(tag =>
          db.none(
            `INSERT INTO ItemLookingFor (ItemID, LookingForID)
             VALUES ($1, (SELECT ID FROM Tag WHERE Name = $2));`,
            [newItem.id, tag]
          )
        )
      );
    }

    res.status(201).send({ message: 'Item created successfully', item: newItem });
  } catch (err) {
    next(err);
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
            i.OwnerAccount as ItemOwnerID,
            i.Name AS ItemName,
            i.Description AS ItemDescription,
            i.Location AS ItemLocation,
            i.DatePosted AS DatePosted,
            JSON_AGG(DISTINCT jt.Name) AS ItemTags,
            JSON_AGG(DISTINCT lt.Name) AS LookingForTags
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
        WHERE
            i.OwnerAccount != $1
        GROUP BY 
            i.ID;`, [ id ])
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
    i.OwnerAccount as ItemOwnerID,
    i.Name AS ItemName,
    i.Description AS ItemDescription,
    i.Location AS ItemLocation,
    i.DatePosted AS DatePosted,
    JSON_AGG(DISTINCT jt.Name) AS ItemTags,
    JSON_AGG(DISTINCT lt.Name) AS LookingForTags
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
WHERE
    i.OwnerAccount = $1
GROUP BY 
    i.ID;`, [ id ])
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
