# == Synopsis
# This is for configuring freshclam, the piece of ClamAV that keeps the virus
# definitions up to date. Note that like the main clamav class, this class
# takes nearly all the config options as parameters. They are downcased. So
# please refer to the freshclam docs to find out about what each parameter
# actually does. This also means the parameters section of this doc only has
# ensure in it.
#
# == Notes
# Only one parameter differs from its lowercase config name; the debug option
# in freshclam is called clamdebug here, because it is a puppet metaparameter
# and won't parse properly in the config file.
#
# == Parameters
#
# [*ensure*]
#  Use this to specify whether the class' resources should be applied or
#  removed.
#
# == Examples
#
#   class {
#      "clamav":
#         ensure => "present";
#   }
#
# == Authors
#
# Joe McDonagh <jmcdonagh@thesilentpenguin.com>
#
# == Copyright
#
# Copyright 2012 The Silent Penguin LLC
#
# == License
# Licensed under The Silent Penguin Properietary License
#
class clamav::freshclam (
   $allowsupplementarygroups  = "false",
   $bytecode                  = "true",
   $checks                    = "24",
   $clamdebug                 = "false",
   $compresslocaldatabase     = "no",
   $connecttimeout            = "30",
   $dnsdatabaseinfo           = "current.cvd.clamav.net",
   $databasedirectory         = "/var/lib/clamav",
   $databasemirror            = "database.clamav.net",
   $databasemirror            = "db.local.clamav.net",
   $databaseowner             = "clamav",
   $ensure                    = "present",
   $foreground                = "false",
   $logfacility               = "LOG_LOCAL6",
   $logfilemaxsize            = "0",
   $logsyslog                 = "false",
   $logtime                   = "true",
   $logverbose                = "false",
   $maxattempts               = "5",
   $pidfile                   = "/var/run/clamav/freshclam.pid",
   $receivetimeout            = "30",
   $scriptedupdates           = "yes",
   $testdatabases             = "yes",
   $updatelogfile             = "/var/log/clamav/freshclam.log"
) {
   # Parameter Validation
   $supported_minimum_os_versions   = { "Ubuntu" => 10.04 }
   $supported_operatingsystems      = [ "Ubuntu" ]
   $valid_ensure_values             = [ "present", "absent" ]

   if ! ($::operatingsystem in $supported_operatingsystems) {
      fail "Your OS ($::operatingsystem) is not supported by this code!"
   }

   if ($::operatingsystemrelease < $supported_minimum_os_versions[$::operatingsystem] ) {
      fail "You need at least version $supported_minimum_os_versions[$::operatingsystem] to use this code."
   }

   if ! ($ensure in $valid_ensure_values) {
      fail "Invalid ensure value for clamav, valid values are $valid_ensure_values"
   }

   if ($ensure == "present") {
      $file_notify   = Service["clamav-freshclam"]
      $file_require  = Package["clamav-freshclam"]
      $svc_before    = undef
      $svc_enable    = "true"
      $svc_ensure    = "running"
      $svc_require   = Package["clamav-freshclam"]
   } else {
      $file_notify   = undef
      $file_require  = undef
      $svc_before    = Package["clamav-freshclam"]
      $svc_enable    = "false"
      $svc_ensure    = "stopped"
      $svc_require   = undef
   }

   file {
      "/etc/clamav/freshclam.conf":
         content  => template("clamav/freshclam.conf.erb"),
         ensure   => $ensure,
         group    => "clamav",
         mode     => "640",
         notify   => $file_notify,
         owner    => "root",
         require  => $file_require;
   }

   package {
      "clamav-freshclam":
         ensure => $ensure;
   }

   service {
      "clamav-freshclam":
         before    => $svc_before,
         enable    => $svc_enable,
         ensure    => $svc_ensure,
         hasstatus => "true",
         require   => $svc_require;
   }
}

#vim: set expandtab ts=3 sw=3:
