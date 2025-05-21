"""
Simple python script to count my total LoC in pull requests
"""

import sys
import argparse
import requests
import pandas as pd


EXTENSIONS = ["c", "cpp", "go", "java", "js", "jsx", "py"]

parser = argparse.ArgumentParser()
parser.add_argument("--csv", type=str, help="Enter CSV name for input")
args = parser.parse_args()

if not args.csv:
    parser.print_help()
    exit(1)


def split_to_diffs(content):
    diffs = []
    chunks = content.split("diff --git")
    for chunk in chunks:
        if chunk.strip():
            diffs.append(f"diff --git{chunk}")
    return diffs


def count_lines_from_diff(content):
    lines = content.split("\n")
    lines = [ each.strip() for each in lines ]

    n_lines = 0
    type = ""

    for line in lines:
        if line.startswith("+") and not line.startswith("+++"):
            n_lines += 1
        if line.startswith("+++"):
            type = line.split(".")[-1]

    return n_lines, type.strip().lower()


def main():
    print("Reading PRs from CSV...")
    df = pd.read_csv(args.csv)

    LINES = {
        "c"   : 0,
        "cpp" : 0,
        "go"  : 0,
        "java": 0,
        "js"  : 0,
        "jsx" : 0,
        "py"  : 0,
    }

    for i, row in df.iterrows():
        url = row["URL"]
        print("Processing PR:", url)
        url_diff = f"{url.rstrip('/')}.diff"

        r = requests.get(url_diff)
        diff_content = r.text
        diffs = split_to_diffs(diff_content)

        for diff in diffs:
            n_lines, type = count_lines_from_diff(diff)
            if type in LINES:
                count = LINES[type]
                LINES[type] = count + n_lines

    for type in LINES:
        print(f"Type: {type} - {LINES[type]}")


if __name__ == "__main__":
    main()
