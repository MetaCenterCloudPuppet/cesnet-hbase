# == Class hbase::user
#
# Create HBase system user, if needed. The hbase user is required on the all HDFS namenodes to autorization work properly and we don't need to install HBAse just for the user.
#
# It is better to handle creating the user by the packages, so we recommend dependecny on installation classes or HBase packages.
#
class hbase::user {
  group { 'hbase':
    ensure => present,
    system => true,
  }
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      user { 'hbase':
        ensure     => present,
        system     => true,
        comment    => 'Apache HBase',
        gid        => 'hbase',
        home       => '/var/lib/hbase',
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    /Debian|RedHat/: {
      user { 'hbase':
        ensure     => present,
        system     => true,
        comment    => 'HBase User',
        gid        => 'hbase',
        home       => '/var/lib/hbase',
        managehome => true,
        password   => '!!',
        shell      => '/bin/false',
      }
    }
    default: {
      notice("${::osfamily} not supported")
    }
  }
  Group['hbase'] -> User['hbase']
}
