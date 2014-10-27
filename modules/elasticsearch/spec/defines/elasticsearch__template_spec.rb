require 'spec_helper'

describe 'elasticsearch::template', :type => :define do
  content = '{"template": "bazinga"}'
  let(:title) { 'bubbles' }
  let(:params) {{
    :content => content
  }}

  context "ensure present" do
    it do
      should contain_exec('create-elasticsearch-template-bubbles').
        with_command("es-template create 'bubbles' <<EOS\n#{content}\nEOS").
        with_unless("es-template compare 'bubbles' <<EOS\n#{content}\nEOS").
        with_tries('3').
        with_try_sleep('30').
        with_provider('shell')
    end
  end

  context "ensure absent" do
    let(:params) {{
      :content => content,
      :ensure  => 'absent'
    }}
    it do
      should contain_exec('delete-elasticsearch-template-bubbles').
        with_command("es-template delete 'bubbles'").
        with_onlyif("es-template get 'bubbles'")
    end
  end

end
