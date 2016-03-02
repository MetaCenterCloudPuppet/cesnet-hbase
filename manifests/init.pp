# == Class: hbase
#
# HBase Cluster setup.
#
class hbase (
  $hdfs_hostname,
  $master_hostname = undef,
  $backup_hostnames = undef,
  $rest_hostnames = undef,
  $thrift_hostnames = undef,
  $zookeeper_hostnames,
  $external_zookeeper = $hbase::params::external_zookeeper,
  $slaves = [],
  $frontends = [],
  $realm = '',
  $properties = undef,
  $descriptions = undef,
  $features = {},
  $acl = undef,
  $alternatives = '::default',
  $group = 'users',
  $https = undef,
  $https_keystore = '/etc/security/server.keystore',
  $https_keystore_password = 'changeit',
  $https_keystore_keypassword = undef,
  $perform = $hbase::params::perform,
) inherits hbase::params {
  include stdlib

  if $hbase::realm and $hbase::realm != '' {
    $sec_properties = {
      'hadoop.security.authorization' => true,
      'hadoop.proxyuser.hbase.groups' => $hbase::group,
      'hadoop.proxyuser.hbase.hosts'  => '*',
      'hbase.security.authentication' => 'kerberos',
      'hbase.master.keytab.file' => '/etc/security/keytab/hbase.service.keytab',
      'hbase.master.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
      'hbase.regionserver.keytab.file' => '/etc/security/keytab/hbase.service.keytab',
      'hbase.regionserver.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
      'hbase.security.authorization' => true,
      'hbase.coprocessor.master.classes' => 'org.apache.hadoop.hbase.security.access.AccessController',
      'hbase.coprocessor.region.classes' => 'org.apache.hadoop.hbase.security.token.TokenProvider,org.apache.hadoop.hbase.security.access.AccessController',
      'hbase.security.exec.permissions.checks' => true,
      'hbase.rest.authentication.type' => 'kerberos',
      'hbase.rest.authentication.kerberos.principal' => "HTTP/_HOST@${hbase::realm}",
      'hbase.rest.authentication.kerberos.keytab' => "${hbase::hbase_homedir}/hadoop.keytab",
      'hbase.rest.keytab.file' => '/etc/security/keytab/hbase.service.keytab',
      'hbase.rest.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
      'hbase.rpc.protection' => 'auth-conf',
      'hbase.rpc.engine' => 'org.apache.hadoop.hbase.ipc.SecureRpcEngine',
      'hbase.thrift.keytab.file' => '/etc/security/keytab/hbase.service.keytab',
      'hbase.thrift.kerberos.principal' => "hbase/_HOST@${hbase::realm}",
    }
  }
  if $hbase::https and $hbase::https != 'hdfs' {
    if $https_keystore_keypassword {
      $keypass = $https_keystore_keypassword
    } else {
      $keypass = $https_keystore_password
    }
    $https_properties = {
      'hadoop.ssl.enabled' => true,
      'hbase.thrift.ssl.enabled' => true,
      'hbase.thrift.ssl.keystore.store' => $https_keystore,
      'hbase.thrift.ssl.keystore.password' => $https_keystore_password,
      'hbase.thrift.ssl.keystore.keypassword' => $keypass,
    }
  }
  if $hbase::external_zookeeper {
    $zoo_properties = {}
  } else {
    $zoo_properties = {
      'hbase.zookeeper.property.clientPort' => 2181,
      'hbase.zookeeper.property.dataDir' => '/var/lib/hbase/zookeeper',
    }
  }

  $_properties = merge($hbase::params::properties, $sec_properties, $https_properties, $zoo_properties, $properties)
  $_descriptions = merge($hbase::params::descriptions, $descriptions)

  if ($hbase::perform) {
    include hbase::install
    include hbase::config
    include hbase::service

    Class['hbase::install'] ->
    Class['hbase::config'] ~>
    Class['hbase::service'] ->
    Class['hbase']
  }
}
