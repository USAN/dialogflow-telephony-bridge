#!/bin/bash
#
# Copyright 2018 USAN, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

if [ -z "$AGENT_PORT" ]; then
  echo "AGENT_PORT environment variable must be set"
  exit 1
fi

if [ ! -d "/etc/ubbagent" ]; then
  echo "/etc/ubbagent directory must be mounted"
  exit 1
fi

# Copy the metering agent config.
cp /agent-config.yaml /etc/ubbagent/config.yaml
