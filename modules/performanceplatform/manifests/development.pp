class performanceplatform::development (
  $stagecraft_password
) {
  file { '/home/vagrant/.bash_profile':
    ensure  => file,
    replace => false,
    owner   => 'vagrant',
    group   => 'vagrant',
    source  => 'puppet:///modules/performanceplatform/home/vagrant/.bash_profile',
  }

  postgresql::server::role { 'stagecraft':
    createdb      => true,
    password_hash => postgresql_password('stagecraft', $stagecraft_password),
  }

  # ensure that we don't run out of file handles when running all the apps
  harden::limit { 'vagrant-nofile':
    domain => 'vagrant',
    type   => '-', # set both hard and soft limits
    item   => 'nofile',
    value  => '16384',
  }

  performanceplatform::development::environment { 'stagecraft':
    postactivate      => 'export DJANGO_SETTINGS_MODULE=development',
    requirements_path => 'requirements/development.txt'
  }


  performanceplatform::development::environment { 'performanceplatform-admin':
    postactivate =>  'export OAUTHLIB_INSECURE_TRANSPORT=1'
  }

}
