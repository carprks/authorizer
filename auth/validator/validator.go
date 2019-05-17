package validator

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"os"
	"time"
)

// KeyData object
type KeyData struct {
	Key        string `json:"key"`
	ExpireTime int    `json:"expires"`
}

func matchKey(key string) KeyData {
	s, err := session.NewSession(&aws.Config{
		Region:   aws.String(os.Getenv("AWS_DB_REGION")),
		Endpoint: aws.String(os.Getenv("AWS_DB_ENDPOINT")),
	})
	if err != nil {
		fmt.Println(fmt.Sprintf("Key Session Error: %v", err))
		return KeyData{}
	}
	svc := dynamodb.New(s)
	result, err := svc.GetItem(&dynamodb.GetItemInput{
		Key: map[string]*dynamodb.AttributeValue{
			"key": {
				S: aws.String(key),
			},
		},
		TableName: aws.String(os.Getenv("AWS_DB_TABLE")),
	})
	if err != nil {
		fmt.Println(fmt.Sprintf("Key Get Error: %v", err))
		return KeyData{}
	}
	returnData := KeyData{}
	unErr := dynamodbattribute.UnmarshalMap(result.Item, &returnData)
	if unErr != nil {
		fmt.Println(fmt.Sprintf("Key Unmarshall Error: %v", unErr))
		return KeyData{}
	}

	return returnData
}

func (k KeyData) validKey() bool {
	t := time.Now().Unix()
	if int(t) <= k.ExpireTime {
		return true
	}

	return false
}

// Key validate the key
func Key(key string) bool {
	return matchKey(key).validKey()
}
