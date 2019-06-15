#!/usr/bin/env bash
DEPLOY_ENV=dev

cloudFormation()
{
    STACK_EXISTS=$(AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE --region "$AWS_REGION" | jq '.StackSummaries[].StackName//empty' | grep "$STACK_NAME")
    if [[ -z "$STACK_EXISTS" ]] || [[ "$STACK_EXISTS" == "" ]]; then
        AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws cloudformation create-stack --template-url https://"$S3_FOLDER".s3."$AWS_REGION".amazonaws.com/cf.yaml --stack-name "$STACK_NAME" --region "$AWS_REGION" --parameters ParameterKey=ServiceName,ParameterValue="$SERVICE_NAME" ParameterKey=BuildKey,ParameterValue="$SERVICE_NAME"/"$TRAVIS_BUILD_ID".zip ParameterKey=Environment,ParameterValue="$DEPLOY_ENV"  ParameterKey=BuildBucket,ParameterValue="$S3_FOLDER" --capabilities CAPABILITY_NAMED_IAM
    else
        AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws cloudformation update-stack --template-url https://"$S3_FOLDER".s3."$AWS_REGION".amazonaws.com/cf.yaml --stack-name "$STACK_NAME" --region "$AWS_REGION" --parameters ParameterKey=ServiceName,ParameterValue="$SERVICE_NAME" ParameterKey=BuildKey,ParameterValue="$SERVICE_NAME"/"$TRAVIS_BUILD_ID".zip ParameterKey=Environment,ParameterValue="$DEPLOY_ENV"  ParameterKey=BuildBucket,ParameterValue="$S3_FOLDER" --capabilities CAPABILITY_NAMED_IAM
    fi
}

deployIt()
{
    AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp cf.yaml s3://$S3_FOLDER/cf.yaml
    AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3 cp "$TRAVIS_BUILD_ID".zip s3://$S3_FOLDER/"$SERVICE_NAME"/"$TRAVIS_BUILD_ID".zip
}

if [[ -z "$TRAVIS_PULL_REQUEST" ]] || [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY
    S3_FOLDER=$DEV_S3_BUCKET

    echo "Deploy Dev"
    deployIt
    cloudFormation
    echo "Deployed Dev"

    # Master has an extra step to launch into live
    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
        AWS_ACCESS_KEY_ID=$LIVE_AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY=$LIVE_AWS_SECRET_ACCESS_KEY
        S3_FOLDER=$LIVE_S3_BUCKET
        DEPLOY_ENV=live

        echo "Deploy Live"
        deployIt
        cloudFormation
        echo "Deployed Live"
    fi
fi