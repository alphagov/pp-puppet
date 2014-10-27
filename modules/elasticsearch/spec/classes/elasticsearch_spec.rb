require 'spec_helper'

describe 'elasticsearch', :type => :class do
  let(:facts) { { :osfamily => "Debian"} }
  let(:params) do
    { :cluster_name => 'foocluster' }
  end
  home = '/var/lib/elasticsearch-foocluster'

  it do
    should contain_package('elasticsearch')
    should contain_file(home).with_ensure('directory')
    should contain_service('elasticsearch-foocluster').
      with_ensure('running')

    should contain_file("#{home}/config/logging.yml")

    should contain_file("#{home}/config/elasticsearch.yml").
      with_content(/^\s*cluster.name: foocluster/).
      with_content(/multicast.enabled: false/).
      with_content(/mlockall: false/).
      with_content(/unicast.hosts: \["localhost"\]/)

    should contain_file("/etc/init/elasticsearch-foocluster.conf").
      with_content(/ES_HOME="#{home}"/).
      with_content(/ES_HEAP_SIZE="512m"/)
  end

  context "with a list of cluster_hosts" do
    let(:params) do
      {
        :cluster_name => 'foocluster',
        :cluster_hosts => ['one', 'two', 'three'],
        :host => 'one'
      }
    end

    it do
      should contain_file("#{home}/config/elasticsearch.yml").
        with_content(/unicast.hosts: \["one", "two", "three"\]/).
        with_content(/network\.publish_host: one/)
    end
  end

  context "with mlock_all set to true" do
    let(:params) do
      {
        :cluster_name => 'foocluster',
        :mlock_all => true,
      }
    end

    it do
      should contain_file("#{home}/config/elasticsearch.yml").
        with_content(/mlockall: true/)
    end
  end

  context "with heap_size set to '4g'" do
    let(:params) do
      {
        :cluster_name => 'foocluster',
        :heap_size => '4g'
      }
    end

    it do
      should contain_file("/etc/init/elasticsearch-foocluster.conf").
        with_content(/ES_HEAP_SIZE="4g"/)
    end
  end

  context "with custom data dir" do
    let(:params) do
      {
        :data_directory => '/mnt/data/elasticsearch',
      }
    end

    it do
      should contain_file("/mnt/data/elasticsearch").
        with_ensure('directory')
    end
  end

end
