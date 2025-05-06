# OpenSAFELY Job Runner Setup

This guide will help you set up and run the OpenSAFELY Job Runner using Docker Compose.

## Quick Setup

The easiest way to set up OpenSAFELY Job Runner is to use the provided setup script:

```bash
# Make it executable
chmod +x setup-opensafely.sh
# Run the setup script
./setup-opensafely.sh
```

## Manual Setup

### 1. Create Directory Structure

```bash
# Set the workdir base location
export WORKDIR_BASE="$HOME/opensafely-workdir"

# Create required directories
mkdir -p "$WORKDIR_BASE/high_privacy/volumes"
mkdir -p "$WORKDIR_BASE/high_privacy/workspaces"
mkdir -p "$WORKDIR_BASE/high_privacy/logs"
mkdir -p "$WORKDIR_BASE/medium_privacy/workspaces"

# Set permissions
chmod -R 777 "$WORKDIR_BASE"
```

### 2. Create Docker Compose File

Create a file named `docker-compose.yml` with the following content:

```yaml
version: '3.8'

services:
  job-runner:
    image: ghcr.io/khajievn/opensafely-job-runner:latest
    container_name: opensafely-job-runner
    restart: unless-stopped
    user: root
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${WORKDIR_BASE:-$HOME/opensafely-workdir}:/workdir
    environment:
      - WORKDIR=/workdir
      - BACKEND=test
      - USING_DUMMY_DATA_BACKEND=True
      - HIGH_PRIVACY_STORAGE_BASE=/workdir/high_privacy
      - MEDIUM_PRIVACY_STORAGE_BASE=/workdir/medium_privacy
      - HIGH_PRIVACY_VOLUME_DIR=/workdir/high_privacy/volumes
      - DOCKER_HOST=unix:///var/run/docker.sock
      - DOCKER_USER_ID=1000
      - DOCKER_GROUP_ID=1000
      - DOCKER_HOST_VOLUME_DIR=${WORKDIR_BASE:-$HOME/opensafely-workdir}/high_privacy/volumes
      - JOB_SERVER_ENDPOINT=${JOB_SERVER_ENDPOINT:-http://host.docker.internal:8000/api/v2/}
      - POLL_INTERVAL=5
      - JOB_LOOP_INTERVAL=1.0
      - TEST_MAX_WORKERS=2
      - ALLOWED_GITHUB_ORGS=Epsilon-Data  # Change to your GitHub organization
      - PRIVATE_REPO_ACCESS_TOKEN=your-github-token  # Replace with your GitHub token
      - TEST_JOB_SERVER_TOKEN=your-job-server-token  # Replace with your job server token
    ports:
      - "8888:8888"
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

### 3. Start the Container

```bash
docker compose up -d
```

## Understanding the WORKDIR

The `WORKDIR_BASE` (default: `$HOME/opensafely-workdir`) is where all OpenSAFELY data and outputs are stored. Inside the container, this is mounted as `/workdir`. The structure is:

- `/workdir/high_privacy/`: For sensitive patient-level data (Level 3)
  - `volumes/`: Where job volumes are stored
  - `workspaces/`: Where workspace data is stored
  - `logs/`: Where job logs are stored
- `/workdir/medium_privacy/`: For aggregated, moderately sensitive outputs (Level 4)
  - `workspaces/`: Where workspace data is stored

## Obtaining a Job Server Token

The job server token (`TEST_JOB_SERVER_TOKEN`) is needed for authentication with the OpenSAFELY job server. To get a token:

1. Access the OpenSAFELY job server (either your organization's instance or the public instance)
2. Log in with your credentials
3. Navigate to your user profile or API settings
4. Generate or copy your API token
5. Add this token to your Docker Compose file under the `TEST_JOB_SERVER_TOKEN` environment variable

For development or testing purposes, you can use the default token provided in the docker-compose.yml file.

## Configuring GitHub Access

The job runner needs access to GitHub repositories containing your OpenSAFELY projects. Configure:

1. `PRIVATE_REPO_ACCESS_TOKEN`: Your GitHub Personal Access Token with `repo` scope
2. `ALLOWED_GITHUB_ORGS`: The GitHub organizations containing your project repositories