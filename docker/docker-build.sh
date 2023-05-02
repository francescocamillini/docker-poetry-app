#!/bin/bash

 docker build \
   --build-arg PYTHON_VERSION_ARG=3.9.1 \
   --build-arg POETRY_VERSION_ARG=1.4 \
   -f docker/Dockerfile \
   -t poetry-docker \
   .