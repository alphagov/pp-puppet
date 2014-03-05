class stagecraft::assets() {
  file { ["/opt/stagecraft",
          "/opt/stagecraft/releases",
          "/opt/stagecraft/shared",
          "/opt/stagecraft/shared/log"]:
    ensure => directory,
    user   => 'deploy'
  }
}
