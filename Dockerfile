FROM ubuntu:24.04

ARG SUPERSET_ADMIN
ARG SUPERSET_PASSWORD
USER root
RUN ls -lh /etc/apt/sources.list.d && rm -f /etc/apt/sources.list 
COPY ./sources.list /etc/apt/sources.list
COPY ./duckdb /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
RUN apt-get update -o Acquire::https::mirrors.tuna.tsinghua.edu.cn::Verify-Peer=false -o Acquire::https::security.ubuntu.com::Verify-Host=false -o Acquire::https::archive.ubuntu.com::Verify-Host=false && \
    apt-get install -o Acquire::https::mirrors.tuna.tsinghua.edu.cn::Verify-Peer=false -o Acquire::https::security.ubuntu.com::Verify-Host=false -o Acquire::https::archive.ubuntu.com::Verify-Host=false -y ca-certificates
RUN apt-get install -y build-essential pkgconf libssh-dev libz-dev uuid-dev liblzma-dev libreadline-dev libffi-dev libbz2-dev git g++ cmake ninja-build libssl-dev

RUN chmod +x /usr/local/bin/duckdb && pip install apache-superset==4.0.2 \
                psycopg2-binary \
                duckdb-engine==1.0.0 \
                duckdb==1.0.0

RUN duckdb install -c '\
      INSTALL arrow; \
      INSTALL autocomplete; \
      INSTALL delta; \
      INSTALL excel; \
      INSTALL fts; \
      INSTALL httpfs; \
      INSTALL icu; \
      INSTALL inet; \
      INSTALL jemalloc; \
      INSTALL json; \
      INSTALL motherduck; \
      INSTALL mysql_scanner; \
      INSTALL parquet; \
      INSTALL postgres_scanner; \
      INSTALL shell; \
      INSTALL spatial; \
      INSTALL sqlite_scanner; \
      INSTALL substrait; \
      INSTALL tpcds; \
      INSTALL tpch; \
      INSTALL vss;'

USER superset

ENTRYPOINT ["/entrypoint.sh"]
