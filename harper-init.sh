#!/bin/bash

## Quick shell script that initializes our HarperDB schema, table and dummy data
## Replace the base64 encoded user:pass token with your own!

Create golftv_dev schema
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic SERCX0FETUlOOnBvbnRpMTAx' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "create_schema",
        "schema": "golftv_dev"
    }'

## Create videos table, using golftv_dev schema
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic SERCX0FETUlOOnBvbnRpMTAx' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "create_table",
        "schema": "golftv_dev",
        "table": "videos",
        "hash_attribute": "id"
    }'

## Create banners table, using golftv_dev schema
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic SERCX0FETUlOOnBvbnRpMTAx' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "create_table",
        "schema": "golftv_dev",
        "table": "banners",
        "hash_attribute": "id"
    }'    

## Import demo_video_data.csv to populate data
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic SERCX0FETUlOOnBvbnRpMTAx' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "csv_file_load",
        "schema": "golftv_dev",
        "table": "videos",
        "file_path": "demo_video_data.csv"
    }'

## Import demo_banners_data.csv to populate data
curl -v --url http://localhost:9925 \
    --header 'Authorization: Basic SERCX0FETUlOOnBvbnRpMTAx' \
    --header 'Content-Type: application/json' \
    --data '{
        "operation": "csv_file_load",
        "schema": "golftv_dev",
        "table": "banners",
        "file_path": "demo_banner_data.csv"
    }'    