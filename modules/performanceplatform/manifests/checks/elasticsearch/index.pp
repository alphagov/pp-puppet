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

}
