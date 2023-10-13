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
const mongodb = require('mongodb');
const fs = require('fs');
const MongoClient = mongodb.MongoClient;

function log(...optionalParams) {
  console.log('[mongodb]', ...optionalParams);
}

function DB(credentials) {
  const DB_NAME = 'todos';
  const COLLECTION_NAME = 'todos';
  const self = this;
  let db;

  self.type = function() {
    return 'Databases for MongoDB';
  };

  self.init = () => {
    return new Promise(async (resolve, reject) => {
      try {
        let connectionString;
        if (credentials.connectionUrl) {
          connectionString = credentials.connectionUrl;
        } else {
          // Extract the database username and password
          let username = credentials.MONGO_USERNAME;
          let password = credentials.MONGO_PASSWORD;
          // Extract the MongoDB URIs
          let connectionPath = credentials.MONGO_HOSTS;
          connectionString = `mongodb://${username}:${password}@${connectionPath}/?replicaSet=replset`;
        }

        // write down the certificate so that it can be used by MongoDB client
        fs.writeFileSync('mongo.crt', Buffer.from(credentials.MONGO_CERTIFICATE_BASE64, 'base64'));

        var options = {
          tlsCAFile: 'mongo.crt',
          maxPoolSize: 1,
        };
        const client = new MongoClient(connectionString, options);
        log("Connecting...");
        await client.connect();
        log("Connected");
        db = client.db(DB_NAME).collection(COLLECTION_NAME);
        log("Got database!");
        resolve();
      } catch (err) {
        reject(err);
      }
    });
  };

  self.count = () => {
    log('count');
    return new Promise(async (resolve, reject) => {
      try {
        const count = db.count();
        log('counted', count);
        resolve(count);
      } catch (err) {
        reject(err);
      }
    });
  };

  self.search = () => {
    log('search');
    return new Promise(async (resolve, reject) => {
      try {
        const cursor = await db.find();
        const result = await cursor.toArray();
        resolve(result.map(todo => {
          todo.id = todo._id;
          delete todo._id;
          return todo;
        }));
      } catch (err) {
        reject(err);
      }
    });
  };

  self.create = (item) => {
    log('create', item);
    return new Promise(async (resolve, reject) => {
      try {
        const result = await db.insertOne(item);
        const newItem = {
          id: result.insertedId,
          title: item.title,
          completed: item.completed,
          order: item.order
        };
        log('created', newItem);
        resolve(newItem);
      } catch (err) {
        reject(err);
      }
    });
  };

  self.read = (id) => {
    log('read', id);
    return new Promise(async (resolve, reject) => {
      try {
        const item = await db.findOne({ _id: new mongodb.ObjectID(id) });
        item.id = item._id;
        delete item._id;
        log('read', item);
        resolve(item);
      } catch (err) {
        reject(err);
      }
    });
  };

  self.update = (id, newValue) => {
    log('update', id, newValue);
    return new Promise(async (resolve, reject) => {
      try {
        delete newValue.id;
        await db.findAndModify({ _id: new mongodb.ObjectId(id) }, [], newValue, { upsert: true });
        newValue.id = id;
        delete newValue._id;
        log('updated', newValue);
        resolve(newValue);
      } catch (err) {
        reject(err);
      }
    });
  };

  self.delete = (id) => {
    log('delete', id);
    return new Promise(async (resolve, reject) => {
      try {
        await db.deleteOne({ _id: new mongodb.ObjectId(id) });
        log('deleted', id);
        resolve({ id: id });
      } catch (err) {
        reject(err);
      }
    });
  };
}

module.exports = function(credentials) {
  return new DB(credentials);
}
