require 'spec_helper'

describe 'hbase::regionserver::config', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']
    path = $test_config_dir[os]

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_file(path + '/hbase-site.xml') }
    end
  end
end

describe 'hbase::regionserver', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('hbase::regionserver::install') }
      it { should contain_class('hbase::regionserver::config') }
      it { should contain_class('hbase::regionserver::service') }
    end
  end
end
