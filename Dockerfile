FROM ubuntu:22.04

ARG SUPERSET_ADMIN
ARG SUPERSET_PASSWORD
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
SHELL ["/bin/bash", "-c"]
USER root
RUN ls -lh /etc/apt/sources.list.d && rm -f /etc/apt/sources.list && groupadd -g 1000 superset && useradd -u 1000 -g 1000 -s /bin/bash -G sudo -d /home/superset -m superset
COPY ./sources.list /etc/apt/sources.list
COPY ./duckdb /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh
COPY assets/dashboard_export.zip /home/superset/
RUN apt-get update -o Acquire::https::mirrors.tuna.tsinghua.edu.cn::Verify-Peer=false -o Acquire::https::security.ubuntu.com::Verify-Host=false -o Acquire::https::archive.ubuntu.com::Verify-Host=false && \
    apt-get install -o Acquire::https::mirrors.tuna.tsinghua.edu.cn::Verify-Peer=false -o Acquire::https::security.ubuntu.com::Verify-Host=false -o Acquire::https::archive.ubuntu.com::Verify-Host=false -y ca-certificates
RUN apt-get install -y build-essential pkgconf libssh-dev libz-dev unzip uuid-dev liblzma-dev libreadline-dev libffi-dev libbz2-dev git g++ cmake ninja-build libssl-dev python3-full python3-pip

RUN chmod +x /usr/local/bin/duckdb && \
      python3 -m venv /home/superset && source /home/superset/bin/activate && \
      python3 -m ensurepip --upgrade && python3 -m pip install --upgrade setuptools && \
      pip install apache-superset==4.0.2 \
                psycopg2-binary \
                duckdb-engine \
                duckdb==1.0.0

RUN duckdb install -c '\
      INSTALL arrow; \
      INSTALL aws; \
      INSTALL autocomplete; \
      INSTALL delta; \
      INSTALL excel; \
      INSTALL fts; \
      INSTALL httpfs; \
      INSTALL icu; \
      INSTALL inet; \
      INSTALL json; \
      INSTALL motherduck; \
      INSTALL mysql_scanner; \
      INSTALL parquet; \
      INSTALL postgres_scanner; \
      INSTALL spatial; \
      INSTALL sqlite_scanner; \
      INSTALL substrait; \
      INSTALL tpcds; \
      INSTALL tpch; \
      INSTALL vss;'

USER superset

ENTRYPOINT ["/entrypoint.sh"]
