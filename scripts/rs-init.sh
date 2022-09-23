#!/bin/bash

MONGODB1=mongo1-local
MONGODB2=mongo2-local
MONGODB3=mongo3-local

echo "**********************************************" ${MONGODB1}
echo "Waiting for MongoDB startup..."
until curl http://${MONGODB1}:27017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 1
done

# check if replica set is already initiated
RS_STATUS=$( mongo --quiet --host ${MONGODB1}:27017 --eval "rs.status().ok" )

if [[ $RS_STATUS != 1 ]]
then
echo SETUP.sh time now: `date +"%T" `
mongo --host ${MONGODB1}:27017 <<EOF
mongo --host ${MONGODB1:27017
var cfg = {
    "_id": "rs0",
    "protocolVersion": 1,
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "${MONGODB1}:27017",
            "priority": 2
        },
        {
            "_id": 1,
            "host": "${MONGODB2}:27017",
            "priority": 0
        },
        {
            "_id": 2,
            "host": "${MONGODB3}:27017",
            "priority": 0,
        }
    ]
};
rs.initiate(cfg, { force: true });
rs.reconfig(cfg, { force: true });
rs.secondaryOk();
db.getMongo().setReadPref('primary');
rs.status();
EOF
else
  echo "[INFO] Replication set already initiated."
fi