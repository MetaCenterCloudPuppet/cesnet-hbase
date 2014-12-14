# == Class hbase::common::postinstall
#
# Preparation steps after installation. It switches hbase-conf alternative, if enabled.
#
class hbase::common::postinstall {
  $confname = $hbase::alternatives
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'
  $altcmd = $::osfamily ? {
    'Debian' => 'update-alternatives',
    'RedHat' => 'alternatives',
  }

  if $confname {
    exec { 'hbase-copy-config':
      command => "cp -a ${hbase::confdir}/ /etc/hbase/conf.${confname}",
      path    => $path,
      creates => "/etc/hbase/conf.${confname}",
    }
    ->
    exec { 'hbase-install-alternatives':
      command     => "${altcmd} --install /etc/hbase/conf hbase-conf /etc/hbase/conf.${confname} 50",
      path        => $path,
      refreshonly => true,
      subscribe   => Exec['hbase-copy-config'],
    }
    ->
    exec { 'hbase-set-alternatives':
      command     => "${altcmd} --set hbase-conf /etc/hbase/conf.${confname}",
      path        => $path,
      refreshonly => true,
      subscribe   => Exec['hbase-copy-config'],
    }
  }
}
