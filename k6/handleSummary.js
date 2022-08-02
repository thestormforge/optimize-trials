
export function handleSummary(data) {
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
    'prometheus.txt': toPrometheus(data)
  }
}
