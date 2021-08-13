# Trial Job - StormForge Performance

The StormForge Performance trial job leverages the `forge` CLI to launch a test case. The image will look for a test case definition (or will check to make sure it exists). Additionally, the image can introduce some JavaScript constants which can be referenced from the test case.

## Configuration

| Environment Variable | Description |
| -------------------- | ----------- |
| `TEST_CASE`          | The _required_ name of the StormForge Performance test case to launch (including the organization). |
| `TITLE`              | Title to use for the test run. |
| `NOTES`              | Notes to use for the test run. |
| `REGION`             | Region to start the test run in. |
| `SIZING`             | Cluster sizing to use for the test run. |
| `TARGET`             | Value to use for the `target` definition. |
| `TEST_CASE_FILE`     | Path to the test case file mounted in the container. |
| `STORMFORGER_JWT`    | Access token for the StormForge Performance API. |
| `PUSHGATEWAY_URL`    | The URL used push StormForge Performance test run metrics. |

| Files | Description |
| ----- | ----------- |
| `/etc/podinfo/labels` | If present, `name="value"` per-line labels to set on the test run. |

## Metrics

| Name |
| ---- |
| `apdex_75` |
| `min` |
| `max` |
| `request_count` |
| `error_ratio` |
| `clients_launched` |
| `mean` |
| `stddev` |
| `median` |
| `percentile_95` |
| `percentile_99` |

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
        image: thestormforge/optimize-trials:latest-stormforge-perf
        env:
        - name: TEST_CASE
          value: acme-inc/sandbox
        - name: TEST_CASE_FILE
          value: /cases/blackfriday.js
        - name: TITLE
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: STORMFORGER_JWT
          valueFrom:
            secretKeyRef:
              key: accessToken
              name: stormforge-service-account
        - name: PUSHGATEWAY_URL
          value: http://pushgateway:9091/metrics/job/trialRun/instance/sandbox-1
        volumeMounts:
        - mountPath: /etc/podinfo
          name: podinfo
          readOnly: true
        - mountPath: /cases
          name: stormforge-test-case-file
          readOnly: true
      volumes:
      - name: stormforge-test-case-file
        configMap:
          name: stormforge-test-case
      - name: podinfo
        downwardAPI:
          items:
          - path: labels
            fieldRef:
              fieldPath: metadata.labels
```

NOTE: If you are using this in an experiment, keep in mind that some values are set automatically. In particular, the `backoffLimit`, `restartPolicy`, and `PUSHGATEWAY_URL` environment variable are all introduced when evaluating a trial's job template.
