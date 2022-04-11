require("dotenv").config();
const { MongoClient } = require('mongodb');
const { exit } = require("process");
const system = require("system-commands");
const mongouri = process.env.DB_URI || "mongodb://localhost"; //mongo connection string
async function setup() {
    const client = new MongoClient(mongouri);
    await client.connect();
    const metahkgthreads = client.db("metahkg-threads");
    const metahkgusers = client.db("metahkg-users");
    if ((await metahkgthreads.collection("category").find().toArray()).length) {
        console.log("documents found. not inserting categories.");
    } else {
        await system(`mongoimport -d=metahkg-threads --uri=${mongouri} templates/server/category.json`);
    }
    await metahkgthreads.collection("hottest").createIndex({ "createdAt": 1 }, { expireAfterSeconds: 172800 });
    await metahkgthreads.collection("summary").createIndex({ "op": "text", "title": "text" }); //text search
    await metahkgusers.collection("limit").createIndex({ "createdAt": 1 }, { expireAfterSeconds: 86400 });
    await metahkgusers.collection("verification").createIndex({ "createdAt": 1 }, { expireAfterSeconds: 300 });
    exit(0);
}
setup();