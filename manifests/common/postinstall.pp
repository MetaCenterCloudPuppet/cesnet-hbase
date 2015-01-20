# == Class hbase::common::postinstall
#
# Preparation steps after installation. It switches hbase-conf alternative, if enabled.
#
class hbase::common::postinstall {
  $confname = $hbase::alternatives
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'

  if $confname {
    exec { 'hbase-copy-config':
      command => "cp -a ${hbase::confdir}/ /etc/hbase/conf.${confname}",
      path    => $path,
      creates => "/etc/hbase/conf.${confname}",
    }
    ->
    alternative_entry{"/etc/hbase/conf.${confname}":
      altlink  => '/etc/hbase/conf',
      altname  => 'hbase-conf',
      priority => 50,
    }
    ->
    alternatives{'hbase-conf':
      path => "/etc/hbase/conf.${confname}",
    }
  }
}
