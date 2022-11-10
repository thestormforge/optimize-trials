# Tricentis NeoLoad Trial Image

The [Tricentis NeoLoad](https://www.tricentis.com/products/performance-testing-neoload) trial job enables you to use NeoLoad performance tests in your Optimize Pro experiments.
It utilizes a customer container image, based on the [`python:3.10-bullseye`](https://hub.docker.com/_/python) base container and the [official NeoLoad CLI utility](https://github.com/Neotys-Labs/neoload-cli).

## Usage

- Create a NeoLoad access token.
- Configure the environment variables shown in the next section for your trial job in your `experiment.yaml`
- Configure Trial to use either `prometheus` setupTask or manually define `PUSHGATEWAY_URL`.

## Configuration

| Environment Variable | Description | Default value | 
| -------------------- | ----------- |---------------|
| `SCENARIO`           | Scenario from NeoLoad Project to use | `StormForgeScenario` |
| `TEST_NAME`          | Test result naming pattern | `SF-$(uuidgen)` |
| `TEST_FILE`          | Zip or YAML test file to use (will be uploaded to Neoload SaaS) | none |
| `ZONE`               | NeoLoad controller zone to use | `USEGCP`
| `LGS`                | Number of load generators to use | `2`
| `NEOLOAD_TOKEN`      | NeoLoad authentication token | none |
| `PUSHGATEWAY_URL`    | The URL used to push NeoLoad test run metrics. If not explicitly set, the Optimize controller will set it. |

## Metrics

Metrics are extracted from the NeoLoad test report using the built-in transactions-csv template to produce a CSV file.
This file contains calculated statistics based on all requests executed in the test.

| Name | Example Value | Description |
| ---- | ------------- | ----------- |
| `request_count` | 81323 | total number of requests performed | 
| `average_response_time` | 0.1387 | average response time (seconds) |
| `max_response_time` | 0.2578 | maximum response time (seconds) |
| `min_response_time` | 0.0879 | minimum response time (seconds) |
| `p50` | 0.145 | 50th percentile for response time (seconds) |
| `p90` | 0.184 | 90th percentile for response time (seconds) |
| `p95` | 0.186 | 95th percentile for response time (seconds) |
| `p99` | 0.189 | 99th percentile for response time (seconds) |

## Example Kubernetes Manifest


The following Kubernetes `Job` manifest excerpt, `ConfigMap`, and `Secret` illustrate how you might use this trial job container in your Optimize Pro `experiment.yaml`.

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
      - name: neoload
        image: thestormforge/optimize-trials:latest-blazemeter-cloud
        env:
        - name: TEST_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: LGS
          value: "5"
        - name: TEST_FILE
          value: /tmp/neoload-files/neoload-stormforge.yaml
        - name: NEOLOAD_TOKEN
          valueFrom:
            secretKeyRef:
              name: neoload-token
              key: token
        volumeMounts:
        - name: test-case-file
          readOnly: true
          mountPath: /tmp/neoload-files
    volumes:
      - name: test-case-file
        configMap:
          name: neoload-artifacts
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: neoload-artifacts
data:
  neoload-stormforge.yaml: |
    name: Loadtest Party
    user_paths:
    - name: sf-path
      actions:
        steps:
          - transaction:
              name: Transaction1
              description: loadtest party
              steps:
              - request:
                  url: http://TARGET_SERVER/
              - request:
                  url: /
                  server: TARGET_SERVER
                  method: GET

    populations:
    - name: pop1
      user_paths:
      - name: sf-path

    scenarios:
    - name: StormForgeScenario
      populations:
      - name: pop1
        rampup_load:
          min_users: 20
          max_users: 100
          increment_users: 2
          increment_every: 1s
          duration: 5m
---
apiVersion: v1
kind: Secret
metadata:
  name: neoload-token
data:
  token: XXX-XXX-XXX-XXX
```

NOTE: If you are using this in an experiment, keep in mind that some values are set automatically. In particular, the `backoffLimit`, `restartPolicy`, and `PUSHGATEWAY_URL` environment variable are all introduced when evaluating a trial's job template. `PUSHGATEWAY_URL` requires the usage of the [`prometheus` `setupTask`](https://docs.stormforge.io/optimize-pro/concepts/trials/#prometheus) though.
