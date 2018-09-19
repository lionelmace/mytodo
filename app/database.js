var async = require("async");

function Database(appEnv, cloudantCreds, dbName, waterfallCallback) {
  var self = this;

  console.log('DB - Initializing database', dbName);

  var cloudant = require('nano')(cloudantCreds.url).db;
  // TODO: Update app to support Cloudant library. See code sample
  // https://github.com/IBM-Cloud/secure-file-storage/blob/master/app.js#L5
  var todoDb;
  var prepareDbTasks = [];

  // create the db
  prepareDbTasks.push(
    function (callback) {
      console.log('DB - Creating database', dbName);
      cloudant.create(dbName, function (err, body) {
        if (err && err.statusCode == 412) {
          console.log('DB - Database already exists', dbName);
          callback(null);
        } else if (err) {
          callback(err);
        } else {
          callback(null);
        }
      });
    });

  // use it
  prepareDbTasks.push(
    function (callback) {
      console.log('DB - Setting current database to', dbName);
      todoDb = cloudant.use(dbName);
      callback(null);
    });

  async.waterfall(prepareDbTasks, function (err, result) {
    if (err) {
      console.log('DB - Error in database preparation', err);
    }

    waterfallCallback(err, todoDb);
  });

}

// callback(err, database)
module.exports = function (appEnv, serviceName, dbName, callback) {
  return new Database(appEnv, serviceName, dbName, callback);
}
