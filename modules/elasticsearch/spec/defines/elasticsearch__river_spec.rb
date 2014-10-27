require 'spec_helper'

describe 'elasticsearch::river', :type => :define do
  content = '{"type": "bazinga"}'
  let(:title) { 'mississippi' }
  let(:params) {{
    :content => content
  }}

  context "ensure present" do
    it do
      should contain_exec('create-elasticsearch-river-mississippi').
        with_command("es-river create 'mississippi' <<EOS\n#{content}\nEOS").
        with_unless("es-river compare 'mississippi' <<EOS\n#{content}\nEOS").
        with_provider('shell')
    end
  end

  context "ensure absent" do
    let(:params) {{
      :content => content,
      :ensure  => 'absent'
    }}
    it do
      should contain_exec('delete-elasticsearch-river-mississippi').
        with_command("es-river delete 'mississippi'").
        with_onlyif("es-river get 'mississippi'")
    end
  end

end
