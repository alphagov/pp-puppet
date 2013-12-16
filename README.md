[![Build Status](https://travis-ci.org/alphagov/pp-puppet.png)]
(https://travis-ci.org/alphagov/pp-puppet)

Performance Platform Puppet
===========================

Contains the puppet code and Vagrant definitions to provision environments for Performance Platform

# Prereq

You will need access to the repos:

- `pp-puppet` obviously, DUH!
- `pp-deployment` for secrets when provisioning _real_ environments

# WARNING: This is a Public Repo

It is not expected that any secret data (keys, certificates, your inside leg measurement) is
committed to this repo. Anything in here is in the public domain and should only be used for
test environments. Secret data for real environments should be in the `pp-deployment` repo
and will be combined with this when deploying real machines.

# Setup

It is recommended that you use Ruby 1.9 through rbenv. `alphagov/gds-boxen`
can also set this up for you. Alternatively you can read about how to do it
yourself [here](https://github.com/sstephenson/rbenv/#homebrew-on-mac-os-x)
and [here](http://dan.carley.co/blog/2012/02/07/rbenv-and-bundler/).

Before bringing any machines up, you will need to install all the gems. Run
these commands from the host machine from inside this repo's directory:

    bundle install --without NONEXISTENT
    bundle exec librarian-puppet install

## Tests!

The intention is that this repo refers to external well-tested modules via the Puppetfile.
Given that, the tests for the puppet code in the `manifests` directory are deliberately minimal.
Running `bundle exec rake test` will:

1. Check that no nasty lint has been introduced into the puppet code
2. Run rspec-puppet to test that the individual machine manifests compile
3. Check that the Puppetfile does not contain any references to `git@github` style URLs

## Usage

You need only bring up the subset of nodes that you're working on. For
example, to bring up a frontend and backend:
```sh
vagrant up jumpbox-1 frontend-1
```

Vagrant will run the Puppet against the node when it boots up.
Nodes should look almost identical to that of a real environment, including
network addresses. To access a node's services like HTTP/HTTPS you can point
your `hosts` file to the host-only IP address (eth1).

Physical attributes like `memory` and `num_cores` will be ignored because
they don't scale appropriately to local VMs (especially when running 10 of them)

### Bringing up the MongoDB cluster

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

### Installing backdrop

Currently there are some [manual installation steps](https://github.com/alphagov/puppet-backdrop) for backdrop.

## Configuring machines

Machines are configured according to the `class` as configured in `manifests/machines/${class}.pp`. Machines should
be configured to inherit the base class (machines::base) for definitions that apply to all machines (e.g. hosts, users).

```puppet
class machines::jumpbox inherits machines::base {
    notify { 'Included the Jumpbox class': }
}
```

It is important to also create the proper `/etc/hosts` entry for this machine on all the other machines. This can
be accomplished by extending the hosts section of `config/hiera/data/common.yaml` with a definition for your new host:

```
hosts:
    jumpbox-1:
        ip: 172.27.1.2
```

It is expected that additional resources that are not already defined as native Puppet Types will be utilised by
including external modules with `librarian-puppet` from http://forge.puppetlabs.com - an example of this is UFW:

```sh
# grep ufw ./Puppetfile
mod 'attachmentgenie/ufw'

# class used in manifests/machines/base.pp
include ufw
ufw::allow { "allow-ssh-from-all":
    port => 22,
    ip   => 'any'
}
```

On that note, when configuring software which listens on network ports, don't forget to add an appropriate Firewall
rule with UFW!

## Adding user accounts

User accounts are managed in 'hieradata/common.yaml'. They look like this:

```
accounts:
    ssharpe:
        home_dir: /home/ssharpe
        comment: Sam J Sharpe
        ssh_key: AAAAB3NzaC1yc2EAAAABIwAAAQEAyNoMftFLf3w0NOW7J0KUwOx9897CU352n3zKD3p/GCcdH4eMv1QI0BhjItZplWG8TzFSBfWOOSruRh1Gksa1l1jiQcisEio6Wr7kZ7bpvMMA45ZoaDc26HTB+r0BZkNn7Lwwxxvy+1pbqStnnKzb9OTYIyVkb495LS0x1EL/P9S/NWtpm8ZULa1JDplYMA5SqMZnhmlGAXdh8UnjdcdOgOm2ngA+geJBSzVbABECiIAklHU1PRzOtrq8SuO8JmXW6NkuL0aabdTgE6noIm+Nn7T5ufZpOpIGYimVI8+mu+efcBzAp5Q0vTRgSBLfggdczZbFfPXpIt1Ib+LEf+Cuqw==
        groups:
            - admin
```

## Errors

Some errors that you might encounter...

### Ruby warnings
```
/usr/local/lib/site_ruby/1.9.1/rubygems/custom_require.rb:36:in `require': iconv will be deprecated in the future, use String#encode instead.
/usr/lib/ruby/gems/1.9.1/gems/puppet-2.7.19/lib/puppet/provider/service/bsd.rb:12: warning: class variable access from toplevel
```
These are expected because Puppet 2.7 doesn't quite claim to be compatible
with Ruby 1.9

### NFS failed mounts
```
[frontend-1] Mounting NFS shared folders...
Mounting NFS shared folders failed. This is most often caused by the NFS
client software not being installed on the guest machine. Please verify
that the NFS client software is properly installed, and consult any resources
specific to the linux distro you're using for more information on how to do this.
```
This seems to be caused by a combination of OSX, VirtualBox, and Cisco
AnyConnect. Try temporarily disconnecting from the VPN when bringing up a
new node.

### hiera errors
```
[manifests/machines:master●]$ vagrant up jumpbox-1.management
There was a problem with the configuration of Vagrant. The error message(s)
are printed below:

hiera:
* Config file not found at '/Users/sam/Projects/gds/pp-puppet/manifests/machines/config/hiera/hiera.yaml'.
* Data directory not found at '/Users/sam/Projects/gds/pp-puppet/manifests/machines/config/hiera/data'.
```
This simply means you are not in the root directory (where the `Vagrantfile` live), just cd there and you will be fine
