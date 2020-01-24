Personal Infrastructure
#######################

Things I Need to Run
====================

* Airsonic
* Nextcloud
* Wireguard
* Mumble Server
* Bitwarden (rs version, probably)

Goals
=====

* Infrastructure as code
* Immutable infrastructure
* Everything backed up to B2
* Everything backed up to onsite location

Uptime
------

* Can blow away all machines (but not data) and restore in under an hour
* Can restore all data within one day after catastrophic failure (everything
  goes down, including data)

  * From local backup: 1 day
  * From B2: 2 days

Things that Need Stored Somewhere
---------------------------------

* Nextcloud docs and such (low latency, need these in object storage)
* Photos (not as low latency, can have these in S3 storage if necessary)
* Music
* Configs (stored in this repo)
* Projects (stored in their respective Git(Hub|Lab) Repos)
