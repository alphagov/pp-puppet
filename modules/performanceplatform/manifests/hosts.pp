# == Class: performanceplatform::hosts
#
# Manage standard /etc/hosts entries:
#
# - IPv4 loopback.
# - IPv6 lookback and multicast.
#
class performanceplatform::hosts (
  $ip = $::ipaddress,
) {
  resources { 'host':
    purge => true,
  }

  host { $::fqdn:
    ensure        => present,
    ip            => $ip,
    host_aliases  => $::hostname,
  }

  host {
    'localhost':
      ensure        => present,
      ip            => '127.0.0.1';
    'ip6-localhost':
      ensure        => present,
      ip            => '::1',
      host_aliases  => 'ip6-loopback';
    'ip6-localnet':
      ensure        => present,
      ip            => 'fe00::0';
    'ip6-mcastprefix':
      ensure        => present,
      ip            => 'ff00::0';
    'ip6-allnodes':
      ensure        => present,
      ip            => 'ff02::1';
    'ip6-allrouters':
      ensure        => present,
      ip            => 'ff02::2';
  }
}
