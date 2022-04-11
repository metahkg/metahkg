require("dotenv").config();
const { MongoClient } = require('mongodb');
const { exit } = require("process");
const system = require("system-commands");
const mongouri = process.env.DB_URI || "mongodb://localhost"; //mongo connection string
async function setup() {
    const client = new MongoClient(mongouri);
    await client.connect();
    const db = client.db("metahkg");
    if ((await db.collection("category").find().toArray()).length) {
        console.log("documents found. not inserting categories.");
    } else {
        await system(`mongoimport -d=metahkg --uri=${mongouri} metahkg-server/templates/server/category.json`);
    }
    await db.collection("viral").createIndex({ "createdAt": 1 }, { expireAfterSeconds: 172800 });
    await db.collection("summary").createIndex({ "op": "text", "title": "text" }); //text search
    await db.collection("limit").createIndex({ "createdAt": 1 }, { expireAfterSeconds: 86400 });
    await db.collection("verification").createIndex({ "createdAt": 1 }, { expireAfterSeconds: 300 });
    exit(0);
}
setup();