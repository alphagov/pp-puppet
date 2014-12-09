# Install mongodb in a replicaset
# require_logshipper - hacky parameter needed to set relationship correctly
# as logshipper is defined in hiera, and the development vm does not require
# it
class performanceplatform::mongo (
    $data_dir,
    $disk_mount = undef,
    $mongo_hosts,
    $version = undef,
){

    validate_string($version)

    class { 'mongodb':
        enable_10gen    => true,
        replSet         => 'production',
        logpath         => '/var/log/mongodb/mongodb.log',
        dbpath          => $data_dir,
        nohttpinterface => true,
        version         => $version,
    }


    group{ 'mongodb':
      ensure  => present,
    }

    user{ 'mongodb':
      ensure  => present,
      require => Group['mongodb']
    }

    file { $data_dir:
      ensure  => directory,
      owner   => 'mongodb',
      group   => 'mongodb',
      require => User['mongodb']
    }

    if ($disk_mount) {
      performanceplatform::mount { $data_dir:
        mountoptions => 'defaults',
        disk         => $disk_mount,
        require      => File[$data_dir],
        before       => Class['mongodb']
      }

      performanceplatform::checks::disk { "${::fqdn}_${data_dir}":
        fqdn => $::fqdn,
        disk => $data_dir,
      }

      lvm::volume { 'mongo':
        ensure => 'present',
        vg     => 'data',
        pv     => '/dev/sdb1',
        fstype => 'ext4',
        before => Performanceplatform::Mount[$data_dir]
      }
    }

    logrotate::rule { 'mongodb-rotate':
      path          => '/var/log/mongodb/mongodb.log',
      rotate        => 30,
      rotate_every  => 'day',
      missingok     => true,
      compress      => true,
      create        => true,
      sharedscripts => true,
      create_mode   => '0640',
      create_group  => 'mongodb',
      create_owner  => 'mongodb',
      # This is ugly, mongodb does it's own logrotation so we need to remove them
      # http://viktorpetersson.com/2011/12/22/mongodb-and-logrotate/
      postrotate    => 'killall -SIGUSR1 mongod && find /var/log/mongodb/ -type f -regex ".*\.\(log.[0-9].*-[0-9].*\)" -exec rm {} \;'
    }
    file { '/etc/mongodb':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }
    $mongo_members_tmp = join($mongo_hosts,'","')
    $mongo_members = "[\"${mongo_members_tmp}\"]"
    file { '/etc/mongodb/configure-replica-set.js':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/etc/mongodb'],
        content => "
function replicaSetMembers() {
  var members = ${mongo_members};
  var i = 0;
  return members.map(function(member) {
    return {
      _id: i++,
      host: member
    };
  })
}

function replicaSetConfig() {
  return {
    _id: 'production',
    members: replicaSetMembers()
  };
}

rs.initiate(replicaSetConfig());
"
    }
    exec { 'configure-replica-set':
      command => "echo '/usr/bin/mongo --host ${mongo_hosts[0]} /etc/mongodb/configure-replica-set.js' | at now + 3min",
      unless  => "/usr/bin/mongo --host ${mongo_hosts[0]} --quiet --eval 'rs.status().ok' | grep -q 1",
      require => [
        File['/etc/mongodb/configure-replica-set.js'],
        Service['mongodb'],
        Package['at'],
      ],
    }

    # MongoDB works best with a lower tcp keepalive
    # http://docs.mongodb.org/manual/faq/diagnostics/#does-tcp-keepalive-time-affect-sharded-clusters-and-replica-sets
    exec { 'set-tcp_keepalive_time':
      command => 'echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time',
      unless  => '[ "300" = "$(cat /proc/sys/net/ipv4/tcp_keepalive_time)" ]',
    }

    $escaped_fqdn = regsubst($::fqdn, '\.', '_', 'G')

    sensu::check { "mongod_is_down_${escaped_fqdn}":
      command  => '/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p mongod -W 1 -C 1',
      interval => 60,
      handlers => ['default'],
    }

    # MongoDB collectd plugin
    vcsrepo { '/etc/collectd/plugins/mongodb':
        ensure   => present,
        provider => git,
        source   => 'https://github.com/sebest/collectd-mongodb.git',
        revision => '359a8d2aab16b2cc89d38c2c07564f594bd5ec96',
        require  => Package['git'],
    }
    package { 'pymongo':
        ensure   => present,
        provider => pip,
        require  => Package['python-pip'],
    }
    include collectd
    file { "${::collectd::params::plugin_conf_dir}/01-mongodb.conf":
        ensure => present,
        owner  => root,
        group  => $::collectd::params::root_group,
        mode   => '0640',
        source => 'puppet:///modules/performanceplatform/collectd/mongodb.conf',
        notify => Service['collectd'],
    }
}
