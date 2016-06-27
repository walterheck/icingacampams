class profile::base::yum {
  include epel

  # get repos from hiera and create them
  $repositories = hiera_hash('profile::base::yum::repositories', undef)
  if $repositories {
    create_resources('yumrepo', $repositories)
  }

}
