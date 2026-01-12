Infrastructure setup for minicraft Podman deployment.
```
minicraft/
├── .gitignore                  # Ignores local artifacts, secrets, build outputs, and temp files
├── README.md                   # overview: repo structure, etc
│
├── infra/                      # Host-level setup for networking, firewall, and pod deployment
│   ├── LICENSE                 # Project license (AGPL-3.0) stored alongside infra assets
│   ├── nftables.conf           # Firewall rules for TCP/UDP exposure and rate-limiting
│   ├── pod.yml                 # Podman pod definition (containers, ports, volumes)
│   ├── minicraftpod.kube       # Kubernetes-format spec used by podman play kube
│   ├── 25-dumpodintf.netdev    # systemd-networkd virtual interface definition
│   ├── 25-dumpodintf.network   # systemd-networkd network config for the pod interface
│   └── setup.sh                # Bootstrap script: installs deps, applies firewall, deploys pod
│
├── tnrfls/                     # Container build contexts for each service
│   ├── auth/                   # Caddy + oauth2-proxy for SSO and reverse proxying
│   │   ├── Dockerfile
│   │   ├── start.sh
│   │   ├── Caddyfile
│   │   └── oauth2-proxy.cfg
│   │
│   ├── stats/                  # PHP-FPM + TinyFileManager for stats and file access
│   │   ├── Dockerfile
│   │   ├── start.sh
│   │   ├── tfm_config.php
│   │   └── fpm_tfm_pool.conf
│   │
│   └── app/                    # Main application / game server container (UDP/TCP service)
│       ├── Dockerfile
│       ├── start.sh
│       └── app.conf
│
└── ops/                        # Operational helper scripts for day‑to‑day management
    ├── backup.sh               # Backup world data, configs, or persistent volumes
    ├── logs.sh                 # Tail or collect logs from running containers
    └── update.sh               # Rebuild images, pull updates, and restart the pod cleanly
```
Variable Handling (setup + configs)
setup.sh -> exports vars
pod.yml -> injects into containers
Dockerfile/.conf/.cfg/.php/Caddyfile -> read vars

Processes (what they provide)
[auth: Caddy+SSO] -> HTTP routing
[stats: PHP-FPM] -> stats/files
[app: server]    -> game TCP/UDP

Networking Routes (minecraft + web)
Browser -> HTTPS -> [auth] -> [stats/app HTTP]
Minecraft -> UDP/TCP -> [app] (bypasses SSO)

