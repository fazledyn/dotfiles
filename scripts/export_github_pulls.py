"""
Simple python script to export my public PRs into a CSV file
"""

import sys
import json
import argparse
import subprocess
import pandas as pd


# check if user has `gh` cli installed or not
_c, _m = subprocess.getstatusoutput("gh version")
if _c != 0:
    print("You do not have GitHub CLI installed")
    print("Visit 'https://cli.github.com' to download")
    exit(1)

LIMIT = 999

HANDLES = [
    "fazledyn",
    "fazledyn-or",
]

UNALLOWED_REPO_OWNERS = [
    # own
    "fazledyn",
    "fazledyn-or",

    # work
    "openrefactory",
    "openrefactory-inc",

    # misc
    "jaintapauljp",
    "mushtari-sadia",
    "tanzimazadnishan",
]

parser = argparse.ArgumentParser()
parser.add_argument("--csv", type=str, help="Enter CSV name for output")
args = parser.parse_args()

if not args.csv:
    parser.print_help()
    exit(1)


def count_pr_lines(url):
    proc = subprocess.run(
        f"gh pr diff {url}",
        text=True,
        shell=True,
        capture_output=True,
    )
    lines = str(proc.stdout).splitlines()
    line_count = 0
    for line in lines:
        if line.startswith("+") and not line.startswith("+++"):
            line_count += 1
    return line_count

def main():
    print("Fetching PRs from GitHub ...")
    pr_list = []
    for handle in HANDLES:
        proc = subprocess.run(
            f"""
            gh search prs     \
            'is:public'       \
            --author {handle} \
            --limit {LIMIT}   \
            --json 'title,url,createdAt,author,state'
            """,
            capture_output=True,
            shell=True,
            text=True,
        )
        out_json = json.loads(proc.stdout)

        for pr in out_json:
            sys.stdout.write(".")
            sys.stdout.flush()
            pr_repo_owner = pr["url"].split("/")[3]
            pr_entry = {
                "author": pr["author"]["login"],
                "state" : pr["state"],
                "title" : pr["title"],
                "date"  : pr["createdAt"][0:10],
                "url"   : pr["url"],
                "owner" : pr_repo_owner.lower(),
            }
            pr_list.append(pr_entry)

    print(f"\nTotal Unfiltered PRs: {len(pr_list)}")

    print("Filtering PRs ...")
    filtered_pr_list = []
    for pr in pr_list:
        sys.stdout.write(".")
        sys.stdout.flush()
        if pr["state"] in ["open", "merged"]:
            if pr["owner"] not in UNALLOWED_REPO_OWNERS:
                del pr["owner"]
                # pr["lines"] = count_pr_lines(pr["url"])
                filtered_pr_list.append(pr)

    print(f"\nTotal Filtered PRs: {len(filtered_pr_list)}")

    print("Exporting PRs to CSV ...")
    df = pd.DataFrame()
    for pr in filtered_pr_list:
        sys.stdout.write(".")
        sys.stdout.flush()
        csv_row = {
            "Author": pr["author"],
            "Status": pr["state"],
            "Title": pr["title"],
            "Created On": pr["date"],
            "URL": pr["url"],
            # "# of Lines": pr["lines"],
        }
        csv_row = pd.DataFrame(csv_row, index=["Author"])
        df = pd.concat([df, csv_row])

    df.to_csv(args.csv, index=False)
    print("\nSuccess!")
    print(f"Exported PR List to {args.csv}")


if __name__ == "__main__":
    main()
