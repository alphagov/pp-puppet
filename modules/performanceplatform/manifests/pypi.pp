class performanceplatform::pypi (
  $test_username,
  $test_password,
  $live_username,
  $live_password,
) {
    $pypirc_file = "/var/lib/jenkins/.pypirc"

    file { $pypirc_file:
      ensure => present,
      owner  => 'jenkins',
      group  => 'jenkins',
      mode   => '0644',
      content => template('performanceplatform/pp-dev-pypirc.erb'),
      require => Class['performanceplatform::jenkins']
    }
}
