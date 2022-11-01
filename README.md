# StormForge Optimize - Trials

![Main](https://github.com/thestormforge/optimize-trials/workflows/Main/badge.svg)

This repository is a collection of container images suitable for use as trial jobs during an [Optimize Pro](https://docs.stormforge.io/optimize-pro/) experiment. Each trial job has specific requirements in terms of experiment setup, consult the individual container's documentation for more details.

## Trial Jobs

| Directory                                | Trial Job Description |
|------------------------------------------|-----------------------|
| [`jmeter/`](./jmeter/)                   | |
| [`k6/`](./k6/)                           | |
| [`locust/`](./locust/)                   | |
| [`stormforge-perf/`](./stormforge-perf/) | |
### StormForge Performance

The StormForge Performance trial job invokes a [StormForge Performance](https://www.stormforge.io/performance-testing/) test case against your application, with each trial corresponding to a test run.

### Locust

The Locust trial job creates a [Locust](https://locust.io/) load test parametrized via environment variables.
