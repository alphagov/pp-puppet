# == Class: java
#
# This class provides a JDK

# === Parameters
#
# [*ensure*]
#   Standard puppet ensure variable to control the package installation
#
# [*package_name*]
#   The name of the package providing Java. We are expecting to use an
#   OpenJDK package provided by a distro, or Azul OpenJDK package from
#   their apt repo
class java (
  $ensure = installed,
  $package_name = 'zulu-8',
  $download_url = '',
) {
  case $package_name {

    'oracle-java7-installer': {
      $download_dir= '/var/cache/oracle-jdk7-installer'
      file {$download_dir:
        ensure => directory,
      }

      exec { 'download-oracle-java7':
        command => "/usr/bin/curl -o jdk-7u9-linux-x64.tar.gz ${download_url}",
        cwd     => '/var/cache/oracle-jdk7-installer',
        require => [Package['curl'], File[$download_dir]],
        timeout => 3600,
        unless  => '/usr/bin/test "`shasum -a 256 jdk-7u9-linux-x64.tar.gz`" = "1b39fe2a3a45b29ce89e10e59be9fbb671fb86c13402e29593ed83e0b419c8d7  jdk-7u9-linux-x64.tar.gz"',
      }
      notify{"command => /usr/bin/curl -o jdk-7u9-linux-x64.tar.gz ${download_url}":}
      exec {
        'set-licence-selected':
          command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';
        'set-licence-seen':
          command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
      }

      package { 'oracle-java7-installer':
        ensure  => present,
        require => [
          Exec['set-licence-selected'],
          Exec['set-licence-seen'],
          Exec['download-oracle-java7']
        ],
      }
    }
    default: {
      package { $package_name:
        ensure => $ensure,
      }
    }
  }
}
