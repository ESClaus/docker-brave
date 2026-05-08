# Docker container for Brave Browser
[![Release](https://img.shields.io/github/release/ESClaus/docker-brave.svg?logo=github&style=for-the-badge)](https://github.com/ESClaus/docker-brave/releases/latest)
[![Docker Image Size](https://img.shields.io/docker/image-size/esclaus/docker-brave/latest?logo=docker&style=for-the-badge)](https://hub.docker.com/r/esclaus/docker-brave/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/esclaus/docker-brave?label=Pulls&logo=docker&style=for-the-badge)](https://hub.docker.com/r/esclaus/docker-brave)
[![Docker Stars](https://img.shields.io/docker/stars/esclaus/docker-brave?label=Stars&logo=docker&style=for-the-badge)](https://hub.docker.com/r/esclaus/docker-brave)
[![Build Status](https://img.shields.io/github/actions/workflow/status/ESClaus/docker-brave/build-image.yml?logo=github&branch=main&style=for-the-badge)](https://github.com/ESClaus/docker-brave/actions/workflows/build-image.yml)

This project provides a lightweight Docker container for
[Brave Browser](https://brave.com), built on top of
[jlesage/baseimage-gui](https://github.com/jlesage/docker-baseimage-gui).

Access the application's full graphical interface directly from any modern web
browser - no downloads, installs, or setup required on the client side - or
connect with any VNC client.

> [!NOTE]
> This Docker container is entirely unofficial and not made by the creators of
> Brave Browser.

---

[![Brave logo](https://raw.githubusercontent.com/ESClaus/docker-brave/main/brave-icon.png)](https://brave.com)

Brave is a free and open-source web browser focused on privacy and security.
It includes a built-in ad blocker, tracker blocking, and fingerprinting
protection by default — no extensions required.

---

## Why This Container?

The [LinuxServer.io Brave container](https://docs.linuxserver.io/images/docker-brave/)
uses [Selkies](https://github.com/selkies-project/selkies), a WebRTC-based
remote desktop streaming technology. While feature-rich, the WebRTC encoding
overhead can feel laggy and unresponsive — especially over remote connections.

This container uses TigerVNC via
[jlesage's baseimage-gui](https://github.com/jlesage/docker-baseimage-gui),
providing a significantly more responsive experience with lower latency.

---

## Table of Contents

   * [Quick Start](#quick-start)
   * [Usage](#usage)
      * [Environment Variables](#environment-variables)
      * [Data Volumes](#data-volumes)
      * [Ports](#ports)
      * [Docker Compose File](#docker-compose-file)
   * [Docker Image Versioning and Tags](#docker-image-versioning-and-tags)
   * [Docker Image Update](#docker-image-update)
      * [unRAID](#unraid)
   * [User/Group IDs](#usergroup-ids)
   * [Accessing the GUI](#accessing-the-gui)
   * [Security](#security)
   * [Reverse Proxy](#reverse-proxy)
   * [Allowing the membarrier System Call](#allowing-the-membarrier-system-call)
   * [Troubleshooting](#troubleshooting)
   * [Support or Contact](#support-or-contact)

## Quick Start

> [!IMPORTANT]
> The Docker command provided in this quick start is an example, and parameters
> should be adjusted to suit your needs.

Launch the Brave Browser docker container with the following command:

```shell
docker run -d \
    --name=brave-browser \
    -p 5800:5800 \
    -v /docker/appdata/brave-browser:/config:rw \
    --shm-size=1gb \
    esclaus/docker-brave
```

Where:

  - `/docker/appdata/brave-browser`: Stores the application's configuration,
    state, logs, and any files requiring persistency.

Access the Brave Browser GUI by browsing to `http://your-host-ip:5800`.

> [!IMPORTANT]
> The `--shm-size=1gb` parameter is required. Brave is a Chromium-based browser
> and requires a large shared memory allocation to function correctly. Without
> it the browser will crash on startup.

## Usage

```shell
docker run [-d] \
    --name=brave-browser \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    --shm-size=1gb \
    esclaus/docker-brave
```

| Parameter | Description |
|-----------|-------------|
| -d        | Runs the container in the background. If not set, the container runs in the foreground. |
| -e        | Passes an environment variable to the container. See [Environment Variables](#environment-variables) for details. |
| -v        | Sets a volume mapping to share a folder or file between the host and the container. See [Data Volumes](#data-volumes) for details. |
| -p        | Sets a network port mapping to expose an internal container port to the host. See [Ports](#ports) for details. |

## Environment Variables

To customize the container's behavior, you can pass environment variables using
the `-e` parameter in the format `<VARIABLE_NAME>=<VALUE>`.

| Variable | Description | Default |
|----------|-------------|---------|
|`USER_ID`| ID of the user the application runs as. See [User/Group IDs](#usergroup-ids) for details. | `1000` |
|`GROUP_ID`| ID of the group the application runs as. See [User/Group IDs](#usergroup-ids) for details. | `1000` |
|`SUP_GROUP_IDS`| Comma-separated list of supplementary group IDs for the application. | (no value) |
|`UMASK`| Mask controlling permissions for newly created files and folders, specified in octal notation. | `0022` |
|`TZ`| [TimeZone](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones) used by the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, Brave is automatically restarted if it crashes or terminates. | `0` |
|`CONTAINER_DEBUG`| When set to `1`, enables debug logging. | `0` |
|`DISPLAY_WIDTH`| Width (in pixels) of the application's window. | `1920` |
|`DISPLAY_HEIGHT`| Height (in pixels) of the application's window. | `1080` |
|`SECURE_CONNECTION`| When set to `1`, uses an encrypted connection to access the GUI via web browser or VNC client. See [Security](#security) for details. | `0` |
|`VNC_PASSWORD`| Password required to connect to the application's GUI. | (no value) |
|`WEB_AUTHENTICATION`| When set to `1`, protects the GUI with a login page when accessed via a web browser. Requires `SECURE_CONNECTION` to be enabled. | `0` |
|`WEB_AUTHENTICATION_USERNAME`| Optional username for web authentication. | (no value) |
|`WEB_AUTHENTICATION_PASSWORD`| Optional password for web authentication. | (no value) |
|`WEB_LISTENING_PORT`| Port used by the web server to serve the GUI. | `5800` |
|`VNC_LISTENING_PORT`| Port used by the VNC server to serve the GUI. | `5900` |
|`BRAVE_OPEN_URL`| The URL to open when Brave starts. Multiple URLs can be opened by separating them with the pipe character (`\|`). | (no value) |
|`BRAVE_KIOSK`| Set to `1` to enable kiosk mode. Launches Brave in a restricted, full-screen mode suitable for public displays. | `0` |
|`BRAVE_CUSTOM_ARGS`| Custom argument(s) to pass when launching Brave. | (no value) |

## Data Volumes

The following table describes the data volumes used by the container. Volume
mappings are set using the `-v` parameter with a value in the format
`<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path | Permissions | Description |
|----------------|-------------|-------------|
|`/config`| rw | Stores the application's configuration, state, logs, and any files requiring persistency. |

## Ports

The following table lists the ports used by the container.

When using the default bridge network, ports can be mapped to the host using the
`-p` parameter with value in the format `<HOST_PORT>:<CONTAINER_PORT>`.

| Port | Protocol | Mapping to Host | Description |
|------|----------|-----------------|-------------|
| 5800 | TCP | Optional | Port to access the application's GUI via the web interface. |
| 5900 | TCP | Optional | Port to access the application's GUI via VNC. |

## Docker Compose File

Below is an example `docker-compose.yml` file for use with
[Docker Compose](https://docs.docker.com/compose/overview/).

```yaml
services:
  brave-browser:
    image: esclaus/docker-brave
    ports:
      - "5800:5800"
    volumes:
      - "/docker/appdata/brave-browser:/config:rw"
    shm_size: "1gb"
```

## Docker Image Versioning and Tags

Each release of this Docker image is tagged with the version of Brave Browser
it contains. The following tags are available:

| Tag | Description |
|-----|-------------|
| `latest` | Always points to the most recently built image. |
| `1.89.145` | Specific Brave Browser version. |

To use a specific version:

```shell
docker pull esclaus/docker-brave:1.89.145
```

View all available tags on [Docker Hub](https://hub.docker.com/r/esclaus/docker-brave/tags).

## Docker Image Update

When a new version of Brave Browser is released, a new image is built and
published to Docker Hub automatically. The `latest` tag always points to the
most recently built image.

To manually update the Docker image, follow these steps:

  1. Fetch the latest image:
```shell
docker pull esclaus/docker-brave
```

  2. Stop the container:
```shell
docker stop brave-browser
```

  3. Remove the container:
```shell
docker rm brave-browser
```

  4. Recreate and start the container using the `docker run` command, with the
     same parameters used during initial deployment.

> [!NOTE]
> Since all application data is saved under the `/config` container folder,
> destroying and recreating the container does not result in data loss, and
> Brave resumes with the same profile, extensions, and settings provided the
> `/config` folder mapping remains unchanged.

### unRAID

For unRAID users, update a container image with these steps:

  1. Select the *Docker* tab.
  2. Click the *Check for Updates* button at the bottom of the page.
  3. Click the *apply update* link of the container to be updated.

## User/Group IDs

When mapping data volumes, permission issues may arise between the host and the
container. To avoid this, specify the user the application should run as using
the `USER_ID` and `GROUP_ID` environment variables.

To find the appropriate IDs, run the following command on the host:

```shell
id <username>
```

This produces output like: uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom)
Use the `uid` and `gid` values to configure the container.

## Accessing the GUI

Assuming the container's ports are mapped to the same host's ports, access the
Brave Browser GUI as follows:

  - Via a web browser:

```text
http://<HOST_IP_ADDR>:5800
```

  - Via any VNC client:

```text
<HOST_IP_ADDR>:5900
```

## Security

By default, access to the application's GUI uses an unencrypted connection (HTTP
or VNC).

A secure connection can be enabled via the `SECURE_CONNECTION` environment
variable. When enabled, the GUI is accessed over HTTPS when using a browser,
with all HTTP accesses redirected to HTTPS.

### VNC Password

To restrict access to your application, set a password using the `VNC_PASSWORD`
environment variable.

> [!CAUTION]
> VNC password is limited to 8 characters. This limitation comes from the Remote
> Framebuffer Protocol specification.

### Web Authentication

Access to the application's GUI via a web browser can be protected with a login
page. When enabled, users must provide valid credentials to gain access.

Enable web authentication by setting the `WEB_AUTHENTICATION` environment
variable to `1`.

> [!IMPORTANT]
> Web authentication requires the container to be configured with secure web
> access. Set `SECURE_CONNECTION=1` to enable HTTPS.

## Reverse Proxy

The following NGINX configuration can be used to set up a reverse proxy to this
container.

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

upstream docker-brave {
    server 127.0.0.1:5800;
}

server {
    [...]

    server_name brave.domain.tld;

    location / {
        proxy_pass http://docker-brave;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_buffering off;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
```

## Allowing the membarrier System Call

To properly function, Brave requires the `membarrier` system call. Without it,
the browser may crash.

Docker uses a seccomp profile to restrict system calls available to the
container. Before Docker version `20.10.0`, the `membarrier` system call was
not allowed in the default profile. If you run such a version, use one of the
following solutions:

  1. Run the container with a custom seccomp profile allowing the `membarrier`
     system call. Download the [latest official seccomp profile] and add the
     following parameter when creating the container:
     `--security-opt seccomp=/path/to/seccomp_profile.json`
  2. Run the container without the default seccomp profile:
     `--security-opt seccomp=unconfined`
  3. Run the container in privileged mode:
     `--privileged`

[latest official seccomp profile]: https://github.com/moby/moby/blob/master/vendor/github.com/moby/profiles/seccomp/default.json

## Troubleshooting

### Browser Crashes on Startup

Ensure the `--shm-size=1gb` parameter is set when creating the container.
Brave is a Chromium-based browser and requires a large shared memory allocation.
Without it the browser will crash immediately on startup.

### membarrier Warnings

If you see warnings about the `membarrier` system call in the container logs,
see the [Allowing the membarrier System Call](#allowing-the-membarrier-system-call)
section for solutions.

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/ESClaus/docker-brave/issues).