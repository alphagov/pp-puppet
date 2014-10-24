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
) {
  package { $package_name:
    ensure => $ensure,
  }
}
