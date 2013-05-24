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

## Creating new node types

### Creating the definition of the machine for provisioning

The Vagrantfile will bring up nodes defined in the `machine-templates` directory. Here is an example:
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
}
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
