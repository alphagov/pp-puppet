require_relative '../../../../spec_helper'

describe 'performanceplatform::proxy_vhost', :type => :define do

    let(:title) { 'www-vhost' }

    context 'defaults' do
        let (:params) {{
            'servername'    => 'www.performance.service.gov.uk',
        }}

        it do
            should contain_nginx__resource__vhost('www.performance.service.gov.uk').with( {
                'proxy_set_header' => [
                    "X-Forwarded-Server $host",
                    "X-Forwarded-Host  $host",
                    "Host $host",
                ],
            })
        end
    end

    context 'with request_uuid => not-a-boolean' do
        let (:params) {{
            'servername'    => 'www.performance.service.gov.uk',
            'request_uuid'  => 'not-a-boolean',
        }}

        it do
            expect {
                should contain_nginx__resource__vhost('www.performance.service.gov.uk')
            }.to raise_error(Puppet::Error, /is not a boolean/)
        end
    end

    context 'with request_uuid' do
        let (:params) {{
            'servername'    => 'www.performance.service.gov.uk',
            'request_uuid'  => true,
        }}

        it do
            should contain_nginx__resource__vhost('www.performance.service.gov.uk').with( {
                'proxy_set_header' => [
                    "X-Forwarded-Server $host",
                    "X-Forwarded-Host  $host",
                    "Host $host",
                    "Request-Id $request_uuid",
                ],
            })
        end
    end

end
