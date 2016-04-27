# docker-mongo-rocks

## Example usage with compose (warning: mongo not using auth)

```
version: '2'
services:
  web:
    container_name: 'server'
    build: .
    ports:
      - "80:80"
    volumes:
      - .:/usr/src/app
    links:
      - mongo
  mongo:
    container_name: 'tmake_db'
    image: chromapdx/mongo-rocks
    volumes:
      - ./:/data
    ports:
      - "27017:27017"
```

to build a docker image based on chromapdx/mongo-rocks-dist

## Dockerfile
```
FROM chromapdx/mongo-rocks-dist

VOLUME /data/db

ENV STORAGE_ENGINE rocksdb

# don't forget these for production ;)
#ENV AUTH yes
#COPY set_mongodb_password.sh
#ENV JOURNALING yes

EXPOSE 27017

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
```
## docker-entrypoint.sh
```
#!/bin/bash
set -m

mongodb_cmd="mongod --storageEngine $STORAGE_ENGINE"
cmd="$mongodb_cmd --httpinterface --rest --master"
if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth"
fi

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

$cmd &

if [ ! -f /data/db/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

fg

```
## set_mongodb_password.sh
```
#!/bin/bash

PASS=${MONGODB_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MONGODB_PASS} ] && echo "preset" || echo "random" )

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup"
    sleep 5
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
done

echo "=> Creating an admin user with a ${_word} password in MongoDB"
mongo admin --eval "db.createUser({user: 'admin', pwd: '$PASS', roles:[{role:'root',db:'admin'}]});"

echo "=> Done!"
touch /data/db/.mongodb_password_set

echo "========================================================================"
echo "You can now connect to this MongoDB server using:"
echo ""
echo "    mongo admin -u admin -p $PASS --host <host> --port <port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"
```
