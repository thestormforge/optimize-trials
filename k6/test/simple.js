import http from 'k6/http'

export default function () {
  const target = __ENV.SF_K6_TARGET
  
  http.get(`${target}/?delay=500`, {
    tags: {
      my_tag: "hello"
    }
  })
}