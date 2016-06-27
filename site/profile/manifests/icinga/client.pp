class profile::icinga::client {

  $icinga2_web_fqdn = hiera('icingaweb::fqdn')

  include ::icinga2
  include ::icinga2::feature::command

  class { '::icinga2::feature::api':
    accept_commands => true,
    accept_config   => true,
    manage_zone     => false,
  }

  # icinga2::pki::puppet class needs to be declared
  # after the icinga2::feature::api class in order
  # to avoid resource duplication
  contain ::icinga2::pki::puppet

  @@icinga2::object::zone { $::fqdn:
    endpoints => {
      $::fqdn => {
        host => $::fqdn,
      },
    },
    parent    => 'master',
  }

  icinga2::object::zone { 'master':
    endpoints => {
      $icinga2_web_fqdn => {
        host => $icinga2_web_fqdn,
      },
    },
  }

  Icinga2::Object::Zone <<| |>>

}
