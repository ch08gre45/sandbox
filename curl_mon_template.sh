#!/bin/bash

# Setup
this_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
this_date_time=$(date +%Y_%m_%d_%H_%M)

# Script called with 3 parameters: check name, check environment and check url
check_type_name=$1
check_environment=$2
check_url=$3
# Look for this in the response as proof of success
check_grep="CHANGE_ME"

lock_file="/tmp/${check_type_name}.lock"
output_file="/tmp/${check_environment}_${check_type_name}_$(date +%Y_%m_%d).csv"

# Check lock file before going forward with the check
[ ! -f ${lock_file} ] && > ${lock_file} || exit 1

# Do the check
request_result=$(curl -s --connect-timeout 20 --max-time 30 ${check_url} -w "test_time_total %{time_total}")

# Parse the response
state=$([ $(echo -e "${request_result}" | grep "${check_grep}" | wc -l) -gt 0 ] && echo "1" || echo "0" )
timer=$(echo -e "${request_result}" | grep "test_time_total" | cut -d " " -f 2)

# Send the final output to the output file
echo "${this_date_time},${check_environment},${check_type_name},${state},${timer}"

# Remove lock file after everything is done
rm -f ${lock_file}
