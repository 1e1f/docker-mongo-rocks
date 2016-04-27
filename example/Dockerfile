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
