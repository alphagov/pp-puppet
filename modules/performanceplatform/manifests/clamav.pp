# == Synopsis
# This is the main class for configuring Clam Anti-Virus. Fresh clam is in
# its own class. It takes a *lot* of parameters, nearly all of the config
# options. Therefore checking what you pass is nearly impossible. It's up
# to you to not pass empty things and break stuff. Also, not all parameters
# are documented in the parameters portion of this doc. Please refer to the
# official clam docs for explanation. The parameters are downcased versions
# of any config file option.
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
class clamav (
   $algorithmicdetection           = "true",
   $allowsupplementarygroups       = "true",
   $archiveblockencrypted          = "false",
   $bytecode                       = "true",
   $bytecodesecurity               = "TrustSigned",
   $bytecodetimeout                = "60000",
   $clamdebug                      = "false",
   $commandreadtimeout             = "5",
   $crossfilesystems               = "true",
   $databasedirectory              = "/var/lib/clamav",
   $detectbrokenexecutables        = "false",
   $detectpua                      = "false",
   $ensure                         = "present",
   $exitonoom                      = "false",
   $extendeddetectioninfo          = "true",
   $fixstalesocket                 = "true",
   $followdirectorysymlinks        = "false",
   $followfilesymlinks             = "false",
   $foreground                     = "false",
   $heuristicscanprecedence        = "false",
   $idletimeout                    = "30",
   $leavetemporaryfiles            = "false",
   $localsocket                    = "/var/run/clamav/clamd.ctl",
   $localsocketgroup               = "clamav",
   $localsocketmode                = "666",
   $logclean                       = "false",
   $logfacility                    = "LOG_LOCAL6",
   $logfile                        = "/var/log/clamav/clamav.log",
   $logfilemaxsize                 = "0",
   $logfileunlock                  = "false",
   $logsyslog                      = "false",
   $logtime                        = "true",
   $logverbose                     = "false",
   $maxconnectionqueuelength       = "15",
   $maxdirectoryrecursion          = "15",
   $maxqueue                       = "100",
   $maxthreads                     = "12",
   $ole2blockmacros                = "false",
   $officialdatabaseonly           = "false",
   $phishingalwaysblockcloak       = "false",
   $phishingalwaysblocksslmismatch = "false",
   $phishingscanurls               = "true",
   $phishingsignatures             = "true",
   $pidfile                        = "/var/run/clamav/clamd.pid",
   $readtimeout                    = "180",
   $scanarchive                    = "true",
   $scanelf                        = "true",
   $scanhtml                       = "true",
   $scanmail                       = "true",
   $scanole2                       = "true",
   $scanpe                         = "true",
   $scanpartialmessages            = "false",
   $selfcheck                      = "3600",
   $sendbuftimeout                 = "200",
   $streammaxlength                = "25m",
   $structureddatadetection        = "false",
   $user                           = "clamav"
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
      $file_notify   = Service["clamav-daemon"]
      $file_require  = Package["clamav-daemon"]
      $svc_before    = undef
      $svc_enable    = "true"
      $svc_ensure    = "running"
      $svc_require   = Package["clamav-daemon"]
   } else {
      $file_notify   = undef
      $file_require  = undef
      $svc_before    = Package["clamav-daemon"]
      $svc_enable    = "false"
      $svc_ensure    = "stopped"
      $svc_require   = undef
   }

   file {
      "/etc/clamav/clamd.conf":
         content  => template("clamav/clamd.conf.erb"),
         ensure   => $ensure,
         group    => "clamav",
         mode     => "644",
         notify   => $file_notify,
         owner    => "root",
         require  => $file_require;
   }

   package {
      "clamav":
         ensure => $ensure;
      "clamav-daemon":
         ensure => $ensure;
      "libclamav6":
         ensure => $ensure;
      "libclamav-dev":
         ensure => $ensure;
   }

   service {
      "clamav-daemon":
         before    => $svc_before,
         enable    => $svc_enable,
         ensure    => $svc_ensure,
         hasstatus => "true",
         require   => $svc_require;
   }
}

#vim: set expandtab ts=3 sw=3:
