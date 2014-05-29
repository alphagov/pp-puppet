class performanceplatform::pypi (
  $test_username="foo",
  $test_password="foo",
  $live_username="foo",
  $live_password="foo",
) {
    $pipyirc_file = "/home/jenkins/.pipyirc"

    file { $pipyirc_file:
      ensure => present,
      owner  => 'jenkins',
      group  => 'jenkins',
      mode   => '0644',
      source => "puppet:///modules/performanceplatform/pp-dev-pypirc.erb"
    }

}
