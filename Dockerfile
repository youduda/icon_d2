FROM python:3.9-slim

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

RUN set -ex \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        cdo \
        wget \
        bzip2 \
        parallel \
        ncftp \
    && apt-get remove -y $buildDeps \
    && apt-get autoremove -y

COPY ./requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt

# Purge /tmp directory.
RUN rm -r /tmp/requirements.txt
