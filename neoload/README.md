# Tricentis NeoLoad Trial Image

TODO: …

## Prerequisites

TODO: …

## Configuration

| Environment Variable | Description |
| -------------------- | ----------- |
| `TODO`        | TODO |
| `PUSHGATEWAY_URL`    | The URL used to push K6 test run metrics. If not explicitly set, the Optimize controller will set it. |

## Metrics

TODO: …

## Example Kubernetes Manifest

TODO: …

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
        - name: SCRIPT_FILE
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
