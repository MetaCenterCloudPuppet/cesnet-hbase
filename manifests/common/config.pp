class hbase::common::config {
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
}
