class hbase::master::install {
  include stdlib

  ensure_packages($hbase::packages['master'])
}
