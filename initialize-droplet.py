#! /bin/env python3
"""
Environment variables:

    DIGITALOCEAN_ACCESS_TOKEN
        The token to use to authenticate to the DigitalOcean API.
"""

import os
import sys
import digitalocean


def prompt_select(prompt, options, formatter, multiple=False, default=None):
    options = list(options)
    while True:
        print()
        print(prompt)
        default_idx = None
        for i, opt in enumerate(options):
            print(f'  {i}: {formatter(opt)}')
            if default and opt.slug == default:
                default_idx = i
        print()

        try:
            how_many = 'any' if multiple else 'one'
            result = set(
                map(
                    int,
                    input('Enter {} of the indexes{}: '.format(
                        how_many,
                        f' [{default_idx}]' if default else '',
                    )).split(),
                ))
        except Exception:
            continue
        if len(result) == 0:
            if default:
                return options[default_idx]
            continue
        elif len(result) == 1:
            return options[list(result)[0]]
        elif multiple is False:
            continue
        else:
            return [o for i, o in enumerate(options) if i in result]


def prompt_proceed(prompt):
    while True:
        proceed = input(prompt + ' [yN]')
        if proceed in ('y', 'Y'):
            return True
        elif proceed in ('n', 'N', ''):
            return False


token = (os.environ.get('DIGITALOCEAN_ACCESS_TOKEN')
         or input('DigitalOcean Access Token: '))

print(f'Using Access Token: {token}')
manager = digitalocean.Manager(token=token)

# Prompt for the keys to auto-add to the droplet.
keys_to_use = prompt_select(
    'Which SSH keys do you want to be able to access the machine?',
    manager.get_all_sshkeys(),
    lambda s: s.name,
    multiple=True,
)

name = os.environ.get('DROPLET_NAME') or input('Droplet name: ')

region = os.environ.get('DROPLET_REGION')
if not region:
    region = prompt_select(
        'Which droplet region do you want to use?',
        manager.get_all_regions(),
        lambda r: f'{r.name}: {r.slug}',
        default='sfo2',
    ).slug

size = os.environ.get('DROPLET_SIZE')
if not size:
    size = prompt_select(
        'Which droplet size do you want to use?',
        filter(lambda m: m.memory <= 8192, manager.get_all_sizes()),
        lambda s: f'{s.memory}MiB/{s.disk}GiB@${s.price_monthly}/mo: {s.slug}',
        default='s-1vcpu-1gb',
    ).slug

image = os.environ.get('DROPLET_IMAGE')
if not image:
    image = prompt_select(
        'Which droplet size do you want to use?',
        filter(
            lambda i: (i.slug is not None and region in i.regions and
                       ('ubuntu' in i.slug or 'fedora' in i.slug)),
            manager.get_all_images(),
        ),
        lambda i: f'{i.name}: {i.slug}',
        default='ubuntu-16-04-x64',
    ).slug

user_data = '''#cloud-config

runcmd:
  - apt install -y git
  - git clone https://gitlab.com/sumner/infrastructure.git
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=digitalocean NIX_CHANNEL=nixos-19.09 bash 2>&1 | tee /tmp/infect.log
'''

print()
print('=' * 80)
print('SUMMARY:')
print('=' * 80)
print(f'''
A droplet named "{name}" with initial image of "{image}" and size
"{size}" will be created in the {region} region.

The following SSH keys will be able to access the machine:
    { ', '.join(map(lambda k: k.name, keys_to_use))}

It will be configured with the following cloud configuration:

{user_data}''')

if not prompt_proceed(
        'Would you like to create a droplet with this configuration?'):
    print('Cancelling!')
    sys.exit(1)

droplet = digitalocean.Droplet(
    backups=False,
    image=image,
    ipv6=True,
    name=name,
    region=region,
    size_slug=size,
    ssh_keys=keys_to_use,
    tags=['web-server', 'wireguard'],
    token=token,
    user_data=user_data,
)

droplet.create()
