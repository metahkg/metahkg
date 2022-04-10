# Deploying Metahkg

## Prerequisites

- x86_64 debian linux (only tested on ubuntu)
- mongodb (either locally or remotely)
- mailgun key (for sending emails, obviously)
- recaptcha site key and secret pair (for anti-spamming)
- a publicily accessible s3 bucket

## Set up

Run `./setup.sh` for a fast setup. It will install all the dependencies for you.
However, you will still need to configure the env variables.
Alternatively, use the following step-by-step guide. It assumes that you have installed all the dependencies.

### Mongodb

```bash
$ mongoimport -d=metahkg-threads metahkg-server/templates/server/category.json
$ mongosh
test> use metahkg-threads
metahkg-threads> db.hottest.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 172800 })
metahkg-threads> db.summary.createIndex({ "op": "text", "title": "text" }) //for text search
metahkg-threads> use metahkg-users
metahkg-users> db.limit.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 86400 })
metahkg-users> db.verification.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 300 })
metahkg-users> exit
```

To use authentication:

```bash
$ mongosh
test> use admin
admin> db.createUser({ user: "<username>", pwd: "<password>", roles: [ "root", "userAdminAnyDatabase" ])
admin> use metahkg-threads
metahkg-threads> db.createUser({ user: "<username>", pwd: "<password>", roles: [ { role: "readWrite", db: "metahkg-threads" } ] })
metahkg-threads> use metahkg-users
metahkg-users> db.createUser({ user: "<username>", pwd: "<password>", roles: [ { role: "readWrite", db: "metahkg-users" } ] })
```

### Environmental variables

```bash
cd metahkg-web
cp templates/template.env .env
cd ../metahkg-server
cp templates/template.env .env
```

Then edit values in the .env files.

## Deploy the React app

```bash
cd metahkg-web
yarn install
yarn run deploy
```

## Deploying backend

```bash
# run at the repository (metahkg-server) root
cd metahkg-server
yarn install
yarn run deploy
```

You must need a domain. If you don't have one and deploys it locally only,
use metahkg.test.wcyat.me which points to localhost. Config nginx to do this
(proxy_pass http://localhost:(the port you choose in .env)).

## Nginx

Copy nginx.conf to /etc/nginx/sites-available, edit the domain, port, and certificate, then enable.

Please use https as some features are not supported in http.
