class pp_postgres::server {
  include('postgresql::server')

  apt::pin { 'apt.postgresql.org':
    originator => 'apt.postgresql.org',
    priority   => 500,
  }->
  apt::source { 'apt.postgresql.org':
    location          => 'http://apt.postgresql.org/pub/repos/apt/',
    release           => "${::lsbdistcodename}-pgdg",
    repos             => "main ${::postgresql::globals::version}",
    key               => 'ACCC4CF8',
    key_source        => 'http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc',
    include_src       => false,
  }

  Apt::Source['apt.postgresql.org']->Package<|tag == 'postgresql'|>
}
