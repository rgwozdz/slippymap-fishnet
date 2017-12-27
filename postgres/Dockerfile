FROM mdillon/postgis:latest
WORKDIR /usr/src
ENV PLV8_VERSION=v2.0.0 \
    PLV8_SHASUM="a3a630149342c8dd00ed890ca92f5ed0326eb781cc32d740e34ea58453b041f6  v2.0.0.tar.gz"

RUN buildDependencies="build-essential \
    ca-certificates \
    curl \
    git-core \
    postgresql-server-dev-$PG_MAJOR" \
  && apt-get update \
  && apt-get install -y --no-install-recommends ${buildDependencies} \
  && mkdir -p /tmp/build \
  && curl -o /tmp/build/${PLV8_VERSION}.tar.gz -SL "https://github.com/plv8/plv8/archive/$PLV8_VERSION.tar.gz" \
  && cd /tmp/build \
  && echo ${PLV8_SHASUM} | sha256sum -c \
  && tar -xzf /tmp/build/${PLV8_VERSION}.tar.gz -C /tmp/build/ \
  && cd /tmp/build/plv8-${PLV8_VERSION#?} \
  && make static \
  && make install \
  && strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8.so \
  && cd / \
  && apt-get clean \
  && apt-get remove -y  ${buildDependencies} \
  && apt-get autoremove -y \
  && rm -rf /tmp/build /var/lib/apt/lists/*


ENV DEBIAN_FRONTEND=noninteractive
RUN sed -e s%http://archive.ubuntu.com/ubuntu/%mirror://mirrors.ubuntu.com/mirrors.txt% -i /etc/apt/sources.list

ENV OSM2PGSQL_VERSION=0.94.0 \
    OSMCTOOLS_VERSION=0.6-1

RUN buildDependencies="build-essential \
    ca-certificates \
    curl \
    make \
    cmake \
    g++ \
    git \
    git-core \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libexpat1-dev \
    zlib1g-dev \
    libbz2-dev \
    libpq-dev \
    libgeos-dev \
    libgeos++-dev \
    libproj-dev \
    lua5.2 \
    liblua5.2-dev" \
  && apt-get update \
  && apt-get install -y --no-install-recommends ${buildDependencies} \
  && cd /tmp \
  && git clone --depth 1 --branch $OSM2PGSQL_VERSION https://github.com/openstreetmap/osm2pgsql.git \
  && mkdir -p osm2pgsql/build \
  && cd osm2pgsql/build  \
  && cmake .. \
  && make install

RUN mkdir /home/postgres
RUN mkdir /home/postgres/osm-pbfs
RUN mkdir /home/postgres/shapefiles
RUN mkdir /home/postgres/src
RUN chown postgres:postgres -R /home/postgres
ADD src/ /home/postgres/src
RUN mkdir /usr/osm-cache

RUN buildDependencies="build-essential \
    ca-certificates \
    curl \
    wget \
    unzip" \
  && apt-get update \
  && apt-get install -y --no-install-recommends ${buildDependencies} \
  && cd /home/postgres/osm-pbfs \
  && wget http://download.geofabrik.de/north-america/us/washington-latest.osm.pbf \
#  && wget http://ftp.osuosl.org/pub/openstreetmap/pbf/planet-latest.osm.pbf \
  && cd /home/postgres/shapefiles
  && wget http://data.openstreetmapdata.com/land-polygons-complete-3857.zip
  && unzip land-polygons-complete-3857.zip

EXPOSE 8080
EXPOSE 5432
LABEL maintainer="rgwozdz@spatialdev.com"