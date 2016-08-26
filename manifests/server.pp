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
# Orchestrates a default WSO2 product installation
define wso2base::server (
  $maintenance_mode,
  $pack_filename,
  $pack_dir,
  $carbon_home_symlink,
  $install_mode,
  $install_dir,
  $pack_extracted_dir,
  $wso2_user,
  $wso2_group,
  $patches_dir,
  $service_name,
  $service_template,
  $template_list,
  $directory_list,
  $file_list,
  $system_file_list,
  $enable_secure_vault,
  $key_store_password
) {
  $carbon_home        = $name
  $patches_abs_dir    = "${carbon_home}/${patches_dir}"
  notice("WSO2 product [name] ${::product_name}, [version] ${::product_version}, [CARBON_HOME] ${carbon_home}")

  wso2base::clean { $carbon_home:
    mode          => $maintenance_mode,
    pack_filename => $pack_filename,
    pack_dir      => $pack_dir
  }

  # Copy the WSO2 product pack, extract and set permissions
  wso2base::install { $carbon_home:
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
    wso2_module      => $caller_module_name,
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
  if ($::platform == 'mesos' and $Wso2base::marathon_lb_cert_config_enabled == true) {
    wso2base::import_cert{ $carbon_home:
      carbon_home          => $carbon_home,
      wso2_module          => $wso2_module,
      java_home            => $Wso2base::java_home,
      cert_file            => $Wso2base::cert_file,
      trust_store_password => $Wso2base::trust_store_password,
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

  # Start the service
  # TODO: start the service only if configuration changes are applied that needs a restart to be effective
  if $::vm_type != 'docker' {
    service { $service_name:
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => [Wso2base::Deploy[$carbon_home], Wso2base::Patch[$carbon_home],
                     Wso2base::Configure[$carbon_home], Wso2base::Apply_secure_vault[$carbon_home]]
    }

    notify { "Successfully started WSO2 service [name] ${service_name}, [CARBON_HOME] ${carbon_home}":
      withpath => true,
      require  => Service[$service_name]
    }
  }
}
