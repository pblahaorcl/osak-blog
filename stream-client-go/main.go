package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"strconv"
	"time"

	"github.com/oracle/oci-go-sdk/v65/common"
	"github.com/oracle/oci-go-sdk/v65/streaming"
)

var (
	endpoint   string
	streamOcid string
	producer   bool
	groupName  string = "OsakDemo"
)

// Payload defines message schema
type Payload struct {
	Id        int       `json:"key"`   // Unique identifier
	EventType string    `json:"type"`  // Type of message
	TimeStamp time.Time `json:"ts"`    // Creation time
	Message   string    `json:"value"` // Message value
}

func main() {
	flag.StringVar(&endpoint, "endpoint", "https://cell-1.streaming.us-phoenix-1.oci.oraclecloud.com", "Streaming end point")
	flag.StringVar(&streamOcid, "streamId", "ocid1.stream.oc1.phx.amaaaaaayrywvyya5avpkjd7qrbotwjmt5qczeajmco2y736gwbfegqeknpq", "Streaming ocid")
	flag.BoolVar(&producer, "p", false, "Producer")
	flag.Parse()
	// setup OCI streaming client with user principal and default configuration
	// from $HOME/.oci/config
	c, err := streaming.NewStreamClientWithConfigurationProvider(common.DefaultConfigProvider(),
		endpoint)
	if err != nil {
		log.Fatal(err)
	}
	if producer {
		emitMessages(c)
	} else {
		consumeMessages(c)
	}
}

// emitMessages produces new messages
func emitMessages(c streaming.StreamClient) {
	i := 0
	for {
		i++
		p := Payload{
			Id:        i,
			EventType: "demo",
			TimeStamp: time.Now(),
			Message:   "msg_" + strconv.Itoa(i),
		}
		b, _ := json.Marshal(p)
		m := streaming.PutMessagesRequest{
			StreamId: &streamOcid,
			PutMessagesDetails: streaming.PutMessagesDetails{
				Messages: []streaming.PutMessagesDetailsEntry{
					{
						Key:   []byte(strconv.Itoa(i)),
						Value: b,
					},
				},
			},
		}
		r, err := c.PutMessages(context.Background(), m)
		if err != nil {
			log.Printf("error: %s", err)
		}
		log.Println(r.PutMessagesResult)
		time.Sleep(time.Second * 1)
	}
}

// consumeMessages consumes messages from Stream with 5 sec sleep
func consumeMessages(c streaming.StreamClient) {
	cursorRequest := streaming.CreateGroupCursorRequest{
		StreamId: &streamOcid,
		CreateGroupCursorDetails: streaming.CreateGroupCursorDetails{
			Type:      streaming.CreateGroupCursorDetailsTypeTrimHorizon,
			GroupName: &groupName,
		},
	}
	cursor, err := c.CreateGroupCursor(context.Background(), cursorRequest)
	if err != nil {
		log.Fatal(err)
	}
	request := streaming.GetMessagesRequest{StreamId: &streamOcid,
		Cursor: cursor.Value}

	p := Payload{}
	for {
		r, err := c.GetMessages(context.Background(), request)
		if err != nil {
			fmt.Println("Error", err)
		}
		for _, m := range r.Items {
			json.Unmarshal(m.Value, &p)
			log.Printf("{id=%d,ts=%s} \n", p.Id, p.TimeStamp)
		}
		request.Cursor = r.OpcNextCursor
		time.Sleep(time.Second * 5)
	}
}
