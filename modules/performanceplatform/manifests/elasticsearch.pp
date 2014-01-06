class performanceplatform::elasticsearch(
  $data_dir,
  $disk_mount,
  $cluster_hosts,
  $minimum_master_nodes,
  $heap_size,
) {

  class { '::elasticsearch':
    cluster_hosts         => $cluster_hosts,
    data_directory        => $data_dir,
    host                  => $::hostname,
    heap_size             => $heap_size,
    minimum_master_nodes  => $minimum_master_nodes,
    require               => Performanceplatform::Mount[$data_dir],
  }


  file { '/mnt/data':
    ensure => directory,
  }

  performanceplatform::mount { $data_dir:
    mountoptions => 'defaults',
    disk         => $disk_mount,
    require      => File['/mnt/data'],
  }


  cron {'elasticsearch-rotate-indices':
    ensure  => present,
    user    => 'nobody',
    hour    => '0',
    minute  => '1',
    command => '/usr/local/bin/es-rotate --delete-old --delete-maxage 21 logstash',
    require => Class['::elasticsearch'],
  }

  elasticsearch::plugin { 'head':
    install_from => 'mobz/elasticsearch-head',
  }

  elasticsearch::template { 'wildcard':
    content =>  '{
      "template": "*",
      "order": 0,
      "settings": {
        "index.query.default_field":    "@message",
        "index.store.compress.stored":  "true",
        "index.cache.field.type":       "soft",
        "index.refresh_interval":       "10s"
      },
      "mappings": {
        "_default_": {
          "_all": {
            "enabled": false
          },
          "properties": {
            "@fields": {
              "path": "full",
              "dynamic": true,
              "properties": {
                "args": {
                    "type": "string"
                }
              },
              "type": "object"
            },
            "@message":     { "index": "analyzed",     "type": "string" },
            "@source":      { "index": "not_analyzed", "type": "string" },
            "@source_host": { "index": "not_analyzed", "type": "string" },
            "@source_path": { "index": "not_analyzed", "type": "string" },
            "@tags":        { "index": "not_analyzed", "type": "string" },
            "@timestamp":   { "index": "not_analyzed", "type": "date"   },
            "@type":        { "index": "not_analyzed", "type": "string" }
          }
        }
      }
    }'
  }

  sensu::check { 'elasticsearch_is_out_of_memory':
    command  => '/etc/sensu/community-plugins/plugins/files/check-tail.rb -f /var/log/elasticsearch/elasticsearch.log -l 50 -P OutOfMemory',
    interval => 60,
    handlers => ['default', 'pagerduty'],
  }

  sensu::check { 'elasticsearch_cluster_status':
    command  => "/etc/sensu/community-plugins/plugins/elasticsearch/check-es-cluster-status.rb -s ${::hostname}",
    interval => 60,
    handlers => ['default'],
  }

  $graphite_fqdn = regsubst($::fqdn, '\.', '_', 'G')

  performanceplatform::graphite_check { "check_low_disk_space_elasticsearch":
    target   => "collectd.${graphite_fqdn}.df-mnt-data-elasticsearch.df_complex-free",
    warning  => '4000000000:', # A little less than 4 gig
    critical => '1000000000:',  # A little less than 1 gig
    interval => 60,
    handlers => ['default', 'pagerduty'],
  }

}
