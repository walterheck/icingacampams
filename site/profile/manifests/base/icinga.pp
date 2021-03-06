class profile::base::icinga {

  # resource default
  Icinga2::Object::Host {
    display_name    => $::fqdn,
    check_command   => 'cluster-zone',
    target_dir      => '/etc/icinga2/objects/hosts',
    target_file_name=> "${::fqdn}.conf",
  }

  @@icinga2::object::host { $::fqdn:
    ipv4_address => $::ipaddress_enp0s8,
    vars         => {
      os              => 'Linux',
      remote          => true,
      remote_endpoint => $::fqdn
    },
  }

}
