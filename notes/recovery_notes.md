# RECONSTRUCTION NOTES

Sven generated a zip file with logs from the development server, an export of JSON content.

`Explore-logs-2024-02-11 19_19_05.json`

The following CLI gets into the list of log lines exported, and pulls out just the content of the line, ignoring the metadata around it:

```bash
cat SPISearchTests/Explore-logs-2024-02-11\ 19_19_05.json| jq '.[0]'
```

```JSON
{
  "line": "[ INFO ] SearchLogger: search: {\"query\":\"alamo\",\"searchID\":\"5194EE2C-FF08-495E-AE8E-2A470BFFC777\"} [component: server]\n",
  "timestamp": "1707119454282289170",
  "fields": {
    "component": "server",
    "filename": "/var/log/f656468e522e9184b4342d740bcf1ad4b43cb831e527246a30ce1e30b71c0b73/f656468e522e9184b4342d740bcf1ad4b43cb831e527246a30ce1e30b71c0b73-json.log",
    "job": "containers",
    "stream": "stdout"
  }
}
```

```bash
cat Explore-logs-2024-02-11\ 19_19_05.json | jq '.[].line'
```

Extend this further to only grab the lines from the SearchLogger:

```bash
cat Explore-logs-2024-02-11\ 19_19_05.json | jq '.[].line' | grep "SearchLogger"
```

^^ the above includes logs from the Loki system that was querying for these logs (a bit of log inception), so we can narrow this down further:

```bash
cat Explore-logs-2024-02-11\ 19_19_05.json | jq '.[].line' | grep "\[ INFO \] SearchLogger"
```

This gives a more sensible queue of values that we can use to reconstruct. They're still quoted strings, but at least we can work to pull that back out from the top-level JSON that was provided.

```bash
"[ INFO ] SearchLogger: search: {\"query\":\"test\",\"searchID\":\"FB081B23-8199-42D7-AF5B-B5659F438317\"} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[0]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"author\":{\"_0\":{\"name\":\"NoTests\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[1]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"author\":{\"_0\":{\"name\":\"XCTestHTMLReport\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[2]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"snapshot-testing\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[3]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"testing\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[4]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"xctestcase\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[5]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"testability\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[6]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"test-driven-development\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[7]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"uitest\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[8]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"uitests\"}}}} [component: server]\n"
"[ INFO ] SearchLogger: searchresult[9]: {\"id\":\"FB081B23-8199-42D7-AF5B-B5659F438317\",\"r\":{\"keyword\":{\"_0\":{\"keyword\":\"xcuitest\"}}}} [component: server]\n"
```