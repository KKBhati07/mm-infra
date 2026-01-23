#!/bin/bash
set -e

# Initialize all application databases
# This script runs automatically when PostgreSQL container is first initialized
# Files in /docker-entrypoint-initdb.d/ are executed in alphabetical order
# 
# Note: POSTGRES_DB creates 'marketmate' automatically, but we create it explicitly
# here for consistency between local development and production environments

# Function to create database if it doesn't exist
create_database_if_not_exists() {
    local db_name=$1
    DB_EXISTS=$(psql -U "$POSTGRES_USER" -d "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname='$db_name'")
    
    if [ -z "$DB_EXISTS" ]; then
        echo "Creating database '$db_name'..."
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
            CREATE DATABASE $db_name;
EOSQL
        echo "Database '$db_name' created successfully"
    else
        echo "Database '$db_name' already exists, skipping creation"
    fi
}

# Create marketmate database (for Spring Boot backend)
create_database_if_not_exists "marketmate"

# Create mm_chat database (for chat engine service)
create_database_if_not_exists "mm_chat"

echo "All databases initialized successfully"
