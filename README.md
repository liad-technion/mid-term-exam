# status-dashboard

A small internal **Status Dashboard** service: a Python/Flask app, containerized with Docker, served on port 80 by host nginx acting as a reverse proxy.

## Architecture

```
client ──► nginx (host, :80) ──► Docker container (127.0.0.1:5000) ──► Flask app
```

- Flask runs inside a Docker container as a non-root user.
- The container's port is bound to **loopback only** (`127.0.0.1:5000`) — not reachable directly from the network.
- nginx runs on the **host** (not in a container) and reverse-proxies `/` and `/api/` to the container.

## Endpoints

| Method | Path              | Behavior                                                                                     |
| ------ | ----------------- | -------------------------------------------------------------------------------------------- |
| GET    | `/`               | Static HTML page with a button that calls `/api/v1/status` and renders the JSON result.      |
| GET    | `/api/status`     | Redirects to `/api/v1/status`.                                                               |
| GET    | `/api/v1/status`  | `{"status": "ok", "hostname": "<container>", "version": "<VERSION>"}`                        |
| GET    | `/api/v1/secret`  | Requires header `X-API-Key: <API_KEY>`. Returns `401` if missing/wrong, JSON payload if OK.  |

## Requirements

A small helper script is included (optional) to verify everything you need is in place before running the installer:

```bash
./pre-req-check.sh
```

It checks for `docker` (and group membership), `git`, `python3`, `pip`, `poetry`, `nginx`, `curl`, `jq`, `vim`, and `nano`, and prints the apt/install command for anything missing.

## Configuration

The app and install script read values from a `.env` file at the repository root.

```bash
cp .env.example .env
# edit .env and set API_KEY to a real value
```

| Variable  | Required | Default   | Notes                                            |
| --------- | -------- | --------- | ------------------------------------------------ |
| `API_KEY` | yes      | —         | Required by `/api/v1/secret`.                    |
| `VERSION` | no       | `1.0.0`   | Returned by `/api/v1/status`.                    |
| `PORT`    | no       | `5000`    | Internal Flask port (bound to loopback only).    |

You may also pass `API_KEY` inline:

```bash
sudo API_KEY=my-strong-key ./install.sh
```

## Install

From the repository root:

```bash
sudo ./install.sh
```

The script:

1. Verifies it is running as root.
2. Loads `.env` (fails if missing or `API_KEY` is empty).
3. Builds the Docker image `status-dashboard`.
4. Removes any previous `status-dashboard` container (safe to re-run).
5. Runs the new container detached, with `--restart unless-stopped`, bound to `127.0.0.1:5000`.
6. Installs `status-dashboard.conf` into `/etc/nginx/sites-available/`, symlinks it into `sites-enabled/`, removes the default site.
7. Runs `nginx -t`, enables nginx at boot, and reloads (or starts) the service.

On success it prints the URLs the service is reachable at.

## Verify

```bash
# JSON status
curl -s http://localhost/api/status | jq .

# Secret without key → 401
curl -s -o /dev/null -w "%{http_code}\n" http://localhost/api/secret

# Secret with key → 200 + JSON
curl -s -H "X-API-Key: letmein" http://localhost/api/secret | jq .

# Browser
open http://localhost/
```
