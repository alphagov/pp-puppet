class performanceplatform::checks::smokey_tests (
) {
    $smokey_checker_script ="/etc/sensu/check-smokey-test.py"

    file { $smokey_checker_script:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
      source  => "puppet:///modules/performanceplatform/check-smokey-test.py"
    }

    sensu::check { 'smoke_test_admin_uploader':
      interval => 60,
      command  => "${smokey_checker_script} admin_uploader",
      handlers => ['default'],
      require  => File[$smokey_checker_script],
    }

    sensu::check { 'smoke_test_backdrop_read':
      interval => 60,
      command  => "${smokey_checker_script} backdrop_read",
      handlers => ['default'],
      require  => File[$smokey_checker_script],
    }

    sensu::check { 'smoke_test_backdrop_write':
      interval => 60,
      command  => "${smokey_checker_script} backdrop_write",
      handlers => ['default'],
      require  => File[$smokey_checker_script],
    }

    sensu::check { 'smoke_test_spotlight_assets':
      interval => 60,
      command  => "${smokey_checker_script} spotlight_assets",
      handlers => ['default'],
      require  => File[$smokey_checker_script],
    }
}
