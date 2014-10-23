# FIXME: make the file paths not depend on $cluster_name
class elasticsearch::config (
  $cluster_hosts,
  $cluster_name,
  $heap_size,
  $http_port,
  $mlock_all,
  $number_of_replicas,
  $number_of_shards,
  $refresh_interval,
  $transport_port,
  $minimum_master_nodes,
  $data_directory,
  $host,
) {
  $es_home = "/var/lib/elasticsearch-${cluster_name}"

  file { $es_home:
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { "${es_home}/config":
    ensure => directory,
  }

  file { "${es_home}/config/elasticsearch.yml":
    ensure  => present,
    content => template('elasticsearch/elasticsearch.yml.erb'),
  }

  file { "${es_home}/config/logging.yml":
    ensure  => present,
    content => template('elasticsearch/logging.yml.erb'),
  }

  file { "${es_home}/bin":
    ensure => link,
    target => '/usr/share/elasticsearch/bin',
  }

  file { "${es_home}/lib":
    ensure => link,
    target => '/usr/share/elasticsearch/lib',
  }

  file { "${es_home}/logs":
    ensure => link,
    target => '/var/log/elasticsearch',
  }

  file { "${es_home}/plugins":
    ensure => link,
    target => '/usr/share/elasticsearch/plugins',
  }

  file { $data_directory:
    ensure => directory,
    owner  => 'elasticsearch',
  }

  file { "${es_home}/data":
    ensure => link,
    target => $data_directory,
  }

  file { "/etc/init/elasticsearch-${cluster_name}.conf":
    content => template('elasticsearch/upstart.conf.erb'),
  }
}
