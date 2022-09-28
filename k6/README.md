# k6 Trial Job

The k6 trial job leverages a custom k6 container, based on the [public
`grafana/k6` container image](https://hub.docker.com/r/loadimpact/k6), to launch a provided test case. The image will
check to make sure the provided test script exists. It is expected that the test script is valid k6 test case ([see k6 docs](https://k6.io/docs/using-k6/)) available in the container at runtime.

In order to make the k6 output metrics usable by the Optimize Pro
the metrics need to be translated to be pushable to Prometheus. As a result, we make use of k6's `handleSummary()` override function to format the output metrics as shown below. If your test case already defines a `handleSummary()` function it will not be overridden and, consequently, you will need to ensure your output format can be pushed to Prometheus as metrics and you appropriately reference them in your experiment files.

## Configuration

| Environment Variable | Description |
| -------------------- | ----------- |
| `TEST_CASE_FILE`     | Path to the test case file mounted in the container. Defaults to `/scripts/script.js`. Associated volume mount is required that contains this file. If the file is not found, the trial fails. |
| `PUSHGATEWAY_URL`    | The URL used to push K6 test run metrics. If not explicitly set, the Optimize controller will set it. |

## Metrics

The metrics below correspond to the [built-in output metrics](https://k6.io/docs/using-k6/metrics/#built-in-metrics) for a k6 test. Since these metrics take on the shape of an object with various specific attributes/values pairs (ie avg, min, med, etc), the metrics have to be
"flattened" to be pushable to Prometheus. The chosen format was to append the
attribute names to the main metric object, separated by underscores (`_`). As
mentioned previously, this translation is done within the default `handleSummary()` function we append by default to the provided test cases. If you have any custom metrics, they should be properly formatted as well. If your test case already includes a `handleSummary()` function, we will not override that and you must therefore ensure your metrics can be pushed to Prometheus.

| [Name (Built-in)](https://k6.io/docs/using-k6/metrics/#built-in-metrics)|
| -------------- |
| `data_received_count` |
| `data_received_rate` |
| `data_sent_count` |
| `data_sent_rate` |
| `iteration_duration_avg` |
| `iteration_duration_max` |
| `iteration_duration_med` |
| `iteration_duration_min` |
| `iteration_duration_p90` |
| `iteration_duration_p95` |
| `iterations_count` |
| `iterations_rate` |
| `vus_max` |
| `vus_min` |
| `vus_value` |

| [Name (HTTP-specific)](https://k6.io/docs/using-k6/metrics/#http-specific-built-in-metrics)|
| -------------- |
| `http_req_blocked_avg` |
| `http_req_blocked_max` |
| `http_req_blocked_med` |
| `http_req_blocked_min` |
| `http_req_blocked_p90` |
| `http_req_blocked_p95` |
| `http_req_connecting_avg` |
| `http_req_connecting_max` |
| `http_req_connecting_med` |
| `http_req_connecting_min` |
| `http_req_connecting_p90` |
| `http_req_connecting_p95` |
| `http_req_duration_avg` |
| `http_req_duration_max` |
| `http_req_duration_med` |
| `http_req_duration_min` |
| `http_req_duration_p90` |
| `http_req_duration_p95` |
| `http_req_failed_fails` |
| `http_req_failed_passes` |
| `http_req_failed_rate` |
| `http_req_receiving_avg` |
| `http_req_receiving_max` |
| `http_req_receiving_med` |
| `http_req_receiving_min` |
| `http_req_receiving_p90` |
| `http_req_receiving_p95` |
| `http_req_sending_avg` |
| `http_req_sending_max` |
| `http_req_sending_med` |
| `http_req_sending_min` |
| `http_req_sending_p90` |
| `http_req_sending_p95` |
| `http_req_tls_handshaking_avg` |
| `http_req_tls_handshaking_max` |
| `http_req_tls_handshaking_med` |
| `http_req_tls_handshaking_min` |
| `http_req_tls_handshaking_p90` |
| `http_req_tls_handshaking_p95` |
| `http_req_waiting_avg` |
| `http_req_waiting_max` |
| `http_req_waiting_med` |
| `http_req_waiting_min` |
| `http_req_waiting_p90` |
| `http_req_waiting_p95` |
| `http_reqs_count` |
| `http_reqs_rate` |

## Example Kubernetes Manifest

The following Kubernetes `Job` manifest and `ConfigMap` illustrates how you might leverage this trial job container.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: sandbox-1
  namespace: examples
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: black-friday
        image: thestormforge/optimize-trials:k6-latest
        env:
        - name: TEST_CASE_FILE
          value: /scripts/blackfriday.js
        - name: PUSHGATEWAY_URL
          value: http://pushgateway:9091/metrics/job/trialRun/instance/sandbox-1
        volumeMounts:
        - mountPath: /scripts
          name: load-script
          readOnly: true
      volumes:
      - configMap:
          name: load-script
        name: load-script
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: load-script
  namespace: examples
data:
  script.js: |
    import http from 'k6/http';
    import { sleep } from 'k6';

    export default function () {
      http.get('https://test.k6.io');
      sleep(10);
    }
```

NOTE: If you are using this in an experiment, keep in mind that some values are set automatically. In particular, the `backoffLimit`, `restartPolicy`, and `PUSHGATEWAY_URL` environment variable are all introduced when evaluating a trial's job template. `PUSHGATEWAY_URL` requires the usage of the [`prometheus` `setupTask`](https://docs.stormforge.io/optimize-pro/concepts/trials/#prometheus) though.
