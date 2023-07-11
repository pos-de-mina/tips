#!/bin/bash
# 
# https://github.com/pos-de-mina/tips

# set proxy
# format https://proxy-server.local:8080/
pdm_set_proxy() {
  local proxy_server=$1

  # set multiple forms, lower and upper
  export {http,https,ftp,HTTP,HTTPS,FTP}_{proxy,PROXY}=$proxy_server
}

# log message to file
# [timestamp] [log_level] [source] [message]
# Timestamp: This indicates the date and time when the log entry was generated. It helps in tracking events and understanding the sequence of operations.
# Example format: 2023-06-30 14:30:15
# Log Level: This represents the severity or importance of the log entry. It categorizes the log entry based on its significance.
# Common log levels include:
# DEBUG: Detailed information for debugging purposes.
# INFO: General informational messages.
# WARNING or WARN: Indicating potential issues or non-fatal errors.
# ERROR: Denoting errors or exceptional conditions.
# CRITICAL or FATAL: Signifying critical errors that may lead to system failure.
# Example format: INFO, ERROR
# Source: This identifies the source or component that generated the log entry. It helps to determine which part of the system or application produced the log message.
# Example format: ApplicationName, ModuleXYZ
# Message: This contains the actual log message or description of the event or operation. It provides relevant details about what happened or any pertinent information.
# Example format: Connection established successfully, User logged in, File not found
# global variable for log file
PDM_LOG_FILE="/var/log/pdm.$(date +"%Y%m%d").log"
pdm_log() {
  # Message to log
  local message="$1"
  # Log Level: DEBUG, INFO, WARNING, ERROR
  local level="$2"
  # Get the current date and time
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  # Append the message and timestamp to the log file
  echo "${timestamp} ${level} ${message}" >> "$PDM_LOG_FILE"
}
pdm_log_debug(){
  pdm_log $1 'DEBUG'
}
pdm_log_info(){
  pdm_log $1 'INFO'
}
pdm_log_warnig(){
  pdm_log $1 'WARNING'
}
pdm_log_error() {
  pdm_log $1 'ERROR'
}

# Function: pdm_get_file_age_in_minutes
# Description: Get file age in minnutes based on modified date
# Parameters:
#   $1: THe file to check
# Returns: file age in minutes
pdm_get_file_age_in_minutes() {
  # file to check
  local file_path="$1"
  # Get the current timestamp in seconds since the epoch
  local current_time=$(date +%s)
  # Get the file's modification timestamp in seconds since the epoch
  local file_mtime=$(stat -c %Y "${file_path}")
  # Calculate the age of the file in minutes
  local age_minutes=$(( (current_time - file_mtime) / 60 ))

  echo "${age_minutes}"
}


check_file_age() {
    local file_path="$1"
    local age_threshold_minutes="$2"

    # Get the current timestamp in seconds since the epoch
    local current_time=$(date +%s)

    # Get the file's modification timestamp in seconds since the epoch
    local file_mtime=$(stat -c %Y "$file_path")

    # Calculate the age of the file in minutes
    local age_minutes=$(( (current_time - file_mtime) / 60 ))

    # Compare the file's age to the specified threshold
    if (( age_minutes > age_threshold_minutes )); then
        echo "The file is older than ${age_threshold_minutes} minutes."
    else
        echo "The file is not older than ${age_threshold_minutes} minutes."
    fi
}


# Function: calculate_sum
# Description: Calculates the sum of two numbers.
# Parameters:
#   $1: The first number.
#   $2: The second number.
# Returns: The sum of the two numbers.
calculate_sum() {
  local result=$(($1 + $2))
  echo $result
}

# Function: validate_email
# Description: Validates if an email address is in a correct format.
# Parameters:
#   $1: The email address to validate.
# Returns: 
#   0 if the email address is valid.
#   1 if the email address is invalid.
validate_email() {
  local email_regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"

  if [[ $1 =~ $email_regex ]]; then
    return 0
  else
    return 1
  fi
}

# Function: generate_random_password
# Description: Generates a random password of specified length.
# Parameters:
#   $1: The length of the password (default: 15).
# Returns: The randomly generated password.
pdm_generate_random_password() {
  local length=${1:-15}
  local password=$(openssl rand -base64 32 | cut -c1-$length)

  echo "${password:0:5}-${password:5:5}-${password:10:5}"
}

# Function: check_existing_process
# Description: Check if exist other process runnig and avoid this.
# Parameters: None.
# Returns: None.
pdm_pid_file="/tmp/pdm.pid"
pdm_check_existing_process() {
  # Check if the PID file exists
  if [ -f "$pdm_pid_file" ]; then
    # Read the PID from the file
    local old_pid=$(cat "$pdm_pid_file")

    # Check if the process with the same PID is running
    if ps -p "$old_pid" > /dev/null; then
      echo "ERROR: Another instance of the script is already running!"
      exit 1
    fi
  fi

  # Create or update the PID file with the current process ID
  echo $$ > "$pdm_pid_file"
}