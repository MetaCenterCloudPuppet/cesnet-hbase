class hbase::regionserver::install {
  include stdlib

  ensure_packages($hbase::packages['regionserver'])
}
