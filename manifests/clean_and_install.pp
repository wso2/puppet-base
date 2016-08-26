# ------------------------------------------------------------------------------
# Copyright (c) 2016, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------------

define wso2base::clean_and_install (
  $maintenance_mode,
  $install_mode,
  $pack_filename,
  $pack_dir,
  $install_dir,
  $wso2_user,
  $wso2_group,
  $carbon_home_symlink,
  $hosts_mappings
) {
  $carbon_home        = "${install_dir}/${::product_name}-${::product_version}"
  notice("Cleaning and Installing WSO2 product [name] ${::product_name}, [version] ${::product_version}, [CARBON_HOME] ${carbon_home}")

  # Clean
  ::wso2base::clean { $carbon_home:
    mode          => $maintenance_mode,
    pack_filename => $pack_filename,
    pack_dir      => $pack_dir
  }

  # Copy the WSO2 product pack, extract and set permissions
  ::wso2base::install { $carbon_home:
    mode          => $install_mode,
    install_dir   => $install_dir,
    pack_filename => $pack_filename,
    pack_dir      => $pack_dir,
    user          => $wso2_user,
    group         => $wso2_group,
    product_name  => $::product_name,
    require       => Wso2base::Clean[$carbon_home]
  }

  # Create a symlink to CARBON_HOME
  if $::vm_type != 'docker' {
    file { $carbon_home_symlink:
      ensure  => 'link',
      target  => $carbon_home,
      require => Wso2base::Install[$carbon_home]
    }
  }

  ::wso2base::host_mappings { "/etc/host entries for node [carbon home] $carbon_home":
    hosts_mappings => $hosts_mappings
  }
}