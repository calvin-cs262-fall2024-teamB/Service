
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
const bcrypt = require('bcrypt'); // Add bcrypt for password hashing

// Gets the necessary info to access the database from the Azure app service
// Prevents sensitive data from being put on Github
const db = pgp({
  host: process.env.DB_SERVER,
  port: process.env.DB_PORT,
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: {rejectUnauthorized: false,},
});

// Configure the server and its routes.

const express = require('express');

const app = express();
const port = process.env.PORT || 3000;
const router = express.Router();
router.use(express.json());

// Specifies the routes available
router.get('/', readHelloMessage);
router.get('/login', authenticateLogin);
router.get('/market/:id', readMarket); //id of account
router.put('/items/:id', readAccountItems); //id of account


app.use(router);
app.listen(port, () => console.log(`Listening on port ${port}`));

// Implement the CRUD operations.

function returnDataOr404(res, data) {
  if (data == null) {
    res.sendStatus(404);
  } else {
    res.send(data);
  }
}

// Checks if the given email and password are valid for login
// Checks if the given email and password are valid for login
async function authenticateLogin(req, res, next) {
  const { email, password } = req.body;  
  try {
    // Finds the user in the database by email
    const user = await db.oneOrNone('SELECT * FROM Account WHERE emailAddress = $1', [email]);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Compare the provided password with the hashed password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    res.status(200).json({ message: 'Login successful' });
  } catch (err) {
    console.error('Error in authenticateLogin:', err);
    next(err);
  }
}
  
// reads the open market from the perspective of a user (all items that aren't theirs)
function readMarket(req, res, next) {
    db.many('SELECT * FROM Items WHERE OwnerAccount!=${id}', req.params)
      .then((data) => {
        returnDataOr404(res, data);
      })
      .catch((err) => {
        next(err);
      });
  }

// reads the items of a particular user
function readAccountItems(req, res, next) {
    db.many('SELECT * FROM Items WHERE OwnerAccount=${id}', req.params)
      .then((data) => {
        returnDataOr404(res, data);
      })
      .catch((err) => {
        next(err);
      });
  }


function readHelloMessage(res) {
  res.send('MWAHAHAHAHA THE APP SERVICE WORKS!!!');
}
