$realm = ''

class{'hadoop':
  realm => $realm,
}

class{'hbase':
  hdfs_hostname       => $::fqdn,
  realm               => $realm,
  zookeeper_hostnames => [$::fqdn],
}
