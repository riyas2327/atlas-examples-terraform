// Copyright 2015 Google Inc. All Rights Reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// These should be picked up from environment variables prefixed with 'TF_VAR_'
// e.g, before running terraform, make sure to,
// export TF_VAR_ATLAS_USERNAME=erjohnso
variable "GOOGLE_PROJECT_ID" { }
variable "ATLAS_USERNAME" { }
variable "ATLAS_TOKEN" { }
variable "ATLAS_ENVIRONMENT" {
    default = "erjohnso/hyperspace-env"
}

variable "consul_server_count" { 
  default = 3
}
