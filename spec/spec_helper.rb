require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

$test_os=[{
    'osfamily' => 'RedHat',
    'operatingsystem' => 'CentOS',
    'operatingsystemrelease' => ['6']
  }, {
    'osfamily' => 'Debian',
    'operatingsystem' => 'Debian',
    'operatingsystemrelease' => ['7']
  }, {
    'osfamily' => 'RedHat',
    'operatingsystem' => 'Fedora',
    'operatingsystemrelease' => ['21']
  }, {
    'osfamily' => 'RedHat',
    'operatingsystem' => 'RedHat',
    'operatingsystemrelease' => ['6']
  }, {
    'osfamily' => 'Debian',
    'operatingsystem' => 'Ubuntu',
    'operatingsystemrelease' => ['14.04']
  }]

$test_config_dir={
  'CentOS' => '/etc/hbase/conf',
  'Debian' => '/etc/hbase/conf',
  'Fedora' => '/etc/hbase',
  'RedHat' => '/etc/hbase/conf',
  'Ubuntu' => '/etc/hbase/conf',
}
