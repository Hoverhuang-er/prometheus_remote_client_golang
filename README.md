# promremote

`promremote` is a Prometheus remote write client and libs written in Go.

## Installation

`go get -u github.com/Hoverhuang-er/prometheus_remote_client_golang`

## Use

`promremote` is used to send metrics to a Prometheus remote write endpoint such as supported by 
m3db, Prometheus, thanos, victoriaMetrics,InfluxDB and other TimeSeriesDB. It can be pulled into
an existing codebase as a client library or used as a cli tool (`cmd/main.go`) for ad hoc testing
purposes.

**IMPORTANT:** A running program or application that has a Prometheus remote write endpoint is required.

### Update

- 2024-06-01 Add loop mode and context mode, when loop mode greater than 1, the client will send remote write to enpoint every flag interval, and when context mode is not 0, the client will send remote write to endpoint with context time duration.
- 2024-05-31 Release v0.1.0, it both support client and cli. cli can be used to send metrics to a Prometheus remote write endpoint. download the binary from release page.
- 2024-05-30 Use hashicorp/go-retryablehttp instead of net/http for retryable http client and batch upgrate go mod dependencies.
- 2024-05-29 Switch go version from 1.14 to 1.22.3, and add Prometheus remote write URL to env variable support.

### Client library

To use `promremote` as a client library, the client must be constructed manually using structs.

```golang
// create config and client
cfg := promremote.NewConfig(
  promremote.WriteURLOption(writeURLFlag),
  promremote.HTTPClientTimeoutOption(60 * time.Second),
  promremote.UserAgent(userAgent),
)

client, err := promremote.NewClient(cfg)
if err != nil {
  log.Fatal(fmt.Errorf("unable to construct client: %v", err))
}


timeSeriesList := []promremote.TimeSeries{
		promremote.TimeSeries{
			Labels: []promremote.Label{
				{
					Name:  "__name__",
					Value: "foo_bar",
				},
				{
					Name:  "biz",
					Value: "baz",
				},
			},
			Datapoint: promremote.Datapoint{
				Timestamp: time.Now(),
				Value:     1415.92,
			},
		},
	}

if err := client.WriteTimeSeries(timeSeriesList); err != nil {
	log.Fatal(err)
}
```


### CLI

If one wants to use `promremote` as a CLI, he or she can utilize the tool located in the `cmd/`
directory. The tool takes in a series of labels and a datapoint then writes them to a Prometheus
remote write endpoint. Below is an example showing a metric with two labels
(`__name__:foo_bar` and `biz:baz`) and a datapoint (timestamp:`now` value:`1415.92`). And optional with context and loop


**Note**: One can either specify a Unix timestamp (e.g. `1556026725`) or the keyword `now` as the
first parameter in the `-d` flag.

#### Install & Run

```bash
go install github.com/Hoverhuang-er/prometheus_remote_client_golang/cmd/promremotecli
promremotecli -t=__name__:foo_bar -t=biz:baz -d=now,1415.92
```

#### mauanl run

- Run the CLI tool from the root of the repository with default flags.

```bash
go run cmd/promremotecli/main.go -t=__name__:foo_bar -t=biz:baz -d=now,1415.92
```

- Run the CLI tool from the root of the repository with custom flags.

```bash
go run cmd/promremotecli/main.go -t=__name__:foo_bar -t=biz:baz -d=now,1415.92 -u=http://localhost:9090/api/v1/write -c=30 -l=5
```

#### Download binary

Download the binary from the release page and run it.

```bash
wget https://github.com/Hoverhuang-er/prometheus_remote_client_golang/releases/download/v0.1.0/promremotecli_linux_amd64
mv promremotecli_linux_amd64 promremotecli
chmod +x promremotecli
mv promremotecli /usr/local/bin
```
Run the binary with default flags.
```bash
promremotecli -t=__name__:foo_bar -t=biz:baz -d=now,1415.92
```
Run the binary with custom flags.
```bash
promremotecli -t=__name__:foo_bar -t=biz:baz -d=now,1415.92 -u=http://localhost:9090/api/v1/write -c=30 -l=5
```