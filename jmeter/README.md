# Apache JMeter Trial Image

TODO: …

## Usage

Mount volume with `test.jmx` into `/test`. Configure Trial to use either `prometheus` setupTask or manually define `PUSHGATEWAY_URL`.

## Configuration

| Environment Variable | Description | Default |
| -------------------- | ----------- | ------- |
| `JMETER_TEST_PLAN_FILE`     | Path to the JMeter test plan. | `/test/test.jmx` |
| `PUSHGATEWAY_URL`    | The URL used push StormForge Performance test run metrics. | |
| `JMETER_ARGS`        | Allows passing additional arguments to `jmeter`, e.g. to define properties. | |

## Metrics

Metrics are extracted from the `statistics.json` generated by the JMeter report based on all requests.

| Name | Example Value |
| ---- | ------------- |
| `errorCount` | `0` |
| `errorPct` | `0` |
| `maxResTime` | `269` |
| `meanResTime` | `145.86999999999992` |
| `medianResTime` | `150` |
| `minResTime` | `94` |
| `pct1ResTime` | `196.9` |
| `pct2ResTime` | `198` |
| `pct3ResTime` | `267.60000000000036` |
| `receivedKBytesPerSec` | `8.475751945331206` |
| `sampleCount` | `200` |
| `sentKBytesPerSec` | `3.370816290901836` |
| `throughput` | `19.952114924181963` |

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
        image: thestormforge/optimize-trials:latest-jmeter
        env:
        - name: PUSHGATEWAY_URL
          value: http://pushgateway:9091/metrics/job/trialRun/instance/sandbox-1
        volumeMounts:
        - mountPath: /test
          name: jmeter-test-case-file
          readOnly: true
      volumes:
      - name: jmeter-test-case-file
        configMap:
          name: jmeter-test-case
```

NOTE: If you are using this in an experiment, keep in mind that some values are set automatically. In particular, the `backoffLimit`, `restartPolicy`, and `PUSHGATEWAY_URL` environment variable are all introduced when evaluating a trial's job template.
PUSHGATEWAY_URL requires the use of the `prometheus` setupTask.