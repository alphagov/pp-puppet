class performanceplatform::elasticsearch(
  $data_directory,
) {

  class { '::elasticsearch':
    data_directory => '/mnt/data/elasticsearch',
  }

  cron {'elasticsearch-rotate-indices':
    ensure  => present,
    user    => 'nobody',
    hour    => '0',
    minute  => '1',
    command => '/usr/local/bin/es-rotate --delete-old --delete-maxage 21 --optimize-old --optimize-maxage 1 logs',
    require => Class['::elasticsearch'],
  }

  elasticsearch::plugin { 'head':
    install_from => 'mobz/elasticsearch-head',
  }

}
