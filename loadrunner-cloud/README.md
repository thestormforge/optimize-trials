# LoadRunner Cloud Trial Image

This trial image contains the LoadRunner Java CLI, which can be found [here](https://admhelp.microfocus.com/lrc/en/2022.06/Content/Storm/t_cli_tools.htm).

## Prerequisites

* [Micro Focus's LoadRunner Cloud](https://www.microfocus.com/en-us/products/loadrunner-cloud/overview) license and credentials (to be used for `LOADRUNNER_CLOUD_CONNECT` like `connect=MyUsername:Mypwd or MyClientId:MyClientSecret`, see below.)
* TODO: …

## Configuration

| Environment Variable | Description |
| -------------------- | ----------- |
| `LOADRUNNER_CLOUD_CONNECT`        | Your credentials to log into LoadRunner Cloud. |
| `LOADRUNNER_CLOUD_HOST`    | The URL of your LoadRunner Cloud tenant. |
| `LOADRUNNER_CLOUD_TENANTID`    | Your tenant id, specified in your LoadRunner Cloud URL. |
| `LOADRUNNER_CLOUD_TESTID`    | The ID of the test. |

## Metrics

TODO: …

## Example Kubernetes Manifest

TODO: …