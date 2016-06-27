node 'master.icingacampams.vm' {
  include role::puppet::master
}

node 'icinga2.icingacampams.vm' {
  include role::monitoring::standalone
}

node 'peclient.icingacampams.vm' {
  include role::testclient
}
