# = Class hbase::common::keytab
#
# Keytab file ownership (deamons and frontend may need it).
#
class hbase::common::keytab {
  if $hbase::realm {
    file { '/etc/security/keytab/hbase.service.keytab':
      owner => 'hbase',
      group => 'hbase',
      mode  => '0400',
      alias => 'hbase.service.keytab',
    }
  }
}
