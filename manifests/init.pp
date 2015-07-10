# == Class: hbase
#
# HBase Cluster setup.
#
# Installation notes:
#
# 1) Hadoop cluser needs to be already completely deployed (HDFS namenode and datanodes)
#
# 2) hbase class needs to be launch also on HDFS namenode,
#    if not:
#  - create hbase user on Hadoop HDFS Name Node (or install HBase)
#  - create /hbase HDFS directory:
#      hdfs dfs -mkdir /hbase
#      hdfs dfs -chown hbase:hbase /hbase
#
# 3) if enabled https in Hadoop, hbase needs access to http secret file and Kerberos keyfile ==> enable https also in hbase
#
# Web UI: ports 60010, 60030, https is not supported
#
# Any changes will be done only on these hostnames:
# * master_hostname
# * zookeeper_hostnames (if external_zookeeper is false)
# * slaves
# * frontends
# * (hdfs_hostname: only 'kinit' and 'hdfs dfs' commands)
#
# === Parameters
#
# ####`hdfs_hostname` (required)
#   Main node of Hadoop (HDFS Name Node). Used for launching 'hdfs dfs' commands there.
#
# ####`master_hostname` undef
#   HBase master node.
#
# ####`rest_hostnames` undef
#
#  Rest Server hostnames (used only for the helper admin script).
#
# ####`thrift_hostnames` undef
#
#  Thrift Server hostnames (used only for the helper admin script).
#
# ####`zookeeper_hostnames` (required)
#   Zookeepers to use. May be ["localhost"] in non-cluster mode.
#
# ####`external_zookeeper` true
#   Don't launch HBase Zookeeper.
#
# ####`slaves` []
#   HBase regionserver nodes.
#
# ####`frontends` []
#   Array of frontend hostnames. Package and configuration is needed on frontends.
#
# ####`realm` (required)
#   Kerberos realm, or empty string to disable security.
#   To enable security, there are required:
#
#   * configured Kerberos (/etc/krb5.conf, /etc/krb5.keytab)
#   * /etc/security/keytab/hbase.service.keytab
#   * enabled security on HDFS
#   * enabled security on zookeeper, if external
#
# ####`properties`
#
# ####`descriptions`
#
# ####`features` ()
#   * restarts
#   * hbmanager
#
# ####`acl` undef
#
#   Set to true, if setfacl command is available and /etc/hadoop is on filesystem supporting POSIX ACL.
#   It is used to set privileges of ssl-server.xml for HBase. If the POSIX ACL is not supported, disable this parameter also in cesnet-hadoop puppet module.
#
# ####`alternatives` 'cluster'
#
# ####`group` 'users'
#
# User groups (used for REST server and Thrift server impersonation).
#
# ####`https` undef
#   Enable https support. It needs to be set when Hadoop cluster has https enabled.
#
# * **true**: enable https
# * **hdfs**: enable https only for Hadoop, keep HBase https disabled
# * **false**: disable https
#
# ####`https_keystore` '/etc/security/server.keystore'
#
# Certificates keystore file (for thrift server).
#
# ####`https_keystore_password` 'changeit'
#
# Certificates keystore file password (for thrift server).
#
# ####`https_keystore_keypassword` undef
#
# Certificates keystore key password (for thrift server). If not specified, *https\_keystore\_password* is used.
#
class hbase (
  $package_name = $hbase::params::package_name,
  $service_name = $hbase::params::service_name,

  $hdfs_hostname,
  $master_hostname = undef,
  $rest_hostnames = undef,
  $thrift_hostnames = undef,
  $zookeeper_hostnames,
  $external_zookeeper = $hbase::params::external_zookeeper,
  $slaves = [],
  $frontends = [],
  $realm,
  $properties = undef,
  $descriptions = undef,
  $features = {},
  $acl = undef,
  $alternatives = $params::alternatives,
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
  $all_descriptions = {
    'hbase.security.authentication' => 'simple, kerberos',
    'hbase.coprocessor.region.classes' =>  'for enabling full security and ACLs',
    'hbase.rpc.protection' => 'auth-conf, private (10% performance penalty)',
  }

  $_properties = merge($hbase::params::properties, $sec_properties, $https_properties, $properties)
  $_descriptions = merge($hbase::params::descriptions, $all_descriptions, $descriptions)

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
