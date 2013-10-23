class performanceplatform::backdrop_smoke_tests (
) {
    $check_data_path ="/etc/sensu/backdrop-write-read-test.rb"

    package {['curb','json']:
      ensure   => installed,
      provider => gem,
      require  => Package['ruby1.9.1-dev'],
    }

    file { "/etc/sensu/backdrop-write-read-test.rb":
      require => Class['sensu'],
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => "puppet:///modules/performanceplatform/backdrop-write-read-test.rb"
    }

    sensu::check { 'backdrop_smoke_tests':
      interval => 120,
      command  => "ruby ${check_data_path}  -u 'https://${www_vhost}/test' -b'b6be45f57635955b99742bda9970639d3982e52c690d052c6856beb991f865f25b3b87290acf7e1f09927f5ab4c2b6a24c91cc2a01f547e72d0864247ba868ca'"
    }
}
