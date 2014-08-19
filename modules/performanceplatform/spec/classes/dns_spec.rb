require_relative '../../../../spec_helper'

describe 'performanceplatform::dns', :type => :class do

  let (:params) {{
    'hosts'     => "5.6.7.8 box-1\n5.4.3.2 box-2",
    'env_hosts' => "1.2.3.4 domain.com",
  }}

  it { should contain_file('/etc/hosts.dns').with_content("5.6.7.8 box-1\n5.4.3.2 box-2\n1.2.3.4 domain.com") }

end
