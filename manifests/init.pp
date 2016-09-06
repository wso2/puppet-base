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

# wso2base main class. This class validates base configuration parameters
class wso2base (
  $packages               = $wso2base::params::packages,
  $template_list          = $wso2base::params::template_list,
  $file_list              = $wso2base::params::file_list,
  $patch_list             = $wso2base::params::patch_list,
  $cert_list              = $wso2base::params::cert_list,
  $system_file_list       = $wso2base::params::system_file_list,
  $directory_list         = $wso2base::params::directory_list,
  $hosts_mapping          = $wso2base::params::hosts_mapping,
  $java_home              = $wso2base::params::java_home,
  $java_prefs_system_root = $wso2base::params::java_prefs_system_root,
  $java_prefs_user_root   = $wso2base::params::java_prefs_user_root,
  $vm_type                = $wso2base::params::vm_type,
  $wso2_user              = $wso2base::params::wso2_user,
  $wso2_group             = $wso2base::params::wso2_group,
  $product_name           = $wso2base::params::product_name,
  $product_version        = $wso2base::params::product_version,
  $platform_version       = $wso2base::params::platform_version,
  $carbon_home_symlink    = $wso2base::params::carbon_home_symlink,
  $remote_file_url        = $wso2base::params::remote_file_url,
  $maintenance_mode       = $wso2base::params::maintenance_mode,
  $install_mode           = $wso2base::params::install_mode,
  $install_dir            = $wso2base::params::install_dir,
  $pack_dir               = $wso2base::params::pack_dir,
  $pack_filename          = $wso2base::params::pack_filename,
  $pack_extracted_dir     = $wso2base::params::pack_extracted_dir,
  $patches_dir            = $wso2base::params::patches_dir,
  $service_name           = $wso2base::params::service_name,
  $service_template       = $wso2base::params::service_template,
  $ipaddress              = $wso2base::params::ipaddress,
  $enable_secure_vault    = $wso2base::params::enable_secure_vault,
  $secure_vault_configs   = $wso2base::params::secure_vault_configs,
  $key_stores             = $wso2base::params::key_stores
) inherits wso2base::params {

  validate_array($packages)
  validate_array($template_list)
  validate_array($file_list)
  validate_array($patch_list)
  validate_hash($cert_list)
  validate_hash($system_file_list)
  validate_array($directory_list)
  validate_hash($hosts_mapping)
  validate_string($java_home)
  validate_string($java_prefs_system_root)
  validate_string($java_prefs_user_root)
  validate_string($vm_type)
  validate_string($wso2_user)
  validate_string($wso2_group)
  validate_string($product_name)
  validate_string($product_version)
  validate_string($platform_version)
  validate_string($carbon_home_symlink)
  validate_string($maintenance_mode)
  validate_string($install_mode)
  validate_string($install_dir)
  validate_string($pack_dir)
  validate_string($pack_filename)
  validate_string($pack_extracted_dir)
  validate_string($patches_dir)
  validate_string($service_name)
  validate_string($service_template)
  validate_string($ipaddress)
  validate_bool($enable_secure_vault)
  validate_hash($key_stores)

  if $install_mode == 'file_repo' {
    validate_string($remote_file_url)
  }

  if $enable_secure_vault {
    validate_hash($secure_vault_configs)
  }

  $carbon_home         = "${install_dir}/${product_name}-${product_version}"
  $pack_file_abs_path  = "${pack_dir}/${pack_filename}"
}
