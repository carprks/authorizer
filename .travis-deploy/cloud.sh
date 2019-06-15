#!/usr/bin/env bash

authExists=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --region $AWS_REGION | jq '.StackSummaries[].StackName//empty' | grep "$STACK_NAME")
DEPLOY_ENV=dev

if [[ -z "$TRAVIS_PULL_REQUEST" ]] || [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY
    S3_FOLDER=$DEV_S3_BUCKET

    echo "Deploy Dev"
    if [[ -z ${authExists} ]] || [[ ${authExists} == "" ]]; then
        AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY aws cloudformation create-stack --template-url s3://${S3_FOLDER}/cf.yaml --stack-name $STACK_NAME --region $AWS_REGION --parameters ParameterKey=ServiceName,ParameterValue=authorizer ParameterKey=BuildKey,ParameterValue=authorizer/authorizer.zip ParameterKey=Environment,ParameterValue=${DEPLOY_ENV}  ParameterKey=BuildBucket,ParameterValue=${S3_FOLDER} --capabilities CAPABILITY_NAMED_IAM
    else
        AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY aws cloudformation update-stack --template-url s3://${S3_FOLDER}/cf.yaml --stack-name $STACK_NAME --region $AWS_REGION --parameters ParameterKey=ServiceName,ParameterValue=authorizer ParameterKey=BuildKey,ParameterValue=authorizer/authorizer.zip ParameterKey=Environment,ParameterValue=${DEPLOY_ENV}  ParameterKey=BuildBucket,ParameterValue=${S3_FOLDER}
    fi
    echo "Deployed Dev"

# Master has an extra step to launch into live
    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
        AWS_ACCESS_KEY_ID=$LIVE_AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY=$LIVE_AWS_SECRET_ACCESS_KEY
        S3_FOLDER=$LIVE_S3_BUCKET
        DEPLOY_ENV=live

        echo "Deploy Live"
        if [[ -z ${authExists} ]] || [[ ${authExists} == "" ]]; then
            AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY aws cloudformation create-stack --template-url s3://${S3_FOLDER}/cf.yaml --stack-name $STACK_NAME --region $AWS_REGION --parameters ParameterKey=ServiceName,ParameterValue=authorizer ParameterKey=BuildKey,ParameterValue=authorizer/authorizer.zip ParameterKey=Environment,ParameterValue=${DEPLOY_ENV}  ParameterKey=BuildBucket,ParameterValue=${S3_FOLDER} --capabilities CAPABILITY_NAMED_IAM
        else
            AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY aws cloudformation update-stack --template-url s3://${S3_FOLDER}/cf.yaml --stack-name $STACK_NAME --region $AWS_REGION --parameters ParameterKey=ServiceName,ParameterValue=authorizer ParameterKey=BuildKey,ParameterValue=authorizer/authorizer.zip ParameterKey=Environment,ParameterValue=${DEPLOY_ENV}  ParameterKey=BuildBucket,ParameterValue=${S3_FOLDER}
        fi
        echo "Deployed Live"
    fi
fi
