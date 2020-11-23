# Trial Job - StormForger

The StormForger trial job leverages the `forge` CLI to launch a test case. The image will look for a test case definition (or will check to make sure it exists). Additionally, the image can introduce some JavaScript constants which can be referenced from the test case.

## Configuration

| Environment Variable | Description |
| -------------------- | ----------- |
| `TEST_CASE`           | The name of the StormForge test case to launch (including the organization). |
| `TEST_CASE_FILE`       | Path to the test case file mounted in the container. |
| `TARGET`             | Value to use for the `$target` JavaScript constant. |
| `TITLE`              | Title to use for the test run. |
| `NOTES`              | Notes to use for the test run (overwritten by `/etc/podinfo/labels` if present). |
| `STORMFORGER_JWT`    | Access token for the StormForger API. |
| `PUSHGATEWAY_URL`    | The URL used push StormForger test run metrics. |

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
      - name: stormforger
        image: redskyops/trial-jobs:0.0.1-stormforger
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
              name: stormforger-service-account
        - name: PUSHGATEWAY_URL
          value: http://pushgateway:9091/metrics/job/trialRun/instance/sandbox-1
        volumeMounts:
        - mountPath: /etc/podinfo
          name: podinfo
          readOnly: true
        - mountPath: /cases
          name: stormforger-test-case-file
          readOnly: true
      volumes:
      - name: stormforger-test-case-file
        configMap:
          name: stormforger-test-case
      - name: podinfo
        downwardAPI:
          items:
          - path: labels
            fieldRef:
              fieldPath: metadata.labels
```

NOTE: If you are using this in an experiment, keep in mind that some values are set automatically. In particular, the `backoffLimit`, `restartPolicy`, and `PUSHGATEWAY_URL` environment variable are all introduced when evaluating a trial's job template.
