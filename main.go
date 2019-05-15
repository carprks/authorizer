package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/carprks/authorizer/auth"
)

func main() {
	lambda.Start(auth.Handler)
}
