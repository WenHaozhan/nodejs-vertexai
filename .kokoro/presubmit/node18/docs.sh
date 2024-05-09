#!/bin/bash

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eo pipefail

if [[ -z "$CREDENTIALS" ]]; then
  # if CREDENTIALS are explicitly set, assume we're testing locally
  # and don't set NPM_CONFIG_PREFIX.
  export NPM_CONFIG_PREFIX=${HOME}/.npm-global
  export PATH="$PATH:${NPM_CONFIG_PREFIX}/bin"
  cd $(dirname $0)/../..
fi

npm install
npm install --no-save @google-cloud/cloud-rad@^0.4.0

# Switch to 'fail at end' to allow tar command to complete before exiting.
set +e

# publish docs to devsite
NO_UPLOAD=1 DOCS_METADATA_STEM=/vertex-ai/generative-ai/docs/reference/nodejs npx @google-cloud/cloud-rad . cloud-rad

tar cvfz docs.tar.gz yaml

if [[ $EXIT -ne 0 ]]; then
  echo -e "\n Generate docs failed: npx returned a non-zero exit code. \n"
  exit $EXIT
fi

set -e