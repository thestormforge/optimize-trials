# StormForge Optimize - Trials

![Main](https://github.com/thestormforge/optimize-trials/workflows/Main/badge.svg)

This repository is a collection of container images suitable for use as trial jobs during an [Optimize Pro](https://docs.stormforge.io/optimize-pro/) experiment. Each trial job has specific requirements in terms of experiment setup, consult the individual container's documentation for more details.

## Trial Jobs

| Directory                                  | Trial Job Description |
|--------------------------------------------|-----------------------|
| [`blazemeter-cloud/`](./blazemeter-cloud/) | This trial job invokes a [BlazeMeter](https://www.blazemeter.com/) cloud-hosted performance test against your application, with each trial corresponding to a test run.
| [`jmeter/`](./jmeter/)                     | This trial job uses [JMeter](https://jmeter.apache.org/) to execute a test plan (`.jmx` file) to generate load for each Optimize Pro trial. |
| [`k6/`](./k6/)                             | This trial job uses [k6](https://k6.io) to execute a test script written in JavaScript to generate load for each Optimize Pro trial. |
| [`locust/`](./locust/)                     | This trial job executes a [Locust](https://locust.io/) load test written in Python to generate load for each Optimize Pro trial. |
| [`stormforge-perf/`](./stormforge-perf/)   | This trial job invokes a [StormForge Performance Testing](https://www.stormforge.io/performance-testing/) test case against your application, with each trial corresponding to a test run. |
