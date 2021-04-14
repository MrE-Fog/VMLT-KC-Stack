#!/usr/bin/env bash

docker build -t thecb4/vapor-blog:latest -t thecb4/vapor-blog:1.0 .
docker push thecb4/vapor-blog:1.0