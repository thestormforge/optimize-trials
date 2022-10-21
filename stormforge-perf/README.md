# Trial Job - StormForge Performance

Running a trial job with [StormForge Performance Testing](https://docs.stormforge.io/perftest/) differs a bit based on the [environment](https://docs.stormforge.io/perftest/getting-started/environments/) you want to use.

If you are interacting with the Performance Testing via the `forge` CLI or use [app.stormforger](https://app.stormforger.com), see the [Standalone Environment guide here](#standalone-environment). For users of the Platform Environment checkout the next section.

## Platform Environment

To run a trial job on the `platform` environment, you can use the [`stormforge-cli` container image](https://docs.stormforge.io/stormforge-cli/) directly in your [experiment.yaml](https://docs.stormforge.io/optimize-pro/reference/experiment/v1beta2/#experiment):

```yaml
  trialTemplate:
    spec:
      initialDelaySeconds: 15
      setupServiceAccountName: stormforge-setup
      setupTasks:
      - name: monitoring
        args:
        - prometheus
        - $(MODE)
      jobTemplate:
        spec:
          template:
            spec:
              containers:
              - name: stormforge-cli
                image: registry.stormforge.io/library/stormforge-cli
                envFrom:
                - secretRef:
                    name: stormforge-secret
                args:
                # NOTE: --metrics-output is automatically activated via ENV variable
                - create
                - test-run
                - "--test-case=testapp_labs_optimize_trial"
                - "--watch-timeout=1h"
                - "--watch"
```

This example snippet from an experiment uses the `stormforge-cli` for the trial pod.

Via the `args` this trial launches a new test-run from the existing test case `testapp_labs_optimize_trial` and waits for it to finish.
You can attach additional metadata via additional arguments like `--note`, `--title` or `--label`. See [`stormforge create test-run`](https://docs.stormforge.io/stormforge-cli/reference/#stormforge-create-test-run) for more options.

With the `prometheus` setupTask Optimize Pro automatically provisions a prometheus cluster for each trial and injects a `PUSHGATEWAY_URL` into the trial pod. This environment variable triggers a metrics export at the end of the test run, so you can utilize these metrics for optimization criteria.

### Authentication

To allow the trial job to interact with StormForge Performance Testing, the container needs to be configured with a `STORMFORGE_TOKEN` environment variable.
You can create this token via the [`stormforge auth new-token`](https://docs.stormforge.io/stormforge-cli/reference/#stormforge-auth-new-token) command:

```terminal
$ stormforge auth new-token --name stormforge-experiment-token
STORMFORGE_TOKEN=1234567890abcdef1234567890abcdef.1234567890abcdef1234567890abcdef1234567890abcdef.1234567890abcdef1234567890abcdef1234567890abcdef
```

You can store this value as a secret in Kubernetes via `kubectl create secret` in one command:

```terminal
kubectl create secret generic stormforge-secret --from-literal=$(stormforge auth new token --name stormforge-experiment-token)
```

### stormforge-cli Metrics

The `stormforge-cli` exports the following metrics when enabled via the `PUSHGATEWAY_URL` environment variable or the `--metrics-output` flag:

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

## Standalone Environment

To utilize the `standalone` environment, you need to build a container image from the `Dockerfile` leveraging the `forge` CLI to launch a test case. The image will look for a test case definition (or will check to make sure it exists). Additionally, the image can introduce some JavaScript constants which can be referenced from the test case.

### Configuration

The image provides a number of environment variables that can be configured for the test run:

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

### Metrics

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

### Example: Standalone Kubernetes Manifest

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
