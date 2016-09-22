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

# Add certificate to wso2 server's trust-store
define wso2base::import_cert ($carbon_home, $java_home, $owner, $group, $wso2_module, $trust_store_password) {
  $cert_file = $name['file']
  $alias     = $name['alias']

  ensure_resource('file', "${carbon_home}/repository/resources/security/${cert_file}", {
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0754',
    source  => [
      "puppet:///modules/${wso2_module}/certs/${cert_file}",
      "puppet:///modules/wso2base/certs/${cert_file}",
      "puppet:///files/certs/${cert_file}"
    ]
  })

  exec { "import_cert_${cert_file}":
    path      => "${java_home}/bin",
    cwd       => "${carbon_home}/repository/resources/security",
    command   => "keytool -importcert -noprompt -alias ${alias} -keystore client-truststore.jks -storepass ${trust_store_password} -file ${cert_file}",
    logoutput => 'on_failure',
    require   => File["${carbon_home}/repository/resources/security/${cert_file}"],
    notify    => Exec["delete_cert_${cert_file}"],
  }

  exec { "delete_cert_${cert_file}":
    path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd       => "${carbon_home}/repository/resources/security",
    command   => "rm -rf ${cert_file}",
    logoutput => 'on_failure',
    refreshonly => true,
  }
}
