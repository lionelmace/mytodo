var express = require('express');
var cfenv   = require('cfenv');
var favicon = require('serve-favicon');
var app     = express();
var bodyParser = require('body-parser')

// load local VCAP configuration
var vcapLocal = null
try {
  vcapLocal = require("./vcap-local.json");
  console.log("APP - Loaded local VCAP", vcapLocal);
} catch (e) {
  console.error(e);
}

// This option property is ignored if not running locally.
var options = vcapLocal ? { vcap: vcapLocal } : {}
var appEnv = cfenv.getAppEnv(options);

console.log('APP - Running Local: ' + appEnv.isLocal);
console.log('APP - App Name: ' + appEnv.name);

// load the services bound to this application
var services = appEnv.getServices();
var dbServiceName;
//console.log(services);
var count = 0;
for (var serviceName in services) {
  if (services.hasOwnProperty(serviceName)) {
    count++;
    var service = services[serviceName];
    console.log('APP - Svc Name=' + service.name + ', Label=' + service.label);
    if (service.label == "cloudantNoSQLDB") {
      dbServiceName =  service.name;
    }
  }
}
if (!count) {
  console.log('APP - No services are bound to this app.\n');
}

// expect a service whose name matches the regular expression
//console.log('toto ' + appEnv.getServiceCreds(/cloudant/i));

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json()); // parse application/json

require("./app/database.js")(appEnv, dbServiceName, "todos", 
  function (err, database) {
    if (err) {
      console.log(err);
    } else {
      // database is initialized, install our CRUD route for Todo objects
      require('./app/todos.js')(app, database);
    }
});

// set the static files location /public/img will be /img for users
app.use(express.static(__dirname + '/public'));
app.use(favicon(__dirname + '/public/icons/favicon.ico'));

// start server on the specified port and binding host
app.listen(appEnv.port, "0.0.0.0", function () {
  console.log("APP - Server starting on " + appEnv.url);
});
