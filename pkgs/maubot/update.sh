#! /usr/bin/env sh

wget -O yarn.lock https://raw.githubusercontent.com/maubot/maubot/master/maubot/management/frontend/yarn.lock

yarn2nix > yarnPkgs.nix
