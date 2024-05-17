## OCI Streaming clients

Produces and Consumes testing messages in OCI Streaming with following json scheme:
```
type Payload struct {
	Id        int       `json:"key"`   // Unique identifier
	EventType string    `json:"type"`  // Type of message
	TimeStamp time.Time `json:"ts"`    // Creation time
	Message   string    `json:"value"` // Message value
}
```

### Build
```
make
```

### Supported options
```
Usage of ./stream-client-go-darwin-amd64:
  -endpoint string
    	Streaming end point (default "https://cell-1.streaming.us-phoenix-1.oci.oraclecloud.com")
  -p	Producer
  -streamId string
    	Streaming ocid (default "ocid1.stream.oc1.phx.amaaaaaayrywvyya5avpkjd7qrbotwjmt5qczeajmco2y736gwbfegqeknpq")
```

### Examples
* Run producer as `./bin/stream-client-go-darwin-amd64 -p -streamId Bar`
* Run consumer as `./bin/stream-client-go-darwin-amd64 -streamId Bar`

### Prerequisties
* Installed and configured go and development environemnt with make
* Created OCI tenancy with created OCI Streaming instance
* Configured OCI user as documented [here](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs)
