package policy

import "github.com/aws/aws-lambda-go/events"

func generatePolicy(PrincipalID, effect, resource string) events.APIGatewayCustomAuthorizerResponse {
	authResponse := events.APIGatewayCustomAuthorizerResponse{
		PrincipalID: PrincipalID,
	}

	if effect != "" && resource != "" {
		authResponse.PolicyDocument = events.APIGatewayCustomAuthorizerPolicy{
			Version: "2012-10-17",
			Statement: []events.IAMPolicyStatement{
				{
					Action: []string{
						"execute-api:Invoke",
					},
					Effect: effect,
					Resource: []string{
						resource,
					},
				},
			},
		}
	}

	authResponse.Context = map[string]interface{}{
		"stringKey":  "stringval",
		"numberKey":  123,
		"booleanKey": true,
	}

	return authResponse
}

// GenerateDeny self explanatory
func GenerateDeny(ev events.APIGatewayCustomAuthorizerRequestTypeRequest) events.APIGatewayCustomAuthorizerResponse {
	return generatePolicy("user", "Deny", ev.MethodArn)
}

// GenerateAllow self explanatory
func GenerateAllow(ev events.APIGatewayCustomAuthorizerRequestTypeRequest) events.APIGatewayCustomAuthorizerResponse {
	return generatePolicy("user", "Allow", ev.MethodArn)
}
