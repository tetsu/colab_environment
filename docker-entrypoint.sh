#!/usr/bin/env bash
# ----------------------------------------------------------
# docker-entrypoint.sh
# ----------------------------------------------------------
# This script ensures that "conda activate myenv" is run for any container shell.

source ~/.bashrc
exec "$@"
