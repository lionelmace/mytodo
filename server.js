
const express = require('express');
const cfenv = require('cfenv');
const favicon = require('serve-favicon');
const fs = require('fs')
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
  console.log('ERR Cannot find module ./vcap-local.json');
}

const appEnvOpts = vcapLocal ? {
  vcap: vcapLocal
} : {}
const appEnv = cfenv.getAppEnv(appEnvOpts);

// Retrieve Kubernetes secrets
console.log('K8S - Parsing secrets from volume...');
var secretCredentials;
var runningInKube = false;
try {
  var bindingEncoded = fs.readFileSync('/opt/service-bind/binding', 'utf8');
  //var bindingDecoded = new Buffer(bindingEncoded, 'base64');
  //var binding = JSON.parse(bindingDecoded);
  var binding = JSON.parse(bindingEncoded);
  secretCredentials = {
    'username': binding.username,
    'password': binding.password,
    'host': binding.host,
    'port': binding.port,
    'url': binding.url
  }
  runningInKube = true;
} catch (err) {
  console.log('K8S - No such file or directory /opt/service-bind/binding');
}

let db;
if (appEnv.services['cloudantNoSQLDB']) {
  db = require('./lib/cloudant-db')(appEnv.services['cloudantNoSQLDB'][0].credentials);
} else if (appEnv.services['compose-for-mongodb']) {
  db = require('./lib/compose-db')(appEnv.services['compose-for-mongodb'][0].credentials);
} else if (runningInKube) {
  db = require('./lib/cloudant-db')(secretCredentials);
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
