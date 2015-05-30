require 'spec_helper'

describe 'hbase::restserver::config', :type => 'class' do
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

describe 'hbase::restserver', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('hbase::restserver::install') }
      it { should contain_class('hbase::restserver::config') }
      it { should contain_class('hbase::restserver::service') }
    end
  end
end
