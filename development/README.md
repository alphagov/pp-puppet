# pp-development

A Performance Platform development environment that uses [alphagov/pp-puppet](https://github.com/alphagov/pp-puppet) to provision you a virtual machine.

## DEPRECATED: Moving to pp-puppet

All the scripts and setup tools in this repo are being moved to [pp-puppet](https://github.com/alphagov/pp-puppet). This repository should no longer be used.

## Host machine prerequisites

- [Vagrant](http://www.vagrantup.com/) (note that vagrant >=1.4 is required to use VirtualBox >=4.3)
  - And the vagrant-dns plugin: `vagrant plugin install vagrant-dns`
- Software to run the virtual machine
  - An exact version of [VirtualBox](https://www.virtualbox.org/) for which there exists a [machine image in `$boxesByVersion` in the Vagrantfile](./Vagrantfile). At time of writing this means **4.3.6r91406** but more versions may be added in the future. Mixing versions of virtualbox and additions is unsupported.
  - [VMware](http://www.vmware.com/uk/) should also work
  - To improve performance, users of OSX can set the nfs flag to true [in the Vagrandfile](https://github.com/alphagov/pp-development/blob/master/Vagrantfile#L124). Linux (nfs seems to be more buggy) users may need to install the following packages: ``nfs-kernel-server nfs-common portmap``
  - [local overrides to Vagrant config](https://github.com/alphagov/pp-development/commit/ad3226b6185840f3395fde0c5e175332bf4aab6f) can [go in a local file](https://github.com/alphagov/gds-boxen/blob/120075b037a1e2b4826baa6bb1e12c8709aefa4d/modules/people/files/jabley/pp-development-1-Vagrantfile.localconfig)

## Basic setup

- Clone this folder onto your local machine with `git clone git@github.com:alphagov/pp-development.git`. You can do this in your `~/govuk` folder if you have one or in a separate `~/performance-platform` folder
- Install dependencies with `GOVUK_DEPS=true ./install.sh`
  - Warnings about the ``pp-deployment`` repository can be safely ignored (it contains deployment secrets that you may not have access to)
- Start the virtual machine with `vagrant up`
  - VMWare users may [hit an error](http://superuser.com/questions/511679/getting-an-error-trying-to-set-up-shared-folders-on-an-ubuntu-instance-of-vmware)
  - VirtualBox users should not ignore warnings about a mismatch between
    the version of VirtualBox and the Guest Additions. One known symptom is the
    inability to create symlinks inside Shared Folders, ie ``/var/apps``
  - [vagrant-dns occasionally has a problem](https://github.com/BerlinVagrant/vagrant-dns/issues/27#issuecomment-31514786), so may need [additional configuration](https://github.com/alphagov/gds-boxen/commit/a78bc9861f9fc303497d81d26ab652be41e646f5).
- Starting the machine should also provision it using Puppet (resulting in lots of lines beginning `[bootstrap] Notice: /Stage[main]`), but if it doesn't you can safely reprovision at any time with `vagrant provision`
- **NOTE**
  Initial provisioning of the machine may fail with an error message of the form:
  ```
  Error: No such file or directory - /var/apps/pp-puppet/.tmp/librarian/cache/source/puppet/forge/3792e516e3ff92a0ef9f5e827f8e76eb/smarchive/archive/version/7663d0c47292d3c50eb71d008ed8a340/archive/spec/fixtures/modules/archive/files

  Error: Try 'puppet help module install' for usage

  /var/apps/pp-puppet/vendor/bundle/ruby/1.9.1/gems/librarian-puppet-0.9.13/lib/librarian/puppet/source/forge.rb:114:in `unlink': Directory not empty - /var/apps/pp-puppet/.tmp/librarian/cache/source/puppet/forge/3792e516e3ff92a0ef9f5e827f8e76eb/smarchive/archive/version/7663d0c47292d3c50eb71d008ed8a340 (Errno::ENOTEMPTY)
  ```
  If this happens, running `vagrant provision` again may fix it (issue [#36](https://github.com/alphagov/pp-development/issues/36)).
- When provisioning has completed successfully you should see the line:
  `[bootstrap] pp-development/tools/bootstrap-vagrant exit success`
- SSH on to the virtual machine with `vagrant ssh`
- Install dependencies for each required app in `/var/apps` by following the
  instructions in their README files

## Running apps

- SSH on to the machine with `vagrant ssh`
- Change to the development directory with `cd /var/apps/pp-development`
- Start the apps individually with `bowl backdrop_read` or `bowl spotlight`, or all together with
  `bowl performance`
  - The `bowl` command uses groups from the `Pinfile`, which runs commands from the `Procfile`

## Routing from your local machine to your VM

This only works **if your platform is OSX**.

Each app runs on its own local port ie 3038, 3039, 3057. From inside the VM you can access apps directly at `localhost:3038`. If you install [vagrant-dns](https://github.com/BerlinVagrant/vagrant-dns/), you can access the VM from the host through `perfplat.dev` subdomains, i.e `www.perfplat.dev` or `spotlight.perfplat.dev`.
