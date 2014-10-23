require 'spec_helper_system'

describe 'basic tests' do
  it 'class should work without errors' do
    pp = <<-EOS
      ensure_packages(['python-software-properties', 'openjdk-6-jdk'])
      $sources_list_file = "/etc/apt/sources.list.d/gds-govuk-precise.list"

      exec { "/usr/bin/add-apt-repository ppa:gds/govuk":
        creates => $sources_list_file,
        before  => File[$sources_list_file],
        require => Package['python-software-properties']
      }

      file { $sources_list_file:
        ensure => present,
      }

      exec { 'apt-get-update':
        command => '/usr/bin/apt-get update',
        require => File[$sources_list_file],
      }

      class { 'elasticsearch':
        require => [File[$sources_list_file], Exec['apt-get-update']],
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
    end
  end
end
