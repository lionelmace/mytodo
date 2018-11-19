
const express = require('express');
const cfenv = require('cfenv');
const favicon = require('serve-favicon');
const app = express();
const bodyParser = require('body-parser')

// Set up Port variable (required for Kubernetes)
if (!process.env.PORT) process.env.PORT = 8080;

// load local VCAP configuration
let vcapLocal = null
try {
  vcapLocal = require('./vcap-local.json');
  console.log("Loaded local VCAP", vcapLocal);
} catch (e) {
  console.log('Cannot find module ./vcap-local.json');
}

const appEnvOpts = vcapLocal ? { vcap: vcapLocal } : {}
const appEnv = cfenv.getAppEnv(appEnvOpts);

// Run locally - Load env variables from .env file
const result = require('dotenv').config({
  path: __dirname + '/credentials.env'
}); 
if (result.error) {
  console.log('Cannot find credentials.env');
} else {
  console.log('credentials.env =', result.parsed)
}

// Cloud Foundry -----------------------------------------------------------
// Run in Cloud Foundry - Read VCAP variables
if (!appEnv.isLocal) {
  console.log('Run in Cloud Foundry');
  var services = appEnv.getServices();
  for (var svcName in services) {
    if (services.hasOwnProperty(svcName)) {
      var svc = services[svcName];
      console.log('Service name=' + svc.name + ', Label=' + svc.label);
      if (svc.label == "cloudantNoSQLDB") {
        cloudantCreds =  svc.credentials;
        process.env.CLOUDANT_USERNAME=cloudantCreds.username;
        process.env.CLOUDANT_APIKEY=cloudantCreds.apikey;
      }
    }
  }
}

// Database ----------------------------------------------------------------
let db;
if (process.env.CLOUDANT_USERNAME != '')  {
  db = require('./lib/cloudant-db')(process.env);
} else if (process.env.COMPOSE_USERNAME != '') {
  console.log('Using Compose');
  db = require('./lib/compose-db')(process.env);
} else {
  db = require('./lib/in-memory')();
}
console.log('Using', db.type());

app.use(bodyParser.urlencoded({
  extended: false
}))
app.use(bodyParser.json()); // parse application/json

app.use(express.static(__dirname + '/public'));
app.use(favicon(__dirname + '/public/icons/favicon-check.ico'));

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

// connect to the database
db.init().then(() => {
  // start server on the specified port and binding host
  // app.listen(appEnv.port, "0.0.0.0", function () {
  app.listen(appEnv.port, function () {
    console.log("server starting on " + appEnv.url);
  });
});
