/* eslint-disable no-template-curly-in-string */
/* eslint-disable no-console */
/* eslint-disable no-use-before-define */
/* eslint-disable no-undef */
/**
 * This module implements a REST-inspired webservice for the Bombastic database 
 * and is run on an Azure App Service instance.
 *
 * Based on the CS262 Monopoly service.
 * 
 * @date: Fall, 2024
 */

require('dotenv').config(); // Enable for local testing

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
  ssl: { rejectUnauthorized: false },
});

// Server setup
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;
const router = express.Router();
app.use(express.json()); // Middleware to parse JSON globally

// Routes
app.get('/', readHelloMessage);
app.post('/login', authenticateLogin);
app.get('/market/:id', readMarket);
app.get('/items/:id', readAccountItems);
app.get('/trades/:id', readTrades);
app.get('/updateTrades/:id1/:id2', createOrUpdateTrade);

app.post('/items', async (req, res) => {
  const { ownerAccount, name, description, location, tags, lookingForTags } = req.body;

  if (!ownerAccount || !name || !description || !location) {
    return res.status(400).send('Missing required fields: ownerAccount, name, description, or location.');
  }

  try {
    const insertItemQuery = `
      INSERT INTO Item (OwnerAccount, Name, Description, Location)
      VALUES ($1, $2, $3, $4) RETURNING ID;
    `;
    const itemResult = await db.one(insertItemQuery, [ownerAccount, name, description, location]);
    const itemId = itemResult.id;

    // Add tags to ItemTag table
    const tagQueries = tags.map(tag =>
      db.none('INSERT INTO ItemTag (ItemID, TagID) VALUES ($1, $2)', [itemId, tag])
    );

    // Add "looking for" tags to ItemLookingFor table
    const lookingForQueries = lookingForTags.map(tag =>
      db.none('INSERT INTO ItemLookingFor (ItemID, TagID) VALUES ($1, $2)', [itemId, tag])
    );

    await Promise.all([...tagQueries, ...lookingForQueries]);

    res.status(201).json({ id: itemId, name, description });
  } catch (error) {
    console.error(error);
    res.status(500).send('Failed to add item to the database.');
  }
});

// Middleware to use router
app.use(router);

// Start server
app.listen(port, () => console.log(`Listening on port ${port}`));

// CRUD Operations
function returnDataOr404(res, data) {
  if (!data || data.length === 0) {
    res.sendStatus(404);
  } else {
    res.send(data);
  }
}

// Authentication
async function authenticateLogin(req, res, next) {
  const { email, password } = req.body;
  try {
    const user = await db.oneOrNone('SELECT * FROM Account WHERE emailAddress = $1', [email]);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }
    res.status(200).json({ message: 'Login successful.' });
  } catch (err) {
    next(err);
  }
}

// Fetch market items
function readMarket(req, res, next) {
  const id = req.params.id;
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing ID.' });
  }
  db.any(`
    SELECT 
      i.ID AS ItemID,
      i.OwnerAccount AS ItemOwnerID,
      i.Name AS ItemName,
      i.Description AS ItemDescription,
      i.Location AS ItemLocation,
      i.DatePosted AS DatePosted,
      JSON_AGG(DISTINCT jt.Name) AS ItemTags,
      JSON_AGG(DISTINCT lt.Name) AS LookingForTags
    FROM Item i
    LEFT JOIN ItemTag it ON i.ID = it.ItemID
    LEFT JOIN Tag jt ON it.TagID = jt.ID
    LEFT JOIN ItemLookingFor ilf ON i.ID = ilf.ItemID
    LEFT JOIN Tag lt ON ilf.TagID = lt.ID
    WHERE i.OwnerAccount != $1
    GROUP BY i.ID;
  `, [id])
    .then(data => returnDataOr404(res, data))
    .catch(next);
}

// Fetch account items
function readAccountItems(req, res, next) {
  const id = req.params.id;
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing ID.' });
  }
  db.any(`
    SELECT 
      i.ID AS ItemID,
      i.OwnerAccount AS ItemOwnerID,
      i.Name AS ItemName,
      i.Description AS ItemDescription,
      i.Location AS ItemLocation,
      i.DatePosted AS DatePosted,
      JSON_AGG(DISTINCT jt.Name) AS ItemTags,
      JSON_AGG(DISTINCT lt.Name) AS LookingForTags
    FROM Item i
    LEFT JOIN ItemTag it ON i.ID = it.ItemID
    LEFT JOIN Tag jt ON it.TagID = jt.ID
    LEFT JOIN ItemLookingFor ilf ON i.ID = ilf.ItemID
    LEFT JOIN Tag lt ON ilf.TagID = lt.ID
    WHERE i.OwnerAccount = $1
    GROUP BY i.ID;
  `, [id])
    .then(data => returnDataOr404(res, data))
    .catch(next);
}

// Read trades
function readTrades(req, res, next) {
  const id = req.params.id;
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing ID.' });
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
    FROM Trade t
    WHERE t.Account1 = $1 OR t.Account2 = $1;
  `, [id])
    .then(data => returnDataOr404(res, data))
    .catch(next);
}

// Create or update trades
async function createOrUpdateTrade(req, res, next) {
  const { id1, id2 } = req.params;
  if (!id1 || !id2) {
    return res.status(400).send({ message: 'Invalid or missing user IDs.' });
  }
  try {
    const existingTrade = await db.oneOrNone(`
      SELECT * FROM Trade 
      WHERE (Account1 = $1 AND Account2 = $2) OR (Account1 = $2 AND Account2 = $1);
    `, [id1, id2]);

    if (existingTrade) {
      const updatedTrade = await db.one(`
        UPDATE Trade 
        SET Accepted = true 
        WHERE (Account1 = $1 AND Account2 = $2) OR (Account1 = $2 AND Account2 = $1)
        RETURNING *;
      `, [id1, id2]);
      res.status(200).send({ message: 'Trade updated successfully.', trade: updatedTrade });
    } else {
      const newTrade = await db.one(`
        INSERT INTO Trade (Account1, Account2, Accepted) 
        VALUES ($1, $2, $3) 
        RETURNING *;
      `, [id1, id2, false]);
      res.status(201).send({ message: 'Trade created successfully.', trade: newTrade });
    }
  } catch (err) {
    next(err);
  }
}

// Hello message
function readHelloMessage(req, res) {
  res.send('MWAHAHAHAHA THE APP SERVICE WORKS!!!');
}
