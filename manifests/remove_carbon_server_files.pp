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

define wso2base::remove_carbon_server_files ($carbon_home,$file_list_to_remove) {

  notice("Remove files in the WSO2 pack [carbon_home] $carbon_home [file_list] $file_list_to_remove")

  $list = prefix(prefix($file_list_to_remove,"/"),$carbon_home)

  file { $list:
    ensure => "absent",
    purge  => true,
    force  => true
  }
}
