// Copyright 2015 Google Inc. All Rights Reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
