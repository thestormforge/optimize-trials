# Trial Job - Locust

The Locust job uses Locust to launch a load test performed by Locust and collect the metrics at the end of the job. The metrics are then pushed to the Prometheus Pushgateway.

## Configuration

| Environment Variable | Description | Default Value |
| -------------------- | ----------- | ------------- |
| `HOST`               | Host to load test in the following format: "http://10.21.32.33" | `http://localhost:8000` |
| `NUM_USERS`          | Number of concurrent locust users | `200` |
| `SPAWN_RATE`         | The rate per second in which users are spawned | `20` |
| `RUN_TIME`           | Duration of the load test in seconds | `180` |
| `PUSHGATEWAY_URL`    | The URL used to push Locust test run metrics. | |

## Metrics

| Name |
| ---- |
| `request_count` |
| `failure_count` |
| `average_response_time` |
| `min_response_time` |
| `max_response_time` |
| `average_content_size` |
| `requests_per_s` |
| `failures_per_s` |
| `p50` |
| `p66` |
| `p75` |
| `p80` |
| `p90` |
| `p95` |
| `p98` |
| `p99` |
| `p99_9` |
| `p99_99` |
| `p100` |

## Example Kubernetes Manifest

The following Kubernetes Job manifest illustrates how you might leverage this trial job container. The environment variables are the arguments to the Locust CLI and the Prometheus Pushgateway URL. The locustfile is passed via a ConfigMap.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: locustconfig
data:
  locustfile.py: |
    from locust import HttpUser, task, between
    class MyUser(HttpUser):
        wait_time = between(1, 5)
        @task(1)
        def index(self):
            self.client.get("/api-url/endpoint/")
---
apiVersion: batch/v1
kind: Job
metadata:
  name: locust-1
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: locust
        image: redskyops/trial-jobs:0.0.1-locust
        env:
        - name: HOST
          value: "http://api-endpoint:port-number"
        - name: NUM_USERS
          value: "200"
        - name: SPAWN_RATE
          value: "20"
        - name: RUN_TIME
          value: "180"
        - name: PUSHGATEWAY_URL
          value: "http://prometheus:9091/metrics/job/trialRun/instance/locust-1"
        volumeMounts:
          - name: locustconfig
            mountPath: /locust/locustfile.py
            subPath: locustfile.py
      volumes:
      - name: locustconfig
        configMap:
          name: locustconfig
      - name: podinfo
        downwardAPI:
          items:
          - path: labels
            fieldRef:
              fieldPath: metadata.labels
```

NOTE: If you are using this in an experiment, keep in mind that some values are set automatically. In particular, the `backoffLimit`, `restartPolicy`, and `PUSHGATEWAY_URL` environment variable are all introduced when evaluating a trial's job template.
