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

define wso2base::configure_and_deploy (
  $install_dir,
  $patches_dir,
  $wso2_user,
  $wso2_group,
  $template_list,
  $directory_list,
  $file_list,
  $system_file_list,
  $enable_secure_vault,
  $key_store_password,
  $java_home,
  $cert_file,
  $trust_store_password,
  $module_name,
  $marathon_lb_cert_config_enabled
) {
  $carbon_home        = "${install_dir}/${::product_name}-${::product_version}"
  $patches_abs_dir    = "${carbon_home}/${patches_dir}"
  notice("Configuring and Deploying WSO2 product [name] ${::product_name}, [version] ${::product_version}, [CARBON_HOME] ${carbon_home}")

  # Copy any patches to patch directory
  wso2base::patch { $carbon_home:
    patches_abs_dir => $patches_abs_dir,
    patches_dir     => $patches_dir,
    user            => $wso2_user,
    group           => $wso2_group,
    product_name    => $::product_name,
    product_version => $::product_version,
    require         => Wso2base::Install[$carbon_home]
  }

  # Populate templates and copy files provided
  wso2base::configure { $carbon_home:
    template_list    => $template_list,
    directory_list   => $directory_list,
    file_list        => $file_list,
    system_file_list => $system_file_list,
    user             => $wso2_user,
    group            => $wso2_group,
    wso2_module      => $module_name,
    require          => Wso2base::Install[$carbon_home]
  }

  # Apply secure_vault
  wso2base::apply_secure_vault { $carbon_home:
    user                => $wso2_user,
    enable_secure_vault => $enable_secure_vault,
    key_store_password  => $key_store_password,
    require             => [Wso2base::Configure[$carbon_home], Wso2base::Patch[$carbon_home]]
  }

  # Import marathon-lb ceritficate
  if ($::platform == 'mesos' and $marathon_lb_cert_config_enabled == true) {
    wso2base::import_cert{ $carbon_home:
      carbon_home          => $carbon_home,
      wso2_module          => $module_name,
      java_home            => $java_home,
      cert_file            => $cert_file,
      trust_store_password => $trust_store_password,
      require              => Wso2base::Configure[$carbon_home]
    }
  }

  # Deploy product artifacts
  wso2base::deploy { $carbon_home:
    user            => $wso2_user,
    group           => $wso2_group,
    product_name    => $::product_name,
    product_version => $::product_version,
    require         => Wso2base::Install[$carbon_home]
  }

}