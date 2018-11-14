/**
 * Copyright 2016 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the “License”);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an “AS IS” BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require('express');
const cfenv = require('cfenv');
const favicon = require('serve-favicon');
const app = express();
const bodyParser = require('body-parser')

// load local VCAP configuration
let vcapLocal = null
try {
  vcapLocal = require('./vcap-local.json');
  console.log("Loaded local VCAP", vcapLocal);
} catch (e) {
  console.error(e);
}

const appEnvOpts = vcapLocal ? {
  vcap: vcapLocal
} : {}
const appEnv = cfenv.getAppEnv(appEnvOpts);

let db;
if (appEnv.services['cloudantNoSQLDB']) {
  db = require('./lib/cloudant-db')(appEnv.services['cloudantNoSQLDB'][0].credentials);
} else if (appEnv.services['compose-for-mongodb']) {
  db = require('./lib/compose-db')(appEnv.services['compose-for-mongodb'][0].credentials);
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
