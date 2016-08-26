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

define wso2base::resource {

  # a resource passed to this defined type is expected to be of the following form:
  # $resource = [ { type => 'resource type' , data => 'argument hash' } ]
  # ex.: to create a file at /mnt/foo/bar
  #
  # $data = {
  #   '/mnt/foo/bar' => { ensure => directory }
  # }
  #
  # $resource = [ { type => file , data => $data } ]
  #

  if (size($name) == 2) {
    notice("Create resource [type] $name['type'], [arguments] $name['data']")
    create_resources($name['type'], $name['data'])
  }
}