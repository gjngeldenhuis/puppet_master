# == Class: puppet_master::console
#
# Module to manage certificate authorisation for the Console.
# Collects all puppet_master::console::whitelist_entry instances.
#
# === Parameters
#
# Defaults in puppet_master::params
#
# [*all_in_one*]
#   Boolean value to determine if the node is an all-in-one installation or split
#   Default is true.
#
# [*default_whitelist*]
#   An array of the default entries in the whitelist
#   Default is [::fqdn, 'pe-internal-dashbaord']
#
# === Examples
#
#  class { puppet_master::console:
#     default_whitelist => [$::fqdn, 'pe-internal-dashbaord'],
#     all_in_one        => true,
#  }
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.vm>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class puppet_master::console (
  $all_in_one        = $puppet_master::console::all_in_one,
  $default_whitelist = $puppet_master::console::default_whitelist,
) {

  if ! defined(Class['puppet_master::httpd']) {
    class { 'puppet_master::httpd':
     ca_enabled     => true,
     manage_console => false,
    }
  }

  $role = 'read-write'

  concat { '/etc/puppetlabs/console-auth/certificate_authorization.yml':
    owner          => 'pe-auth',
    group          => 'puppet-dashboard',
    mode           => '0640',
    ensure_newline => false,
    notify         => Service['pe-httpd'],
  }

  concat::fragment { 'top':
    target  => '/etc/puppetlabs/console-auth/certificate_authorization.yml',
    content => "---\n",
    order   => '01',
  }

  if $all_in_one == false {
    concat::fragment { $::fqdn:
      target  => '/etc/puppetlabs/console-auth/certificate_authorization.yml',
      content => "${::fqdn}:\n  role: read-write\n",
      order   => '02',
    }
  }

  concat::fragment { 'pe-internal-dashbaord':
    target  => '/etc/puppetlabs/console-auth/certificate_authorization.yml',
    content => "pe-internal-dashbaord:\n  role: read-write\n",
    order   => '02',
  }

  Puppet_master::Console::Whitelist_entry <<| |>>

}
