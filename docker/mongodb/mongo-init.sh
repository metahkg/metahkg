set -e

mongosh <<EOF
db = db.getSiblingDB('metahkg')

db.createUser({
  user: '$MONGO_INITDB_ROOT_USERNAME',
  pwd: '$MONGO_INITDB_ROOT_PASSWORD',
  roles: [{ role: 'readWrite', db: 'metahkg' }],
});

db = db.getSiblingDB('agenda')

db.createUser({
  user: '$MONGO_INITDB_ROOT_USER',
  pwd: '$MONGO_INITDB_ROOT_PASSWORD',
  roles: [{ role: 'readWrite', db: 'agenda' }],
});

db = db.getSiblingDB('rlp')

db.createUser({
  user: '$MONGO_INITDB_ROOT_USER',
  pwd: '$MONGO_INITDB_ROOT_PASSWORD',
  roles: [{ role: 'readWrite', db: 'rlp' }],
});
EOF
