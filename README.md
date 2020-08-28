# Personal Infrastructure

![Build Status](https://builds.sr.ht/~sumner/infrastructure.svg)
[![HealthCheck Status](https://healthchecks.io/badge/b8bf9b9d-b4bb-4c92-b546-1c69a0/BpOIMYGi.svg)](https://healthchecks.io/projects/8384107b-0803-48b3-bd99-7702d1214ca5/checks/)

## Things I Run

* [Airsonic](https://airsonic.github.io/)
* [Bitwarden RS](https://github.com/dani-garcia/bitwarden_rs)
* [Isso](https://posativ.org/isso/)
* [Matomo](https://matomo.org/)
* [Synapse](https://github.com/matrix-org/synapse) for
  [Matrix](https://matrix.org).
* [Murmur for Mumble](https://www.mumble.info/)
* [Quassel](https://quassel-irc.org/)
* [The Lounge](https://thelounge.chat/)
* [Wireguard](https://www.wireguard.com/)
* [Xandikos](https://www.xandikos.org/)

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
