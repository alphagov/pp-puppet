class machines::mongo inherits machines::base {
    ufw::allow { "allow-mongo-from-backend":
        port => 27017,
        ip   => 'any',
        from => $networks['backend']
    }
    class { 'mongodb':
        enable_10gen => true,
        replSet      => 'production',
        logpath      => '/var/log/mongodb/mongodb.log',
        dbpath       => '/var/lib/mongodb'
    }
    file { '/etc/mongodb':
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }
    $mongo_hosts = grep(keys($hosts),'mongo')
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
      command => "/usr/bin/mongo --host ${mongo_hosts[0]} /etc/mongodb/configure-replica-set.js",
      unless  => "/usr/bin/mongo --host ${mongo_hosts[0]} --quiet --eval 'rs.status().ok' | grep -q 1",
      require => [
        File['/etc/mongodb/configure-replica-set.js'],
        Service['mongodb'],
      ],
    }
}
