# Project scripts backup db to firebase

## Stack

- Node.js
- Firebase
- shell script

## How to install

- Clone this repository
- copy .env.example to .env
- setup .env

## How to run manually

- run $ npm install
- run ./script.sh

## How to run docker

- run $ docker-compose up -d --build

## Config

- cron set on Dockerfile
- firebase config on .env
- dir firebase on key BACKUP_PATH
- max file on firebase on key MAX_FILE
- when NODE=development run on local but NODE=production run on docker
