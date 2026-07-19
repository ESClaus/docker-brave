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

## Image Variants

Two variants are built from the same Dockerfile:

| Variant | Tags | Description |
|---------|------|-------------|
| Brave | `latest`, `1.92.141` | The standard Brave Browser release. |
| Brave Origin | `origin-latest`, `origin-1.92.141` | [Brave Origin](https://brave.com/origin/), a build without Rewards, Wallet, VPN, Leo (Brave AI), Talk, News, and other bundled features. |

Both are available for `linux/amd64` and `linux/arm64` and behave identically
with respect to configuration, environment variables, and volumes.

If you used this container when it shipped enterprise debloat policies, **Brave
Origin is the closest equivalent** and is the recommended replacement.

## Quick Start

```shell
docker run -d \
    --name=brave-browser \
    -p 5800:5800 \
    -v /docker/appdata/brave-browser:/config:rw \
    --shm-size=1gb \
    esclaus/docker-brave
```

For Brave Origin, use the `origin-latest` tag and a separate config directory:

```shell
docker run -d \
    --name=brave-origin \
    -p 5800:5800 \
    -v /docker/appdata/brave-origin:/config:rw \
    --shm-size=1gb \
    esclaus/docker-brave:origin-latest
```

> **Important:** The `--shm-size=1gb` parameter is required. Without it Brave
> will crash on startup.

Access the GUI by browsing to `http://your-host-ip:5800`.

## Browser Policies

**This changed in 1.92.141.** Earlier versions shipped an enterprise policy file
disabling Leo, Rewards, Wallet, VPN, Tor, News, Talk, Speedreader, Playlist,
Wayback Machine, and telemetry. That file has been removed — use the **Brave
Origin** variant if you want those features gone, or supply your own policy file.

The standard Brave image now ships a single policy, `BraveWalletDisabled`. This
is not a feature preference: as of Brave 1.92 the browser aborts with `SIGTRAP`
during wallet initialization on first launch in a headless container, causing
the container to exit immediately. The failure only occurs with an empty
`/config`. The policy prevents it and will be removed once fixed upstream.

Brave Origin ships no policy file, since it does not include the wallet.

Both variants disable the "Ask where to save each file" download prompt via
Chromium's `initial_preferences`, because that dialog cannot render inside the
container. Unlike a policy, this only seeds the default — the setting remains
changeable in Brave's settings.

To supply your own policies:

```shell
-v /path/to/your/policies.json:/etc/brave/policies/managed/policies.json:ro
```

> **Warning:** If you write your own policy file for the standard Brave image,
> keep `"BraveWalletDisabled": true` in it, or the first-launch crash returns.
> The previous debloat policy set is documented in the
> [GitHub repository](https://github.com/ESClaus/docker-brave) for anyone who
> wants to restore it.

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

  brave-origin:
    image: esclaus/docker-brave:origin-latest
    ports:
      - "5801:5800"
    volumes:
      - "/docker/appdata/brave-origin:/config:rw"
    shm_size: "1gb"
```

## Documentation

For full documentation including security configuration, reverse proxy setup,
and troubleshooting, visit the
[GitHub repository](https://github.com/ESClaus/docker-brave).
