
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

// Set up the database connection.

const pgp = require('pg-promise')();
//const bcrypt = require('bcrypt');
//const express = require('express');

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
const app = express();
const port = process.env.PORT || 3000;
const router = express.Router();
app.use(express.json()); // Apply middleware to parse JSON globally

// Routes
app.get('/', readHelloMessage);
app.post('/login', authenticateLogin); // Changed to POST
app.get('/market/:id', readMarket);
app.put('/items/:id', readAccountItems);

app.use(router);
app.listen(port, () => console.log(`Listening on port ${port}`));

// Fallback route for undefined paths
app.use((req, res) => {
  res.status(404).send({ message: 'Resource Not Found' });
});

// Start the server


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
  db.any('SELECT * FROM Items WHERE OwnerAccount != ${id}', { id })
    .then((data) => returnDataOr404(res, data))
    .catch(next);
}

function readAccountItems(req, res, next) {
  const id = req.params.id;
  if (!id) {
    return res.status(400).send({ message: 'Invalid or missing ID' });
  }
  db.any('SELECT * FROM Items WHERE OwnerAccount = ${id}', { id })
    .then((data) => returnDataOr404(res, data))
    .catch(next);
}

function readHelloMessage(req, res) {
  res.send('MWAHAHAHAHA THE APP SERVICE WORKS!!!');
}




