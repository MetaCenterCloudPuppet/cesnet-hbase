class hbase::common::config {
  file { '/etc/hbase/hbase-site.xml':
    owner   => 'root',
    group   => 'root',
    alias   => 'hbase-site.xml',
    content => template('hbase/hbase-site.xml.erb'),
  }

  file { '/etc/hbase/regionservers':
    owner   => 'root',
    group   => 'root',
    alias   => 'regionservers',
    content => template('hbase/regionservers.erb'),
  }
}
