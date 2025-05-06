#!/bin/bash

# Script to add staff role to a user in OpenSAFELY Job Server

# Check if username was provided
if [ $# -eq 0 ]; then
    echo "Error: GitHub username is required"
    echo "Usage: $0 <github_username>"
    exit 1
fi

GITHUB_USERNAME=$1

# Execute command in the running Docker container
echo "Adding staff role for user: $GITHUB_USERNAME"
docker-compose exec web python manage.py create_user "$GITHUB_USERNAME" -s

echo "Done! If no errors appeared, the user has been granted staff privileges."
echo "You can now login with this GitHub account and access the Staff Area."