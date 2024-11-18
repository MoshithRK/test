

---

# ClearData Script Suite Documentation

## Overview

This repository contains a suite of bash scripts to manage files between an S3 bucket and a local directory. The process is divided into four main steps:
1. Retrieve file list from the S3 bucket.
2. Find specific files in the local directory.
3. Compare files from the S3 bucket and the local directory to identify common files.
4. Delete the common files from the local directory.

Each script in this suite is designed to automate and streamline file management tasks.

---

## 1. Retrieve S3 Files

**Purpose**:  
This script lists all files in the specified S3 bucket and saves their names to a local file for further processing.

**Script**: `retrieve_s3_files.sh`

```bash
#!/bin/bash

# Define the S3 bucket and output file
s3_bucket="s3://s3-amz-wb-bucket/slip_image"
output_file="/home/ubuntu/s3_file_list.txt"

# List all files in the S3 bucket and store their names in the output file
aws s3 ls "$s3_bucket/" --recursive | awk '{print $4}' > "$output_file"

# Check if the file was created and has content
if [ -s "$output_file" ]; then
  echo "File list successfully saved to $output_file"
else
  echo "No files found in the S3 bucket or an error occurred."
fi
```

### Process Steps:
1. **Define S3 Bucket and Output File**:  
   The script begins by defining the S3 bucket (`s3://s3-amz-wb-bucket/slip_image`) and the output file path (`/home/ubuntu/s3_file_list.txt`) to store the list of file names.

2. **List Files from S3**:  
   Using the AWS CLI, the script lists all files recursively within the specified S3 bucket. The `aws s3 ls` command is used for this operation, and the output is processed using `awk` to extract the filenames only.

3. **Save to Local File**:  
   The file names are saved to `/home/ubuntu/s3_file_list.txt`. If the file is created and contains data, a success message is printed. Otherwise, it indicates that no files were found.

---

## 2. Find Files in Local Directory

**Purpose**:  
This script searches for files that contain the term “2023” in their names in a local directory and saves the results to a file.

**Script**: `find_files.sh`

```bash
#!/bin/bash

# Define the local directory and output file
local_dir="/var/www/html/dbamazon/Service/slip_image"
output_file="/home/ubuntu/files_with_2023.txt"

# Check if the local directory exists
if [ ! -d "$local_dir" ]; then
  echo "Directory $local_dir does not exist."
  exit 1
fi

# Find all files with "2023" in their name and save to the output file
find "$local_dir" -type f -name "*2023*" -exec basename {} \; > "$output_file"

# Check if the output file contains any results
if [ -s "$output_file" ]; then
  echo "File names containing '2023' have been saved to $output_file"
else
  echo "No files with '2023' found in $local_dir."
  rm -f "$output_file" # Remove the empty file if no results
fi
```

### Process Steps:
1. **Check Local Directory Existence**:  
   The script checks if the specified local directory (`/var/www/html/dbamazon/Service/slip_image`) exists.

2. **Search Files with '2023'**:  
   Using the `find` command, it searches the local directory for files with "2023" in their names. The file names are saved to `/home/ubuntu/files_with_2023.txt`.

3. **Handle Empty Results**:  
   If no files are found, the script deletes the output file (`files_with_2023.txt`).

---

## 3. Compare Files from S3 and Local Directory

**Purpose**:  
This script compares the list of files from the S3 bucket and the local directory to identify common files that exist in both.

**Script**: `compare_files.sh`

```bash
#!/bin/bash

# Define file paths
s3_file_list="/home/ubuntu/s3_file_list.txt"
files_with_2023="/home/ubuntu/files_with_2023.txt"
processed_s3_file_list="/home/ubuntu/processed_s3_file_list.txt"
common_files="/home/ubuntu/common_files.txt"

# Check if input files exist
if [[ ! -f "$s3_file_list" ]]; then
  echo "Error: File $s3_file_list does not exist."
  exit 1
fi

if [[ ! -f "$files_with_2023" ]]; then
  echo "Error: File $files_with_2023 does not exist."
  exit 1
fi

# Remove the "slip_image/" prefix from s3_file_list.txt and save to a temporary file
awk -F '/' '{print $NF}' "$s3_file_list" > "$processed_s3_file_list"

# Sort both files
sort "$processed_s3_file_list" -o "$processed_s3_file_list"
sort "$files_with_2023" -o "$files_with_2023"

# Compare files and find common lines, saving directly to common_files.txt
comm -12 "$processed_s3_file_list" "$files_with_2023" > "$common_files"

# Check if common files were found
if [[ -s "$common_files" ]]; then
  echo "Common files have been successfully saved to $common_files."
else
  echo "No common files were found."
fi

exit 0
```

### Process Steps:
1. **Check Input Files**:  
   The script checks if the required input files (`s3_file_list.txt` and `files_with_2023.txt`) exist.

2. **Process and Sort Files**:  
   - It removes the prefix (`slip_image/`) from the file names listed in `s3_file_list.txt` using `awk`.
   - Both the S3 file list and the local file list are sorted using the `sort` command.

3. **Find Common Files**:  
   The `comm` command is used to find common files between the two sorted lists and save them to `common_files.txt`.

4. **Check for Common Files**:  
   If common files are found, the script outputs a success message; otherwise, it indicates no common files were found.

---

## 4. Delete Common Files

**Purpose**:  
This script deletes the common files identified in the previous step from the local directory.

**Script**: `delete_common_files.sh`

```bash
#!/bin/bash

# Define paths
common_files="/home/ubuntu/common_files.txt"
local_dir="/var/www/html/dbamazon/Service/slip_image"

# Check if common_files.txt exists and is not empty
if [[ ! -f "$common_files" ]]; then
  echo "Error: File $common_files does not exist."
  exit 1
fi

if [[ ! -s "$common_files" ]]; then
  echo "Error: File $common_files is empty."
  exit 1
fi

# Initialize counter
deleted_count=0

# Loop through each file in common_files.txt
while IFS= read -r file; do
  # Construct the full path of the file
  file_path="$local_dir/$file"
  
  # Check if the file exists and delete it
  if [[ -f "$file_path" ]]; then
    rm "$file_path"
    ((deleted_count++))
  fi
done < "$common_files"

# Output success message with count
echo "$deleted_count files have been successfully removed from $local_dir."

exit 0
```

### Process Steps:
1. **Check for Common Files**:  
   The script checks if the `common_files.txt` file exists and contains any data.

2. **Delete Files**:  
   It loops through each line in `common_files.txt`, constructs the full file path, and deletes the file from the local directory.

3. **Count Deleted Files**:  
   After deleting each file, the script keeps a count of how many files were deleted and outputs the total number.

---

## File Structure

```text
/home/ubuntu/cleardata/
├── common_files.txt
├── compare_files.sh
├── delete_common_files.sh
├── files_with_2023.txt
├── find_files.sh
├── processed_s3_file_list.txt
├── retrieve_s3_files.sh
├── s3_file_list.txt
└── s3_file_cleaned.txt
```

---

## Requirements

- **AWS CLI**: Ensure that the AWS CLI is installed and properly configured with access to the required S3 bucket.
- **Permissions**: Ensure the script has permission to read from the S3 bucket and write to the local directory.
- **Bash Shell**: These scripts are intended to run on a Linux server using bash.

---

## How to Run

1. Clone or download the repository containing the scripts.
2. Ensure the correct AWS permissions and configurations are in place for accessing the S3 bucket.
3. Modify any script variables (e.g., S3 bucket name, local directory paths) if needed.
4. Run each script sequentially in the order listed above.

Example:
```bash
./retrieve

_s3_files.sh
./find_files.sh
./compare_files.sh
./delete_common_files.sh
```

---

This concludes the documentation for the **ClearData Script Suite**. Let me know if you need any further modifications or enhancements!
