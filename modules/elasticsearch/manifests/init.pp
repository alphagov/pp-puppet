# == Type: elasticsearch
#
class elasticsearch (
  $cluster_hosts = ['localhost'],
  $cluster_name = 'elasticsearch',
  $heap_size = '512m',
  $http_port = '9200',
  $mlock_all = false,
  $minimum_master_nodes = '1',
  $host = 'localhost',
  $number_of_replicas = '1',
  $number_of_shards = '5',
  $refresh_interval = '1s',
  $transport_port = '9300',
  $data_directory = '/mnt/elasticsearch',
  $version = 'present',
) {
  anchor { 'elasticsearch::begin':
    notify => Class['elasticsearch::service'];
  }

  class { 'elasticsearch::install':
    require => Anchor['elasticsearch::begin'],
    notify  => Class['elasticsearch::service'],
    version => $version;
  }

  class { 'elasticsearch::config':
    cluster_hosts        => $cluster_hosts,
    cluster_name         => $cluster_name,
    heap_size            => $heap_size,
    http_port            => $http_port,
    mlock_all            => $mlock_all,
    number_of_replicas   => $number_of_replicas,
    number_of_shards     => $number_of_shards,
    refresh_interval     => $refresh_interval,
    transport_port       => $transport_port,
    minimum_master_nodes => $minimum_master_nodes,
    host                 => $host,
    data_directory       => $data_directory,
    require              => Class['elasticsearch::install'],
    notify               => Class['elasticsearch::service'];
  }

  class { 'elasticsearch::service':
    cluster_name => $cluster_name,
    notify       => Anchor['elasticsearch::end'],
  }

  anchor { 'elasticsearch::end': }

}
