class performanceplatform::backdrop_smoke_tests (
  $test_bucket_token='qwertyuiop'
) {
    $check_data_path ="/etc/sensu/backdrop-write-read-test.rb"

    file { "/etc/sensu/backdrop-write-read-test.rb":
      require => Class['sensu'],
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => "puppet:///modules/performanceplatform/backdrop-write-read-test.rb"
    }

    sensu::check { 'backdrop_smoke_tests':
      interval => 120,
      command  => "ruby ${check_data_path}  -u 'https://${::www_vhost}/data/test/test' -b'${test_bucket_token}'",
      handlers => ['default', 'pagerduty'],
    }
}
