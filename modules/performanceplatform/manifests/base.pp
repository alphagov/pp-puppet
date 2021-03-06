# Base resources for all PP machines
class performanceplatform::base(
  $dhparams,
) {
    stage { 'system':
        before => Stage['main'],
    }

    class { [ 'performanceplatform::dns',
              'performanceplatform::hosts' ]:
        stage => system,
    }

    file { '/etc/ssl/private/ssl-dhparam.pem':
      ensure  => present,
      content => $dhparams,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
    }

    class {'gstatsd': require => Class['python::install'] }

    $ppas = hiera_array('ppas', [])
    apt::ppa { $ppas: }

    # Ensure that apt::update, thus apt::ppa and apt::source, is applied
    # before installing any packages that might depend on them.
    Class['apt::update'] -> Package <|
      provider != 'pip' and
      provider != 'gem' and
      ensure != 'absent' and
      ensure != 'purged' and
      # Prevent dep loops within the apt module
      title != 'python-software-properties' and
      title != 'software-properties-common' and
      # Prevent dep loops with `system` stage (above)
      title != 'dnsmasq'
    |>

    $machine_role = regsubst($::hostname, '^(.*)-\d$', '\1')

    file { '/etc/environment':
        ensure  => present,
        content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\n",
    }
    file {'/etc/gds':
        ensure => directory,
    }
    # Make sure we are in UTC
    file { '/etc/localtime':
        source => '/usr/share/zoneinfo/UTC'
    }
    file { '/etc/timezone':
        content => 'UTC'
    }
    group { 'gds': ensure => present }
    file { '/etc/sudoers.d/gds':
        ensure  => present,
        mode    => '0440',
        content => '%gds ALL=(ALL) NOPASSWD: ALL
'
    }
    file { '/bin/su':
        ensure => present,
        mode   => '4750',
        owner  => 'root',
        group  => 'gds',
    }

    vcsrepo { '/etc/sensu/community-plugins':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/sensu/sensu-community-plugins.git',
        revision => '2595bf6dbab16e00bf273bd536e2ed30ab199ad9',
        require  => Package['git'],
    }

    # workaround for the elasticsearch puppet repo / logstash forwarder package
    # creating an init file that doesnt work
    # https://github.com/elasticsearch/puppet-logstashforwarder/pull/12/files
    file { '/etc/logstash-forwarder':
      ensure => link,
      target => "${logstashforwarder::configdir}/config.json";
    }

    # Workaround for the logstashforwarder module not creating the config
    # directory before using it. Because the config directory is already
    # specified with a `file`, we can't duplicate that. So we have to do
    # a horrible `exec` to get it to create the directory first. Yuck.
    # We also can't use the `configdir` parameter because we need to run
    # this exec before the class has been evaluated. Double yuck.
    # https://github.com/elasticsearch/puppet-logstashforwarder/pull/13
    exec { 'mkdir -p /etc/logstashforwarder':
      unless => 'ls /etc/logstashforwarder',
      before => Class[Logstashforwarder],
    }

}
