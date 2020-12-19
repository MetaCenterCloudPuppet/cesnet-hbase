# = Class hbase::master::config
#
# Installs HBase master.
#
class hbase::master::install {
  include stdlib
  contain hbase::common::postinstall

  ensure_packages($hbase::packages['master'])
  Package[$hbase::packages['master']] -> Class['hbase::common::postinstall']

  # workaround troubles with premature startup on Debian
  $daemon = $::hbase::daemons['master']
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'
  case $::osfamily {
    'debian': {
      exec {"debian-workaround-${daemon}":
        command => "echo '#! /bin/sh' > /etc/init.d/${daemon} && chmod +x /etc/init.d/${daemon}",
        path    => $path,
        creates => "/etc/init.d/${daemon}",
      }
      ->
      Package[$hbase::packages['master']]
      ->
      exec{"debian-restore-${daemon}":
        command => "mv -v /etc/init.d/${daemon}.dpkg-dist /etc/init.d/${daemon}",
        path    => $path,
        onlyif  => "test -f /etc/init.d/${daemon}.dpkg-dist",
      }
    }
    default: {}
  }
}
