# Personal Infrastructure

```
.----------------------------------------------------------------------------.
| DEPRECATED:                                                                |
|                                                                            |
| I no longer use this to configure my infrastructure. Rather, I have        |
| unified all of my Nix system configurations under one repo which can be    |
| found here:                                                                |
| https://git.sr.ht/~sumner/nixos-configuration                              |
'----------------------------------------------------------------------------'
```

[![builds.sr.ht status](https://builds.sr.ht/~sumner/infrastructure/commits/.build.yml.svg)](https://builds.sr.ht/~sumner/infrastructure/commits/.build.yml)
[![HealthCheck Status](https://healthchecks.io/badge/b8bf9b9d-b4bb-4c92-b546-1c69a0/BpOIMYGi.svg)](https://healthchecks.io/projects/8384107b-0803-48b3-bd99-7702d1214ca5/checks/)

## Things I Run

* [Airsonic](https://airsonic.github.io)
* [Bitwarden RS](https://github.com/dani-garcia/bitwarden_rs)
* [GoAccess](https://goaccess.io/)
* [Isso](https://posativ.org/isso/)
* [Murmur for Mumble](https://www.mumble.info/)
* [Quassel](https://quassel-irc.org/)
* [Synapse](https://github.com/matrix-org/synapse) for
  [Matrix](https://matrix.org)
* [Syncthing](https://syncthing.net)
* [The Lounge](https://thelounge.chat/)
* [Wireguard](https://www.wireguard.com/)
* [Xandikos](https://www.xandikos.org/)

## Things I Want to Run

* Navidrome
* A photo gallery

## Goals

* Infrastructure as code
* Immutable infrastructure (as much as possible)
* Everything backed up to B2
* Everything backed up to onsite location

### Uptime

* Can blow away all machines (but not data) and restore in under an hour
* Can restore all data within one day after catastrophic failure (everything
  goes down, including data)

  * From local backup: 1 day
  * From B2: 2 days

## Backup Strategy

I am using [Restic](https://github.com/restic/restic) to backup everything.

## Things that Need Stored Somewhere

* Docs and such (low latency, need these in block storage)
* Photos (not as low latency, can have these in S3/Spaces/B2 storage if
  necessary)
* Music
* Configs (stored in this repo)
* Projects (stored in their respective Git(Hub|Lab) Repos)
* Password data

## Things that need to be setup by scripts

Q: Can these be done from within the management of NixOS?

* Airsonic: change admin user password
* Airsonic: create personal user
* Bitwarden: add a user
* Synapse user
* Mumble SuperUser
* Mumble channels

## Deploy Instructions

1. Get a working NixOS install.

   * https://www.linode.com/docs/tools-reference/custom-kernels-distros/install-nixos-on-linode/

2. Clone this repo to `/etc/nixos`.
3. Import `host.nix` from `configuration.nix`.
4. `nixos-rebuild switch --upgrade`
