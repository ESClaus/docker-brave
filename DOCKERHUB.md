# Docker container for Brave Browser

This project provides a Docker container for [Brave Browser](https://brave.com),
built on top of [jlesage/baseimage-gui](https://github.com/jlesage/docker-baseimage-gui)
using TigerVNC for a responsive, low-latency remote desktop experience.

Access Brave directly from any modern web browser or VNC client — no client-side
installation required.

## Why This Container?

The [LinuxServer.io Brave container](https://docs.linuxserver.io/images/docker-brave/)
uses Selkies, a WebRTC-based streaming technology that can feel laggy over remote
connections. This container uses TigerVNC, providing significantly lower latency
and a more responsive browsing experience.

## Quick Start

```shell
docker run -d \
    --name=brave-browser \
    -p 5800:5800 \
    -v /docker/appdata/brave-browser:/config:rw \
    --shm-size=1gb \
    esclaus/docker-brave
```

> **Important:** The `--shm-size=1gb` parameter is required. Without it Brave
> will crash on startup.

Access the GUI by browsing to `http://your-host-ip:5800`.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
|`DISPLAY_WIDTH`| Width in pixels of the application window. | `1920` |
|`DISPLAY_HEIGHT`| Height in pixels of the application window. | `1080` |
|`TZ`| Timezone used by the container. | `Etc/UTC` |
|`KEEP_APP_RUNNING`| When set to `1`, Brave restarts automatically if it crashes. | `0` |
|`SECURE_CONNECTION`| When set to `1`, enables HTTPS and encrypted VNC. | `0` |
|`VNC_PASSWORD`| Password required to access the GUI. | (no value) |
|`BRAVE_OPEN_URL`| URL to open when Brave starts. Separate multiple URLs with `\|`. | (no value) |
|`BRAVE_KIOSK`| Set to `1` to enable kiosk mode. | `0` |
|`BRAVE_CUSTOM_ARGS`| Custom arguments to pass when launching Brave. | (no value) |

## Ports

| Port | Description |
|------|-------------|
| 5800 | Web interface (noVNC). |
| 5900 | VNC client access. |

## Data Volumes

| Container Path | Description |
|----------------|-------------|
|`/config`| Stores Brave's profile, extensions, settings, and logs. |

## Docker Compose

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

## Documentation

For full documentation including security configuration, reverse proxy setup,
and troubleshooting, visit the
[GitHub repository](https://github.com/ESClaus/docker-brave).