require("dotenv").config();
const { MongoClient } = require("mongodb");
const { exit } = require("process");
const fs = require("fs");
const mongouri = process.env.DB_URI || "mongodb://username:password@localhost:30000"; //mongo connection string
async function setup() {
    const client = new MongoClient(mongouri);
    await client.connect();
    const db = client.db("metahkg");
    const categoryCl = db.collection("category");
    const viralCl = db.collection("viral");
    const summaryCl = db.collection("summary");
    const limitCl = db.collection("limit");
    const verificationCl = db.collection("verification");
    if ((await categoryCl.find().toArray()).length) {
        console.log("documents found. not setting up again");
    } else {
        await categoryCl.insertMany(
            JSON.parse(fs.readFileSync("mongodb/category.json", "utf-8"))
        );
        await viralCl.createIndex({ createdAt: 1 }, { expireAfterSeconds: 172800 });
        await summaryCl.createIndex({ op: "text", title: "text" }); //text search
        await limitCl.createIndex({ createdAt: 1 }, { expireAfterSeconds: 86400 });
        await verificationCl.createIndex({ createdAt: 1 }, { expireAfterSeconds: 300 });
    }
    exit(0);
}
setup();
