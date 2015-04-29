class hbase::common::config {
  $realm = $hbase::realm

  file { "${hbase::confdir}/hbase-site.xml":
    owner   => 'root',
    group   => 'root',
    alias   => 'hbase-site.xml',
    content => template('hbase/hbase-site.xml.erb'),
  }

  file { "${hbase::confdir}/regionservers":
    owner   => 'root',
    group   => 'root',
    alias   => 'regionservers',
    content => template('hbase/regionservers.erb'),
  }

  file { "${hbase::confdir}/hbase-env.sh":
    owner   => 'root',
    group   => 'root',
    content => template('hbase/hbase-env.sh.erb'),
  }

  if $hbase::realm and $hbase::realm != '' {
    file { "${hbase::confdir}/zk-jaas.conf":
      owner   => 'root',
      group   => 'root',
      content => template('hbase/zk-jaas.conf.erb'),
    }
  }
}
