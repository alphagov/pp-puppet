require_relative '../../../../spec_helper'

describe 'performanceplatform::mount', :type => :define do
    let(:title) { '/mnt/data/myapppp' }


    let(:params) do
        {
            :mountoptions => 'flip',
            :disk => 'plob',
        }
    end

    context 'when running in development' do
        let(:facts) do
            {
                :pp_environment => 'dev',
            }
        end

        it { should_not contain_ext4mount(title) }
        it { should contain_file(title).with_ensure('directory') }

    end

    context 'when not running in development' do
        let(:facts) do
            {
                :pp_environment => 'production',
            }
        end

        it { should contain_ext4mount(title).with({
                :mountoptions => 'defaults',
                :disk         => params[:disk],
            })
        }

    end

end


