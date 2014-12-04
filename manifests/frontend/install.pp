class hbase::frontend {
  include stdlib

  ensure_packages($hbase::packages['frontend'])
}
