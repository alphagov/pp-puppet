# Install mongodb in a replicaset
class performanceplatform::mongo (
    $mongo_hosts,
){
    class { 'mongodb':
        enable_10gen => true,
        replSet      => 'production',
        logpath      => '/var/log/mongodb/mongodb.log',
        dbpath       => '/var/lib/mongodb'
    }
    logrotate::rule { "mongodb-rotate":
      path          => "/var/log/mongodb/mongodb.log",
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
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
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

    $escaped_fqdn = regsubst($::fqdn, '\.', '_', 'G')

    sensu::check { "mongod_is_down_${escaped_fqdn}":
      command  => '/etc/sensu/community-plugins/plugins/processes/check-procs.rb -p mongod -W 1 -C 1',
      interval => 60,
      handlers => ['default'],
    }

}
