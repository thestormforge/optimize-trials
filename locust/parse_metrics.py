import csv
import json
import argparse


def parse_metric_key(key):
    key = key.lower().replace(" ", "_").replace("/", "_per_").replace(".", "_")
    if "%" in key:
        key = key.replace("%", "")
        key = "p" + key
    return key


def main(args):
    # Fetch metrics from locust csv and create json output
    for row in csv.DictReader(open(args.metrics_file)):
        if row["Name"] == "Aggregated":
            row.pop("Type")
            row.pop("Name")
            row = {parse_metric_key(k): float(v) for k, v in row.items()}
            with open(args.output_file, 'w') as fp:
                json.dump(row, fp)


if __name__ == '__main__':
    ARGPARSER = argparse.ArgumentParser()
    ARGPARSER.add_argument("--metrics_file",
                           help="locust metrics csv file",
                           default="locust_stats.csv",
                           type=str)
    ARGPARSER.add_argument("--output_file",
                           help="output json file",
                           default="output.json",
                           type=str)
    ARGS = ARGPARSER.parse_args()
    main(ARGS)
