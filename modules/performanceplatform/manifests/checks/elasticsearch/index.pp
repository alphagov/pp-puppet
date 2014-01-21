define performanceplatform::checks::elasticsearch::index(
  $type,
) {

  $graphite_key_suffix = "elasticsearch_${name}_${type}"
  $graphite_key = "curl_json-${graphite_key_suffix}.gauge-count"
  $graphite_fqdn = regsubst($::fqdn, '\.', '_', 'G')
  $graphite = "collectd.${graphite_fqdn}.${graphite_key}"

  collectd::plugin::curl_json { $graphite_key_suffix:
    url      => "http://localhost:9200/${name}/${type}/_count",
    instance => $graphite_key_suffix,
    keys     => {
      count => { type => 'gauge' },
    },
  }

  performanceplatform::checks::graphite { "check_rate_${name}_${type}":
    target   => "removeBelowValue(derivative(${graphite},0)",
    warning  => '0:',
    critical => '0:',
    interval => 60,
    handlers => ['default'],
  }

}
