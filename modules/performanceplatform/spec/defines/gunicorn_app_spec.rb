require_relative '../../../../spec_helper'

describe 'performanceplatform::gunicorn_app', :type => :define do
  let(:title) { 'gunicorn-app' }
  let(:hiera_data) {{
    'lumberjack::hosts'          => [],
    'ssl::params::ssl_path'      => 'test.gov.uk',
    'ssl::params::ssl_cert_file' => 'testtest',
    'ssl::params::ssl_key_file'  => 'testest',
  }}
  let(:facts) {{
    :operatingsystem => 'ubuntu',
  }}
  
  context 'is a django app that' do
    let(:params) {{
      'is_django' => true,
    }}
  
    it do
      should contain_nginx__vhost__proxy('gunicorn-app-vhost').with(
        'proxy_set_forwarded_host' => true,
        'proxy_append_forwarded_host' => false,
      )
    end

  end

  context 'is a non-django app that' do
    let(:params) {{
      'is_django' => false,
    }}
    it do
      should contain_nginx__vhost__proxy('gunicorn-app-vhost').with(
        'proxy_set_forwarded_host' => false,
        'proxy_append_forwarded_host' => true,
      )
    end
  end
end
