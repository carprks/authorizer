package auth

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/carprks/authorizer/auth/policy"
	"github.com/carprks/authorizer/auth/validator"
	"os"
	"strings"
)

// Handler process request
func Handler(event events.APIGatewayCustomAuthorizerRequestTypeRequest) (events.APIGatewayCustomAuthorizerResponse) {
	token := ""

	authHeader := strings.ToLower(os.Getenv("AUTH_HEADER"))
	for Key, Value := range event.Headers {
		key := strings.ToLower(Key)
		if key == authHeader {
			token = Value
		}
	}

	if strings.Contains(token, os.Getenv("AUTH_PREFIX")) {
		if validator.Key(token) {
			return policy.GenerateAllow(event)
		}
	}

	return policy.GenerateDeny(event)
}