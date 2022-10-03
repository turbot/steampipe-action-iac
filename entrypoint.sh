#!/bin/sh

set -xe
steampipe query "select 1"

setup_plugin()
{
  steampipe plugin install $INPUT_PLUGIN
  
  # Add config file
  export X=0
  echo "\nconnection \"$INPUT_PLUGIN$X\" {" > ~/.steampipe/config/terraform.spc
  echo "  plugin = \"$INPUT_PLUGIN\"" >> ~/.steampipe/config/terraform.spc
  echo "  paths = [ \"/home/steampipe/**/*.tf\" ]" >> ~/.steampipe/config/terraform.spc
  echo "}" >> ~/.steampipe/config/terraform.spc
  cat ~/.steampipe/config/terraform.spc
}

run_infra_check() {
  if steampipe check $INPUT_RUN ; then
    echo "Success"
  else
    echo "Fail"
  fi
}

# Setup plugin
setup_plugin

# Copy infra files
cp -r examples/terraform/aws /home/steampipe/aws

# Mod installation
git clone --depth 1 $INPUT_MOD_URL /workspace
cd /workspace

# Run infra check
run_infra_check