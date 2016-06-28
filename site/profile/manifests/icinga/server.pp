class profile::icinga::server {

  $icinga2_db_ipaddress = hiera('icinga::mysql_ipaddress')
  $icinga2_web_fqdn = hiera('icingaweb::fqdn')
  $icinga2_ido_password = hiera('icinga::ido_password')

  class { 'icinga2':
    db_type         => 'mysql',
    db_host         => $icinga2_db_ipaddress,
    db_port         => '3306',
    db_name         => 'icinga2_data',
    db_user         => 'icinga2',
    db_pass         => $icinga2_ido_password,
    manage_database => true,
  }

  include ::icinga2::feature::command

  class { '::icinga2::feature::api':
    manage_zone => false,
  }

  # icinga2::pki::puppet class needs to be declared
  # after the icinga2::feature::api class in order
  # to avoid resource duplication
  contain ::icinga2::pki::puppet

  Icinga2::Object::Host <<| |>>
  Icinga2::Object::Endpoint <<| |>>
  Icinga2::Object::Service <<| |>>

}
