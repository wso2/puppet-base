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

define wso2base::apply_secure_vault ($user, $enable_secure_vault, $key_store_password) {
  $carbon_home  = $name

  if $enable_secure_vault {
    notice("Applying secure vault for WSO2 product [name] ${::product_name}, [version] ${::product_version},
    [CARBON_HOME] ${carbon_home}")
    exec { 'Applying secure vault':
      user      => $user,
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd       => "${carbon_home}/bin",
      command   => "sh ciphertool.sh -Dconfigure -Dpassword=${key_store_password}",
      logoutput => 'on_failure'
    }
  }
}