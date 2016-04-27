# MongoRocks
# Version 3.2

FROM debian:jessie
MAINTAINER chroma <leif@chroma.io>

# Upgrade your gcc to version at least 4.7 to get C++11 support.
RUN apt-get update \
&&  apt-get install -y build-essential git

# rocksDb
RUN apt-get update \
&&  apt-get install -y libbz2-dev libsnappy-dev zlib1g-dev libzlcore-dev

RUN git clone https://github.com/facebook/rocksdb.git \
&&  cd rocksdb \
&&  git checkout 4.1.fb  \
&&  CXXFLAGS="-flto -Os -s" make -j$(nproc) shared_lib \
&&  make install \
&&  rm -R /rocksdb

VOLUME /out
CMD cp /usr/local/lib/* /out/lib

# mongo
RUN apt-get update \
&&  apt-get install -y scons

RUN git clone https://github.com/mongodb-partners/mongo-rocks.git /mongo-rocks \
&&  cd /mongo-rocks \
&&  git checkout v3.2 \
&&  git clone https://github.com/mongodb/mongo.git /mongo \
&&  cd /mongo \
&&  git checkout tags/r3.2.0 \
&&  mkdir -p src/mongo/db/modules/ \
&&  ln -sf /mongo-rocks src/mongo/db/modules/rocks \
&&  CXXFLAGS="-flto -Os -s" scons \
    CPPPATH=/usr/local/include \
    LIBPATH=/usr/local/lib \
    -j$(nproc) \
    --release \
    --prefix=/usr \
    --opt \
    mongod \
    install \
&&  rm -R /mongo \
&&  rm -R /mongo-rocks

VOLUME /out

CMD cp -av usr/local/lib/*.so /out/lib/ \
&&  cp -av usr/local/lib/*.so.* /out/lib/ \
&&  cp usr/bin/mongod /out/bin/mongod
