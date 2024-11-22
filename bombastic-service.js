
/* eslint-disable no-template-curly-in-string */
/* eslint-disable no-console */
/* eslint-disable no-use-before-define */
/**
 * This module implements a REST-inspired webservice for the Bombastic database and is run on an Azure App Service instance.
 *
 * Based on the cs262 monopoly service found at https://github.com/calvin-cs262-organization/ monopoly-service
 * 
 * @date: Fall, 2024
 * 
 */
// For local testing
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
app.post('/login', authenticateLogin); // Changed to POST
app.get('/market/:id', readMarket);
app.get('/items/:id', readAccountItems);

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




