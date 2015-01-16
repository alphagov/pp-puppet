class performanceplatform::elasticsearch(
  $data_dir,
  $disk_mount,
  $cluster_hosts,
  $minimum_master_nodes,
  $heap_size,
) {

  file { '/mnt/data':
    ensure => directory,
  }

  performanceplatform::mount { $data_dir:
    mountoptions => 'defaults',
    disk         => $disk_mount,
    require      => File['/mnt/data'],
  }

  performanceplatform::checks::disk { "${::fqdn}_${data_dir}":
    fqdn => $::fqdn,
    disk => $data_dir,
  }

  lvm::volume { 'elasticsearch':
    ensure => 'present',
    vg     => 'data',
    pv     => '/dev/sdb1',
    fstype => 'ext4',
    before => Performanceplatform::Mount[$data_dir]
  }

  package { 'estools':
    ensure   => '1.1.2',
    provider => 'pip',
    require  => Package['python-pip'],
  }

  cron {'elasticsearch-rotate-indices':
    ensure  => present,
    user    => 'nobody',
    hour    => '0',
    minute  => '1',
    command => '/usr/local/bin/es-rotate --delete-old --delete-maxage 21 logstash',
    require => Class['::elasticsearch'],
  }

  sensu::check { 'elasticsearch_is_out_of_memory':
    command  => '/etc/sensu/community-plugins/plugins/files/check-tail.rb -f /var/log/elasticsearch/logs/elasticsearch.log -l 50 -P OutOfMemory',
    interval => 60,
    handlers => ['default'],
  }

  sensu::check { 'elasticsearch_cluster_status':
    command  => '/etc/sensu/community-plugins/plugins/elasticsearch/check-es-cluster-status.rb',
    interval => 60,
    handlers => ['default'],
    require  => Package['rest-client'],
  }

  apt::source { 'elasticsearch':
    location    => 'http://packages.elasticsearch.org/elasticsearch/1.3/debian',
    release     => 'stable',
    repos       => 'main',
    key         => 'D88E42B4',
    key_source  => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    include_src => false,
  }

  class { '::elasticsearch':
    version => '1.3.4',
    datadir => $data_dir,
    config  => {},
    require => [Performanceplatform::Mount[$data_dir], Class['java'], Apt::Source['elasticsearch']],
  }

  ::elasticsearch::instance { 'logs':
    config        => {
      'bootstrap.mlockall'       => false,
      'cluster.name'             => 'elasticsearch',
      'discovery'                => {
        'zen' => {
          'minimum_master_nodes' => $minimum_master_nodes,
          'ping'                 => {
            'multicast.enabled' => false,
            'unicast.hosts'     => $cluster_hosts,
          }
        }
      },
      'index.number_of_replicas' => 1,
      'index.number_of_shards'   => 5,
      'index.refresh_interval'   => '1s',
      'network.publish_host'     => $::hostname,
      'node.name'                => $::hostname,
      'script.disable_dynamic'   => true
    },
    init_defaults => {
      'ES_HEAP_SIZE' => $heap_size,
    },
    logging_file  => 'puppet:///modules/performanceplatform/elasticsearch/logging.yml',
  }

  ::elasticsearch::plugin { 'mobz/elasticsearch-head':
    module_dir => 'head',
    instances  => 'logs',
  }

  ::elasticsearch::plugin { 'lmenezes/elasticsearch-kopf':
    module_dir => 'kopf',
    instances  => 'logs',
  }

}
