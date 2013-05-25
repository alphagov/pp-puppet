Performance Platform Puppet
===========================

Contains the puppet code and Vagrant definitions to provision environments for Performance Platform

# Prereq

You will need access to the repos:

- `pp-puppet` obviously, DUH!
- `pp-puppet-secrets` for secrets when provisioning _real_ environments

# WARNING: This is a Public Repo

It is not expected that any secret data (keys, certificates, your inside leg measurement) is
committed to this repo. Anything in here is in the public domain and should only be used for
test environments. Secret data for real environments should be in the `pp-puppet-secrets` repo
and will be combined with this when deploying real machines.

# Setup

The preferred method of installing Vagrant is through Bundler. This allows us
to pin specific versions. However if you already have a system-wide
installation that should also work.

It is recommended that you use Ruby 1.9 through rbenv. `alphagov/gds-boxen`
can also set this up for you. Alternatively you can read about how to do it
yourself [here](https://github.com/sstephenson/rbenv/#homebrew-on-mac-os-x)
and [here](http://dan.carley.co/blog/2012/02/07/rbenv-and-bundler/).

## Tests!

The intention is that this repo refers to external well-tested modules via the Puppetfile.
Given that, the tests for the puppet code in the `manifests` directory are deliberately minimal.
Running `bundle exec rake test` will:

1. Check that no nasty lint has been introduced into the puppet code
2. Run rspec-puppet to test that the individual machine manifests compile
3. Check that the Puppetfile does not contain any references to `git@github` style URLs

## Building a .deb file from the Puppet code

There is support for building a .deb package of the Puppet code, with the intention of deploying
this and any environment-specific hiera data (from `pp-puppet-secrets`) to the environment. You can
build a debian package with `BUILD_NUMBER=212121 bundle exec rake deb`, however the exact mechanism
for deploying this to an environment is yet to be defined.

## Usage

You need only bring up the subset of nodes that you're working on. For
example, to bring up a frontend and backend:
```sh
vagrant up jumpbox-1.management frontend-1.frontend
```

Vagrant will run the Puppet provisioner against the node when it boots up.
Nodes should look almost identical to that of a real environment, including
network addresses. To access a node's services like HTTP/HTTPS you can point
your `hosts` file to the host-only IP address (eth1).

Physical attributes like `memory` and `num_cores` will be ignored because
they don't scale appropriately to local VMs, but can still be customised as
described below.

### Bringing up the MongoDB cluster

MongoDB Replicaset configuration requires that all nodes are up and running Mongo first, so as we
bring up nodes one at a time, it will silently fail on the first two nodes. It is likely to fail
on the 3rd node as well, because mongodb might have started, but is not actually available by the
time the script runs. To fix this (before we have a cronjob to run puppet), simply reprovision one
of the nodes:

```
vagrant provision mongo-1.backend"
```

To verify that mongo is working, do `vagrant ssh mongo-1.backend`, run `mongo` and then issue the
command `rs.isMaster()` - you should see output something like this:

```
production:SECONDARY> rs.isMaster()
{
    "setName" : "production",
    "ismaster" : false,
    "secondary" : true,
    "hosts" : [
            "mongo-2.backend:27017",
            "mongo-3.backend:27017",
            "mongo-1.backend:27017"
    ],
    "primary" : "mongo-1.backend:27017",
    "me" : "mongo-2.backend:27017",
    "maxBsonObjectSize" : 16777216,
    "maxMessageSizeBytes" : 48000000,
    "localTime" : ISODate("2013-05-25T14:11:09.095Z"),
    "ok" : 1
}
```

## Creating new node types

### Creating the definition of the machine for provisioning

The Vagrantfile will bring up nodes defined in the `config/vm-templates` directory. Here is an example:
```json
{
    "class":     "jumpbox",
    "zone":      "management",
    "vm_name":   "jumpbox-1",
    "ip":        "10.0.0.100",
    "num_cores": "2",
    "memory":    "2048"
}
```
 - `class`:     The puppet class (defined in `manifests/machines/${class}.pp`) which will be applied to the machine
 - `zone`:      A logical or network grouping of machines (examples might be `management`, `frontend`). The machine
                json template lives in a directory also named after the zone.
 - `vm_name`:   The name of the VM - it should be unique
 - `ip`:        The IP assigned to the first interface on a real machine or second interface on a Vagrant VM
 - `num_cores`: Vagrant will ignore this, however it will be used for provisioning the real machine
 - `memory`:    Vagrant will ignore this (it defaults to 256MB), however it will be used for provisioning the real machine

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
    jumpbox-1.management.production:
        ip: 10.0.0.100
        host_aliases: jumpbox-1
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

User accounts are managed in 'config/hiera/data/common.yaml'. They look like this:

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

Some errors that you might encounter..

### Ruby warnings
```
/usr/local/lib/site_ruby/1.9.1/rubygems/custom_require.rb:36:in `require': iconv will be deprecated in the future, use String#encode instead.
/usr/lib/ruby/gems/1.9.1/gems/puppet-2.7.19/lib/puppet/provider/service/bsd.rb:12: warning: class variable access from toplevel
```
These are expected because Puppet 2.7 doesn't quite claim to be compatible
with Ruby 1.9

### NFS failed mounts
```
[frontend-1.frontend] Mounting NFS shared folders...
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
