class profile::icinga::client {

  include ::icinga2

  include ::icinga2::feature::command

  # class { '::icinga2::feature::api':
  #   accept_commands => true,
  #   accept_config   => true,
  # }

  # icinga2::pki::puppet class needs to be declared
  # after the icinga2::feature::api class in order
  # to avoid resource duplication
  contain ::icinga2::pki::puppet

}
