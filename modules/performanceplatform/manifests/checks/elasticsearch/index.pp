define performanceplatform::checks::elasticsearch::index(
  $index,
  $type,
) {

  $graphite_key_suffix = "elasticsearch_${index}_${type}"
  $graphite_key = "curl_json-${graphite_key_suffix}.gauge-count"
  $graphite_fqdn = regsubst($::fqdn, '\.', '_', 'G')
  $graphite = "collectd.${graphite_fqdn}.${graphite_key}"

  collectd::plugin::curl_json { $graphite_key_suffix:
    url      => "http://localhost:9200/${index}/${type}/_count",
    instance => $graphite_key_suffix,
    keys     => {
      count => { type => 'gauge' },
    },
  }

  # Elasticsearch indices should generally be growing, apart from when
  # the current index is rolled overnight. We use removeBelowValue to stop
  # the massive negative derivative (when rolling) causing the check to fire.
  performanceplatform::checks::graphite { $name:
    target   => "removeBelowValue(derivative(${graphite}),0)",
    warning  => '0',
    critical => '0',
    below    => true,
    interval => 60,
    handlers => ['default'],
  }

}
