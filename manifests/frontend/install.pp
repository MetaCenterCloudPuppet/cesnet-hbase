class hbase::frontend::install {
  include stdlib

  ensure_packages($hbase::packages['frontend'])
}
