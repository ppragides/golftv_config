#!/bin/bash

## Quick shell script that initializes our HarperDB schema, table and dummy data

## Create schema
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "create_schema",
        "schema": "golftv_dev"
    }'

## Create table
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "create_table",
        "schema": "golftv_dev",
        "table": "golftv_dev",
        "hash_attribute": "id"
    }'

## Import demo_data.csv to populate data
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "csv_file_load",
        "schema": "golftv_dev",
        "table": "golftv_dev",
        "file_path": "demo_data.csv"
    }'