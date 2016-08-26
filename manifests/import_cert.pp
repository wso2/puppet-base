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

# Add marathon-lb certificate to wso2 server's trust-store
define wso2base::import_cert ($carbon_home, $java_home, $cert_file, $trust_store_password, $alias_name) {
    ensure_resource('file', "${carbon_home}/repository/resources/security/${cert_file}", {
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => '0754',
      source  => ["puppet:///modules/wso2base/${cert_file}"]
    })

    exec {'Importing marathon-lb cert':
      path      => "${java_home}/bin",
      cwd       => "${carbon_home}/repository/resources/security",
      command   => "keytool -importcert -noprompt -alias ${alias_name} -keystore client-truststore.jks -storepass ${trust_store_password} -file ${cert_file}",
      logoutput => 'on_failure',
      require   => File["${carbon_home}/repository/resources/security/${cert_file}"]
    }
  }
