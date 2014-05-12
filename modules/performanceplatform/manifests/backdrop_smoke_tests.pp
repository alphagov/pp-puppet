class performanceplatform::backdrop_smoke_tests (
  $test_data_set_token='qwertyuiop'
) {
    file { "/etc/sensu/backdrop-write-read-test.rb":
      ensure  => absent,
      require => Class['sensu'],
    }

    sensu::check { 'backdrop_smoke_tests':
      ensure => absent,
    }
}
