#----------------------------------------------------------------------------
#  Copyright (c) 2016 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------
#
# Manages system configuration
class wso2base::system {

  $packages               = $wso2base::packages
  $wso2_group             = $wso2base::wso2_group
  $wso2_user              = $wso2base::wso2_user
  $vm_type                = $wso2base::vm_type
  $service_name           = $wso2base::service_name
  $service_template       = $wso2base::service_template
  $hosts_mapping          = $wso2base::hosts_mapping
  $java_prefs_system_root = $wso2base::java_prefs_system_root
  $java_prefs_user_root   = $wso2base::java_prefs_user_root

  # Install system packages
  package { $packages:
    ensure => installed
  }

  group { $wso2_group:
    ensure => 'present',
    gid    => '502',
  }

  user { $wso2_user:
    ensure     => present,
    password   => $wso2_user,
    gid        => $wso2_group,
    managehome => true,
    shell      => '/bin/bash',
    require    => Group[$wso2_group]
  }

  if $vm_type != 'docker' {
    cron { 'ntpdate':
      command => '/usr/sbin/ntpdate pool.ntp.org',
      user    => 'root',
      minute  => '*/50'
    }

    create_resources(host, $hosts_mapping)

    file { "/etc/init.d/${service_name}":
      ensure  => present,
      owner   => $wso2_user,
      group   => $wso2_group,
      mode    => '0755',
      content => template($service_template),
      require => [Group[$wso2_group], User[$wso2_user]]
    }
  }

  # Set Java system preferences directory
  file{ [$java_prefs_system_root, $java_prefs_user_root]:
    ensure  => 'directory',
    owner   => $wso2_user,
    group   => $wso2_group,
    mode    => '0755',
    require => [Group[$wso2_group], User[$wso2_user]]
  }
}
