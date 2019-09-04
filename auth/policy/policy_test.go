package policy_test

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/carprks/authorizer/auth/policy"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
	"os"
	"testing"
)

func TestGenerateAllow(t *testing.T) {
	if len(os.Args) >= 1 {
		for _, env := range os.Args {
			if env == "localDev" {
				err := godotenv.Load()
				if err != nil {
					fmt.Println(fmt.Sprintf("godotenv err: %v", err))
				}
			}
		}
	}

	tests := []struct {
		request events.APIGatewayCustomAuthorizerRequest
		expect  events.APIGatewayCustomAuthorizerResponse
	}{
		{
			request: events.APIGatewayCustomAuthorizerRequest{
				Type:               "TOKEN",
				AuthorizationToken: "tester-37259d99-5747-4feb-9261-2764c8cfc326",
				MethodArn:          "arn:aws:execute-api:eu-west-2:123456789:wmcwzleu0i/ESTestInvoke-stage/GET/",
			},
			expect: events.APIGatewayCustomAuthorizerResponse{
				PrincipalID: "system",
				PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
					Version: "2012-10-17",
					Statement: []events.IAMPolicyStatement{
						{
							Action:   []string{"execute-api:Invoke"},
							Effect:   "Allow",
							Resource: []string{"arn:aws:execute-api:eu-west-2:123456789:wmcwzleu0i/ESTestInvoke-stage/GET/"},
						},
					},
				},
				Context: map[string]interface{}{
					"booleanKey": true,
					"numberKey":  123,
					"stringKey":  "stringval",
				},
			},
		},
	}

	for _, test := range tests {
		resp := policy.GenerateAllow(test.request)
		assert.IsType(t, test.expect, resp)
		assert.Equal(t, test.expect, resp)
	}
}

func TestGenerateDeny(t *testing.T) {
	if len(os.Args) >= 1 {
		for _, env := range os.Args {
			if env == "localDev" {
				err := godotenv.Load()
				if err != nil {
					fmt.Println(fmt.Sprintf("godotenv err: %v", err))
				}
			}
		}
	}

	tests := []struct {
		request events.APIGatewayCustomAuthorizerRequest
		expect  events.APIGatewayCustomAuthorizerResponse
	}{
		{
			request: events.APIGatewayCustomAuthorizerRequest{
				Type:               "TOKEN",
				AuthorizationToken: "tester-37259d99-5747-4feb-9261-2764c8cfc326",
				MethodArn:          "arn:aws:execute-api:eu-west-2:123456789:wmcwzleu0i/ESTestInvoke-stage/GET/",
			},
			expect: events.APIGatewayCustomAuthorizerResponse{
				PrincipalID: "system",
				PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
					Version: "2012-10-17",
					Statement: []events.IAMPolicyStatement{
						{
							Action:   []string{"execute-api:Invoke"},
							Effect:   "Deny",
							Resource: []string{"arn:aws:execute-api:eu-west-2:123456789:wmcwzleu0i/ESTestInvoke-stage/GET/"},
						},
					},
				},
				Context: map[string]interface{}{
					"booleanKey": true,
					"numberKey":  123,
					"stringKey":  "stringval",
				},
			},
		},
	}

	for _, test := range tests {
		resp := policy.GenerateDeny(test.request)
		assert.IsType(t, test.expect, resp)
		assert.Equal(t, test.expect, resp)
	}
}
