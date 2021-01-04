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
    """
    Fetch metrics from locust csv and create raw metrics for
    the prometheus push gateway The metrics pushed are
    detailed in the README
    """
    for row in csv.DictReader(open(args.metrics_file)):
        if row["Name"] == "Aggregated":
            row.pop("Type")
            row.pop("Name")
            row.pop("Median Response Time")
            row = {parse_metric_key(k): float(v) for k, v in row.items()}
            metrics_dict = row
            metrics_dict["errorr_ratio"] = float(
                metrics_dict["failure_count"] / metrics_dict["request_count"])
    with open("output.json", "w") as fp:
        json.dump(metrics_dict, fp)


if __name__ == '__main__':
    ARGPARSER = argparse.ArgumentParser()
    ARGPARSER.add_argument("--metrics_file",
                           help="locust metrics csv file",
                           default="locust_stats.csv",
                           type=str)
    ARGS = ARGPARSER.parse_args()
    main(ARGS)
