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

define wso2base::push_system_files ($owner, $group, $wso2_module) {
  $file = $name['file']
  $target_path = $name['target_path']

  ensure_resource('file', "${target_path}/${file}", {
    ensure  => present,
    owner   => $owner,
    group   => $group,
    recurse => remote,
    mode    => '0754',
    source  => ["puppet:///modules/${wso2_module}/system/${file}"]
  })
}
