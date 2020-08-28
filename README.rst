Personal Infrastructure
#######################

Things I Run
============

* `Airsonic <https://airsonic.github.io/>`_
* `Bitwarden RS <https://github.com/dani-garcia/bitwarden_rs>`_
* `Isso <https://posativ.org/isso/>`_
* `Matomo <https://matomo.org/>`_
* `Synapse <https://github.com/matrix-org/synapse>`_ for `Matrix
  <https://matrix.org>`_
* `Murmur for Mumble <https://www.mumble.info/>`_
* `Quassel <https://quassel-irc.org/>`_
* `The Lounge <https://thelounge.chat/>`_
* `Wireguard <https://www.wireguard.com/>`_
* `Xandikos <https://www.xandikos.org/>`_

Goals
=====

* Infrastructure as code
* Immutable infrastructure (as much as possible)
* Everything backed up to B2
* Everything backed up to onsite location

Uptime
------

* Can blow away all machines (but not data) and restore in under an hour
* Can restore all data within one day after catastrophic failure (everything
  goes down, including data)

  * From local backup: 1 day
  * From B2: 2 days

Backup Strategy
===============

I am using `Restic <https://github.com/restic/restic>`_ to backup everything.

Things that Need Stored Somewhere
=================================

* Docs and such (low latency, need these in block storage)
* Photos (not as low latency, can have these in S3/Spaces/B2 storage if
  necessary)
* Music
* Configs (stored in this repo)
* Projects (stored in their respective Git(Hub|Lab) Repos)
* Password data

Things that need to be setup by scripts
=======================================

- [ ] Can these be done from within the management of NixOS?

* Airsonic: change admin user password
* Airsonic: create personal user
* Bitwarden: add a user
* Synapse user
* Mumble SuperUser
* Mumble channels
