# Epsilon - OpenSAFELY Job Server

This project is a containerized version of OpenSAFELY Job Server, designed for easy deployment.

## Prerequisites

- Docker and Docker Compose installed on your system
- Git (optional, for cloning the repository)

## Running the Container

1. Save the docker-compose.yml file to your local machine:

```yaml
version: '3.8'

services:
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: jobserver
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 10s
      timeout: 10s
      retries: 5

  web:
    image: ghcr.io/khajievn/epsilon:latest
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/jobserver
      - JOBSERVER_GITHUB_TOKEN=${JOBSERVER_GITHUB_TOKEN:-dummy}
      - SOCIAL_AUTH_GITHUB_KEY=${SOCIAL_AUTH_GITHUB_KEY:-dummy}
      - SOCIAL_AUTH_GITHUB_SECRET=${SOCIAL_AUTH_GITHUB_SECRET:-dummy}
      - DEBUG=1
      - SECRET_KEY=12345
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health-check"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s

volumes:
  postgres_data:
```

2. Start the containers with default settings:

```bash
docker-compose up -d
```

3. Or specify custom GitHub credentials:

```bash
JOBSERVER_GITHUB_TOKEN=your_real_token \
SOCIAL_AUTH_GITHUB_KEY=your_github_key \
SOCIAL_AUTH_GITHUB_SECRET=your_github_secret \
docker-compose up -d
```

4. The application will be available at http://localhost:8000

5. To stop the container:

```bash
docker-compose down
```

## Initial Setup

### Adding a Staff User

To add staff role to a user, create a file named `add_staff_user.sh` with the following content:

```bash
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
```

Make the script executable and run it:

```bash
chmod +x add_staff_user.sh
./add_staff_user.sh YOUR_GITHUB_USERNAME
```

Note: The user must have logged in at least once before running this script.

### Creating a Backend

To create a backend for job-runner to communicate with job-server:

1. Log in to the job-server with your staff user
2. Navigate to the Staff Area (click on your avatar in the top right corner and select "Staff Area")
3. Go to "Backends" in the staff menu
4. Click "Add backend"
5. Fill in the required fields:
   - Name: A descriptive name (e.g., "Local Backend")
   - Slug: A unique identifier (e.g., "local")
   - Parent Directory: Where jobs will be run (e.g., "/tmp/opensafely")
   - Level 4 URL: Leave blank for local development
   - Is Active: Check this box

6. Click "Save" to create the backend

### Getting a Token for Job Runner

After creating a backend, you'll need to get its token to connect job-runner:

1. In the Staff Area, go to "Backends"
2. Click on the backend you just created
3. Copy the "Auth Token" value displayed on the page
4. Use this token in your job-runner configuration: