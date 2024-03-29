# BlazeMeter Cloud Trial Image

The [BlazeMeter Cloud](https://www.blazemeter.com/) trial job enables you to use BlazeMeter performance tests in your Optimize Pro experiments. It leverages a custom container image, based on the the official [BlazeMeter Taurus](https://gettaurus.org/) [container image](https://hub.docker.com/r/blazemeter/taurus/).

Please note that, while this trial job does utilize BlazeMeter Taurus, it only officially supports cloud provisioned test execution using BlazeMeter Cloud.
None of the local executors provided by Taurus are officially supported with this trial job at this time.

## Usage

- Create a BlazeMeter API key, noting both the the key ID and the secret. These will only be shown once.
- Configure the environment variables shown in the next section for your trial job in your `experiment.yaml`
- Configure Trial to use either `prometheus` setupTask or manually define `PUSHGATEWAY_URL`.

## Configuration

| Environment Variable | Description | Default |
| -------------------- | ----------- | ------- |
| `BLAZEMETER_API_ID`        | BlazeMeter cloud API key ID | |
| `BLAZEMETER_API_SECRET`    | BlazeMeter cloud API key secret | |
| `BLAZEMETER_TEST_URL`      | BlazeMeter cloud test URL (e.g. `https://a.blazemeter.com/app/#/accounts/1234567/workspaces/1234567/projects/1234567/tests/12345678`)| |

## Metrics

Metrics are extracted from the summary CSV file generated by the Taurus [final stats reporter](https://gettaurus.org/docs/Reporting/#Final-Stats-Reporter).
This file contains calculated statistics based on all requests executed in the test.

| Name | Example Value | Description |
| ---- | ------------- | ---- |
| `concurrency` | 50 | average number of Virtual Users |
| `throughput` | 81323 | total count of all samples |
| `succ` | 77257 | total count of successful samples |
| `fail` | 4066 | total count of failed samples |
| `avg_rt` | 0.1387 | average response time (seconds) |
| `stdev_rt` | 0.02 | standard deviation of response time (seconds) |
| `avg_ct` | 0.005 | average connect time if present (seconds) |
| `avg_lt` | 0.135 | average latency if present (seconds) |
| `perc_90` | 0.184 | 90th percentile for response time (seconds) |
| `perc_95` | 0.186 | 95th percentile for response time (seconds) |
| `perc_99` | 0.189 | 99th percentile for response time (seconds) |
| `bytes` | 256 | total download size (bytes) |

## Example Kubernetes Manifest

The following Kubernetes Job manifest illustrates how you might leverage this trial job container.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: sandbox-1
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: black-friday
        image: thestormforge/optimize-trials:latest-blazemeter-cloud
        env:
        - name: PUSHGATEWAY_URL
          value: http://pushgateway:9091/metrics/job/trialRun/instance/sandbox-1
        - name: BLAZEMETER_API_ID
          value: 12345678abcdefg12345678
        - name: BLAZEMETER_API_SECRET
          value: abcdefg12345678abcdefg12345678abcdefg12345678abcdefg12345678abcdefg
        - name: BLAZEMETER_TEST_URL
          value: https://a.blazemeter.com/app/#/accounts/1234567/workspaces/1234567/projects/1234567/tests/12345678
```

NOTE: If you are using this in an experiment, keep in mind that some values are set automatically. In particular, the `backoffLimit`, `restartPolicy`, and `PUSHGATEWAY_URL` environment variable are all introduced when evaluating a trial's job template.
PUSHGATEWAY_URL requires the use of the `prometheus` setupTask.
