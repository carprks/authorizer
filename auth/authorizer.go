package auth

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/carprks/authorizer/auth/policy"
	"github.com/carprks/authorizer/auth/validator"
	"os"
	"strings"
)

// Handler process request
func Handler(ctx context.Context, event events.APIGatewayCustomAuthorizerRequestTypeRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
	token := ""

	authHeader := strings.ToLower(os.Getenv("AUTH_HEADER"))
	for Key, Value := range event.Headers {
		key := strings.ToLower(Key)
		if key == authHeader {
			token = Value
		}
	}

	// Token sent
	fmt.Println(fmt.Sprintf("AUTH Key: %s", token))
	fmt.Println(fmt.Sprintf("Event: %v", event))

	// Test token
	if strings.Contains(token, os.Getenv("AUTH_PREFIX")) {
		if validator.Key(token) {
			fmt.Println(fmt.Sprintf("allowed: %s", token))
			return policy.GenerateAllow(event), nil
		}
		fmt.Println(fmt.Sprintf("denied: %s", token))
		return policy.GenerateDeny(event), nil
	}

	return events.APIGatewayCustomAuthorizerResponse{}, fmt.Errorf("%s", "Unauthorized")
}
