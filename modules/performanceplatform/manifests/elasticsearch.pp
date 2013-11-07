class performanceplatform::elasticsearch(
  $data_directory,
) {

  class { '::elasticsearch':
    data_directory => '/mnt/data/elasticsearch',
  }

  cron {'elasticsearch-rotate-indices':
    ensure  => present,
    user    => 'nobody',
    hour    => '0',
    minute  => '1',
    command => '/usr/local/bin/es-rotate --delete-old --delete-maxage 21 --optimize-old --optimize-maxage 1 logs',
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

}
