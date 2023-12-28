#!/usr/bin/python3

import subprocess
import csv


input_file  = "gh-pr-list"
output_file = "gh-pr-list.csv"

# Dump PR list
command = f"gh search prs 'is:public' --author fazledyn-or --limit 999 > {input_file}"
subprocess.call(command, shell=True)
print(f"Dumped data from GitHub CLI!")

# Open input file in read mode
with open(input_file, 'r') as file:
    lines = file.readlines()

# Extracting data, write to CSV
with open(output_file, 'w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile)
    csv_writer.writerow(['Repo', 'Pull Request', 'Status', 'Description', 'Timestamp', 'URL'])

    # Parsing lines and writing to CSV
    for line in lines:
        parts = line.split("\t")
        repo = parts[0]
        pull_request = parts[1]
        status = parts[2]
        description = ' '.join(parts[3:-2])
        timestamp = parts[-1]
        url = f'https://github.com/{repo}/pull/{pull_request}'
        csv_writer.writerow([repo, pull_request, status, description, timestamp, url])

print(f"Data exported to {output_file} successfully!")
