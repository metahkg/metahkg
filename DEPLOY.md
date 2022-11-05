# Deploying Metahkg

## Docker

It is recommended to use docker for deployment (also supports hot reload).

[Docs](https://docs.metahkg.org/docs/category/deploy-metahkg)

## Manually

**_WARNING:_** This is NOT RECOMMENDED and might be OUTDATED!

### Prerequisites

- amd64 linux (only tested on ubuntu & arch)
- mongodb (either locally or remotely)
- some third-party services (see .env files in metahkg-web and metahkg-server)

### Set up

#### Mongodb

To use authentication:

```bash
$ mongosh
test> use admin
admin> db.createUser({ user: "<username>", pwd: "<password>", roles: [ "root", "userAdminAnyDatabase" ])
admin> use metahkg
metahkg> db.createUser({ user: "<username>", pwd: "<password>", roles: [ { role: "readWrite", db: "metahkg" } ] })
metahkg> exit
```

#### Environmental variables

```bash
cd metahkg-server
cp temp.env .env
```

Then edit values in the .env files.

### Deploy the React app

```bash
cd metahkg-web
```

Then edit variables in .env.

```bash
yarn install
yarn deploy
```

### Deploying backend

```bash
# run at the repository (metahkg-server) root
cd metahkg-server
yarn install
yarn deploy
```

You must need a domain. If you don't have one and deploys it locally only,
use `metahkg.test.wcyat.me` which points to localhost. Config nginx to do this
(proxy_pass <http://localhost:$port>).

## Nginx

Copy nginx.conf to /etc/nginx/sites-available, edit the domain, port, and certificate, then enable.

Please use https as some features are not supported in http.
