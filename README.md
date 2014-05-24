[![Build Status](https://travis-ci.org/alphagov/pp-puppet.png)]
(https://travis-ci.org/alphagov/pp-puppet)

Performance Platform Puppet
===========================

This repository contains the Puppet code and Vagrant definitions to provision environments for the Performance Platform.

As well as definitions for the specific type of machines we use on the Performance Platform,
there is a `development-1` machine which you can use to run all our services on one VM. See
[the `development/` directory](/development) for more information.

# Prerequisites

You will need access to these repositories:

- `pp-puppet` (the one you're in)
- `pp-deployment` for secrets when provisioning _real_ environments

# WARNING: This is a public repo

No secret data (keys, certificates, your inside leg measurement) should be
committed to this repo. Anything in here is in the public domain and should only be used for
test environments. Secret data for real environments should be in the `pp-deployment` repo
and will be combined with this when deploying real machines.

# Setup

## Running virtual machines

You'll need [Vagrant](http://www.vagrantup.com/) installed on your machine to manage local VMs.

You'll also need a provider for your virtual machines. [Virtualbox](http://virtualbox.com/)
is what most of the Performance Platform use, but [VMware](http://www.vmware.com/uk/)
should also work. For VirtualBox, you need an exact version for which there exists a
[machine image in `$boxVersions` in the Vagrantfile](./Vagrantfile). At the time of
writing this means 4.3.6r91406 or 4.3.8r92456 but more may be added in the future.
Mixing versions of VirtualBox and guest additions is unsupported.

## Ruby and Puppet

We recommend that you use Ruby 1.9 through [rbenv](https://github.com/sstephenson/rbenv),
which may be a newer version than your system one.
[Boxen](https://github.com/alphagov/gds-boxen) can set this
up for you, or alternatively you can read about how to do it
yourself [using Homebrew](https://github.com/sstephenson/rbenv/#homebrew-on-mac-os-x)
or [with instructions from @dcarley](http://dan.carley.co/blog/2012/02/07/rbenv-and-bundler/).

Before bringing any machines up, you will need to install all the required gems.

You'll need [bundler](http://bundler.io/) to be installed:

```bash
gem install bundler
rbenv rehash # if you're using rbenv
```

Then run these commands from the host machine from inside this repo's directory:

```bash
bundle install --without NONEXISTENT
bundle exec librarian-puppet install
```

# Tests!

The intention is that this repo refers to external well-tested modules via the Puppetfile.
Given that, the tests for the Puppet code in the `manifests` directory are deliberately minimal.
Running `bundle exec rake test` will:

1. Check that no nasty lint has been introduced into the Puppet code
2. Run rspec-puppet to test that the individual machine manifests compile
3. Check that the Puppetfile does not contain any references to `git@github` style URLs

# Usage

You need only bring up the subset of nodes that you're working on. For
example, to bring up a frontend and backend:

```sh
vagrant up jumpbox-1 frontend-1
```

Vagrant will run Puppet against the node when it boots up.
Nodes should look almost identical to that of a real environment, including
network addresses. To access a node's services like HTTP/HTTPS you can point
your `hosts` file to the host-only IP address (eth1).

Physical attributes like `memory` and `num_cores` will be ignored because
they don't scale appropriately to local VMs (especially when running 10 of them)

## Bringing up the MongoDB cluster

MongoDB Replicaset configuration requires that all nodes are up and running Mongo first, on
initialisation, each node will background a job for 2 minutes later to configure the replicaset. This
means that it may take a couple of minutes after the last mongo node is provisioned before the replicaset
is available. If it doesn't work, then simply triggering provisioning on a node with the following command
and then waiting 2 minutes should make it work.

```
vagrant provision mongo-1
```

To verify that mongo is working, do `vagrant ssh mongo-1`, run `mongo` and then issue the
command `rs.isMaster()` - you should see output something like this:

```
production:SECONDARY> rs.isMaster()
{
    "setName" : "production",
    "ismaster" : false,
    "secondary" : true,
    "hosts" : [
            "mongo-2:27017",
            "mongo-3:27017",
            "mongo-1:27017"
    ],
    "primary" : "mongo-1:27017",
    "me" : "mongo-2:27017",
    "maxBsonObjectSize" : 16777216,
    "maxMessageSizeBytes" : 48000000,
    "localTime" : ISODate("2013-05-25T14:11:09.095Z"),
    "ok" : 1
}
```

## Configuring machines

Machines are configured according to the `class` as configured in `manifests/machines/${class}.pp`. Machines should
be configured to inherit the base class (`performanceplatform::base`) for definitions that apply to all machines (eg hosts, users).

```puppet
class machines::jumpbox inherits machines::base {
    notify { 'Included the Jumpbox class': }
}
```

It is important to also create the proper `/etc/hosts` entry for this machine on all the other machines. This can
be accomplished by extending the `performanceplatform::dns::hosts` section of `hieradata/common.yaml` with a definition for your new host:

It is expected that additional resources that are not already defined as native Puppet types will be utilised by
including external modules with `librarian-puppet` from the [Puppet Forge](https://forge.puppetlabs.com). An example of this is UFW:

```sh
grep ufw ./Puppetfile # => mod 'attachmentgenie/ufw'
```

```yaml
# hieradata/common.yaml
classes:
  'ufw'

# hieradata/role-frontend-app.yaml
ufw_rules:
  allow-http-from-anywhere:
    port: 80
    ip:   'any'
```

On that note, when configuring software which listens on network ports, don't forget to add an appropriate firewall
rule with UFW!

## Adding user accounts

User accounts are managed in `hieradata/common.yaml`. They look like this:

```yaml
accounts:
  ssharpe:
    comment: Sam J Sharpe
    ssh_key: AAAAB3NzaC1yc2EAAAABIwAAAQEAyNoMftFLf3w0NOW7J0KUwOx9897CU352n3zKD3p/GCcdH4eMv1QI0BhjItZplWG8TzFSBfWOOSruRh1Gksa1l1jiQcisEio6Wr7kZ7bpvMMA45ZoaDc26HTB+r0BZkNn7Lwwxxvy+1pbqStnnKzb9OTYIyVkb495LS0x1EL/P9S/NWtpm8ZULa1JDplYMA5SqMZnhmlGAXdh8UnjdcdOgOm2ngA+geJBSzVbABECiIAklHU1PRzOtrq8SuO8JmXW6NkuL0aabdTgE6noIm+Nn7T5ufZpOpIGYimVI8+mu+efcBzAp5Q0vTRgSBLfggdczZbFfPXpIt1Ib+LEf+Cuqw==
    groups:
      - admin
```

## Errors

Some errors that you might encounter...

### NFS failed mounts

```
[frontend-1] Mounting NFS shared folders...
Mounting NFS shared folders failed. This is most often caused by the NFS
client software not being installed on the guest machine. Please verify
that the NFS client software is properly installed, and consult any resources
specific to the linux distro you're using for more information on how to do this.
```

This seems to be caused by a combination of OS X, VirtualBox, and Cisco
AnyConnect. Try temporarily disconnecting from the VPN when bringing up a
new node. As a last resort, restarting your machine may help.

### hiera errors

```
[modules/performanceplatform:master]$ vagrant up jumpbox-1.management
There was a problem with the configuration of Vagrant. The error message(s)
are printed below:

hiera:
* Config file not found at '/Users/sam/Projects/gds/pp-puppet/manifests/machines/config/hiera/hiera.yaml'.
* Data directory not found at '/Users/sam/Projects/gds/pp-puppet/manifests/machines/config/hiera/data'.
```

This simply means you are not in the root directory (where the `Vagrantfile` lives), just `cd` there and you will be fine.
