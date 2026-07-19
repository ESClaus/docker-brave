# Docker container for Brave Browser
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

> [!TIP]
> Two variants are available: standard **Brave** and **Brave Origin**, a build
> that ships without Rewards, Wallet, VPN, Leo, and other bundled features. See
> [Image Variants](#image-variants).

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

   * [Image Variants](#image-variants)
   * [Quick Start](#quick-start)
   * [Usage](#usage)
      * [Environment Variables](#environment-variables)
      * [Data Volumes](#data-volumes)
      * [Ports](#ports)
      * [Docker Compose File](#docker-compose-file)
   * [Docker Image Versioning and Tags](#docker-image-versioning-and-tags)
   * [Browser Policies](#browser-policies)
   * [Docker Image Update](#docker-image-update)
      * [unRAID](#unraid)
   * [User/Group IDs](#usergroup-ids)
   * [Accessing the GUI](#accessing-the-gui)
   * [Security](#security)
   * [Reverse Proxy](#reverse-proxy)
   * [Allowing the membarrier System Call](#allowing-the-membarrier-system-call)
   * [Troubleshooting](#troubleshooting)
   * [Support or Contact](#support-or-contact)

## Image Variants

This repository publishes two variants from the same Dockerfile, selected by the
`BRAVE_FLAVOR` build argument.

| Variant | Tag prefix | Description |
|---------|------------|-------------|
| Brave | *(none)* | The standard Brave Browser release. |
| Brave Origin | `origin-` | [Brave Origin](https://brave.com/origin/), a build that ships without Rewards, Wallet, VPN, Leo (Brave AI), Talk, News, and other bundled features. |

Both variants are built for `linux/amd64` and `linux/arm64`, use identical
container tooling, and behave the same way with respect to configuration,
environment variables, and data volumes.

If you previously used this container with the enterprise debloat policies that
shipped in earlier versions, **Brave Origin is the closest equivalent** and is
the recommended choice. See [Browser Policies](#browser-policies) for details on
what changed.

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

To run the Brave Origin variant instead, use the `origin-latest` tag:

```shell
docker run -d \
    --name=brave-origin \
    -p 5800:5800 \
    -v /docker/appdata/brave-origin:/config:rw \
    --shm-size=1gb \
    esclaus/docker-brave:origin-latest
```

> [!IMPORTANT]
> Use a separate `/config` directory for each variant. The two builds maintain
> independent profiles and should not share one.

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

To run the Brave Origin variant instead, change the image tag and use a separate
config directory:

```yaml
services:
  brave-origin:
    image: esclaus/docker-brave:origin-latest
    ports:
      - "5800:5800"
    volumes:
      - "/docker/appdata/brave-origin:/config:rw"
    shm_size: "1gb"
```

## Docker Image Versioning and Tags

Each release of this Docker image is tagged with the version of Brave Browser
it contains. The following tags are available:

| Tag | Variant | Description |
|-----|---------|-------------|
| `latest` | Brave | Always points to the most recently built image. |
| `1.92.141` | Brave | A specific Brave version. |
| `origin-latest` | Brave Origin | Always points to the most recently built image. |
| `origin-1.92.141` | Brave Origin | A specific Brave Origin version. |

Images are additionally tagged with the Git commit SHA they were built from
(for example `origin-c97323e...`), which can be used to pin to an exact build
when multiple images share the same Brave version.

To use a specific version:

```shell
docker pull esclaus/docker-brave:1.92.141
docker pull esclaus/docker-brave:origin-1.92.141
```

View all available tags on [Docker Hub](https://hub.docker.com/r/esclaus/docker-brave/tags).

## Browser Policies

> [!IMPORTANT]
> **This changed in Brave 1.92.141.** Earlier versions of this container shipped
> an enterprise policy file that disabled Leo, Rewards, Wallet, VPN, Tor, News,
> Talk, Speedreader, Playlist, Wayback Machine, and telemetry. That file has been
> removed. If you relied on it, use the **Brave Origin** variant, which ships
> without those features by design, or restore the policies yourself using the
> instructions below.

The standard Brave image now ships a single policy:

```json
{
  "BraveWalletDisabled": true
}
```

This is **not** a feature preference. It works around an upstream bug: as of
Brave 1.92, the browser aborts with `SIGTRAP` during wallet initialization on
first launch inside a headless container, and the container exits immediately.
The failure only occurs with an empty `/config` — existing profiles are
unaffected — which is why it went unnoticed for several releases. Setting this
policy prevents the crash.

Brave 1.90.122 does not exhibit the problem. Passing
`--disable-features=BraveWallet` does not prevent it; only the policy does.

This policy will be removed once the upstream issue is fixed. The Brave Origin
image ships no policy file at all, since it does not include the wallet.

### Download Prompt

Both variants set `download.prompt_for_download` to `false` via Chromium's
`initial_preferences` mechanism. Brave's "Ask where to save each file before
downloading" dialog cannot render inside the container, so downloads would
otherwise hang.

Unlike a policy, this only seeds the default on first run — the setting remains
visible and changeable in Brave's settings.

### Restoring the Previous Debloat Policies

If you preferred the previous behavior and do not want to switch to Brave
Origin, save the following as `policies.json` on your host:

```json
{
  "BraveAIChatEnabled": false,
  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveVPNDisabled": true,
  "TorDisabled": true,
  "BraveP3AEnabled": false,
  "BraveStatsPingEnabled": false,
  "BraveWebDiscoveryEnabled": false,
  "BraveNewsDisabled": true,
  "BraveTalkDisabled": true,
  "BraveSpeedreaderEnabled": false,
  "BraveWaybackMachineEnabled": false,
  "BravePlaylistEnabled": false
}
```

Then mount it over the container's policy file:

```shell
-v /path/to/your/policies.json:/etc/brave/policies/managed/policies.json:ro
```

> [!WARNING]
> If you write your own policy file for the standard Brave image, keep
> `"BraveWalletDisabled": true` in it. Omitting it will reintroduce the
> first-launch crash described above.

Applied policies can be reviewed at `brave://policy`. A full list of options is
available in the
[Brave Policy Documentation](https://support.brave.com/hc/en-us/articles/360039248271).

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

### GPU and DBus Errors in Log

When viewing the container logs, you may see errors similar to these:

Could not dlopen libGL.so.1: libGL.so.1: cannot open shared object file
Failed to connect to the bus: Failed to connect to socket /run/dbus/system_bus_socket
Error contacting kwalletd

These errors are expected and harmless in a containerized environment. Brave
attempts to connect to system services (DBus, KWallet, GPU hardware) that are
not available inside the container. Brave falls back gracefully in all cases
and continues to function normally.

These errors do not affect browsing, extensions, or any other functionality.

### "Restore Pages?" Dialog After Restart

When the container is restarted, Brave may display a "Brave didn't shut down
correctly" dialog offering to restore pages. This is expected behavior caused
by the container stopping before Brave can write a clean exit state. Simply
dismiss the dialog by clicking the X — it does not indicate any data loss or
corruption.

### Container Exits Immediately on First Run

If the container starts and then exits with status `0` before the GUI becomes
available, and `/config/log/brave/error.log` ends with a line similar to:

```text
/usr/bin/brave-browser: line 30: 1005 Trace/breakpoint trap "$HERE/brave" "$@"
```

then Brave is aborting during startup. As of Brave 1.92 this occurs during
wallet initialization when the profile directory is empty.

The standard image ships a policy that prevents this. If you have mounted your
own `policies.json`, ensure it includes `"BraveWalletDisabled": true`. See
[Browser Policies](#browser-policies).

Note that this failure only occurs with a **new, empty** `/config`. An existing
profile will start normally, which can make the problem appear intermittent.

### "Profile in use" Error After Container Update

If Brave fails to start after updating the container or Brave version, showing
an error like "The profile appears to be in use by another Brave process on
another computer," this is caused by stale lock files left over from an
unclean shutdown.

This container automatically cleans up known lock file locations on startup:

- `/config/profile/SingletonLock`
- `/config/profile/SingletonSocket`
- `/config/profile/SingletonCookie`
- Crashpad lock files in `/config/xdg/config/BraveSoftware/*/Crash Reports/pending/`
  (the directory is `Brave-Browser` or `Brave-Origin` depending on the variant)

If you still encounter this error, the lock files may exist in a location not
covered by this cleanup. You can manually remove them with:

```shell
docker exec -it brave-browser sh -c 'rm -f /config/profile/Singleton*'
```

Then restart the container.

## Support or Contact

Having troubles with the container or have questions? Please
[create a new issue](https://github.com/ESClaus/docker-brave/issues).
