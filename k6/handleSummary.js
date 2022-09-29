/*
  Customize the end-of-test summary report to create a prometheus.txt file
  containing the primary metrics to be send to the Pushgateway.
 
  See https://k6.io/docs/results-visualization/end-of-test-summary/#customize-with-handlesummary

  TODO: metrics are not typed yet, submetrics are skipped, thresholds are not supported
*/
export function handleSummary(data) {
  outputFilename = __ENV.COMBINED_TEST_CASE_FILE || "prometheus.txt"

  function toPrometheus(data) {
    let out = ""
    for (const metricName in data.metrics) {
      const values = data.metrics[metricName].values;

      if (metricName.split(/\{/).length > 1) {
        continue
      }

      for (const metricKey in values) {
        const key = metricKey.replace(/\(|\)/g, "")
        out += `${metricName}_${key} ${values[metricKey]}\n`
      }
    }

    return out
  }

  return {
    outputFilename: toPrometheus(data)
  }
}
