
const express = require('express');
const favicon = require('serve-favicon');
const app = express();
const bodyParser = require('body-parser');
const os = require('os');

// Set up Port variable (required for Kubernetes)
const PORT = process.env.PORT || 8080;

// Run locally - Load env variables from .env file
const result = require('dotenv').config({
  path: __dirname + '/credentials.env'
}); 
if (result.error) {
  //console.log('Cannot find credentials.env');
} else {
  console.log('credentials.env =', result.parsed)
}

// Database ----------------------------------------------------------------
let db;
if (process.env.CLOUDANT_URL !== undefined)  {
  db = require('./lib/db-cloudant')(process.env);
} else if (process.env.MONGO_USERNAME !== undefined) {
  db = require('./lib/db-mongo')(process.env);
} else {
  db = require('./lib/in-memory')();
}
console.log('Using', db.type());

app.use(bodyParser.urlencoded({
  extended: false
}))
app.use(bodyParser.json()); // parse application/json

// Force HTTPS -------------------------------------------------------------
/*
// Enable reverse proxy support in Express. This causes the
// the "X-Forwarded-Proto" header field to be trusted so its
// value can be used to determine the protocol. See 
// http://expressjs.com/api#app-settings for more details.
app.enable('trust proxy');

// Add a handler to inspect the req.secure flag (see 
// http://expressjs.com/api#req.secure). This allows us 
// to know whether the request was via http or https.
app.use (function (req, res, next) {
  if (req.secure) {
          // request was via https, so do no special handling
          next();
  } else {
          // request was via http, so redirect to https
          res.redirect('https://' + req.headers.host + req.url);
  }
});
*/

app.use(express.static(__dirname + '/public'));
app.use(favicon(__dirname + '/public/icons/favicon-check.ico'));

//console.log('Number of cores: ', os.cpus().length);

// Healthcheck use for LivenessProbe ---------------------------------------
app.get('/healthcheck',(req,res)=> {
  res.send ("Health check passed");
 });
 app.get('/badhealth',(req,res)=> {
     res.status(500).send('Health check did not pass');
 });

// Load test - will generate CPU stress for a few seconds. 
app.get('/loadtest', function (req, res) {
    res.send("Load test complete: " + fibo(45));
})

function fibo(n) {
    if (n < 2)
        return 1;
    else return fibo(n - 2) + fibo(n - 1);
}
 
// API ---------------------------------------------------------------------
app.get('/api/todos', (req, res) => {
  db.search().then(todos => {
    res.send(todos);
  }).catch(err => {
    res.status(500).send({ error: err });
  });
});

app.post('/api/todos', (req, res) => {
  db.create({ text: req.body.text, completed: false})
    .then(todo  => db.search())
    .then(todos => res.send(todos))
    .catch(err => { 
      res.status(500).send({ error: err });
  });
});

app.get('/api/todos/:id', (req, res) => {
  db.get(req.params.id).then(todo => {
    res.send(todo);
  }).catch(err => {
    res.status(500).send({ error: err });
  });
});

app.put('/api/todos/:id', (req, res) => {
  db.update(req.params.id, req.body)
    .then(todo => db.search())
    .then(todos => res.send(todos))
    .catch(err => {
      res.status(500).send({ error: err });
  });
});

app.delete('/api/todos/:id', (req, res) => {
  db.delete(req.params.id)
    .then(todo => db.search())
    .then(todos => res.send(todos))
    .catch(err => {
    res.status(500).send({ error: err });
  });
});

// Activate this route to debug
// app.get('*', (req, res) => {
//   console.log(req);
//   res.status(404).send('Not found');
// });

app.listen(PORT, function () {
  console.log("Server starting on http://localhost:" + PORT);
});

// Try to reconnect to the DB after 5sec
function initDb() {
  db.init().catch((err) => {
    console.log('Init failed with error, will retry...', err);
    setTimeout(initDb, 5000);
  })
}

// connect to the database
initDb();

