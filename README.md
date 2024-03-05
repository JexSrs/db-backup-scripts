# db-backup-scripts
Shell scripts to backup MySQL and MongoDB databases and upload them to an S3 bucket

## Supported databases
- `MongoDB`
- `MySQL`

## Environment variables

Each backup script includes a `.env.example` file mentioning the required environment variables

## Setup

For each backup script, use the `docker compose` command to create and start the container.
```shell
docker compose up --build -d
```