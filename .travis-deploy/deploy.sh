#!/usr/bin/env bash

BUCKET=$(aws s3api list-buckets | jq '.Buckets[].Name//empty' | grep "${S3_FOLDER}")

if [[ -z "$TRAVIS_PULL_REQUEST" ]] || [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY
    S3_FOLDER=$DEV_S3_BUCKET

    echo "Key: $AWS_ACCESS_KEY_ID"
    echo "Sec: $AWS_SECRET_ACCESS_KEY"

#    if [[ -z ${BUCKET} ]] || [[ ${BUCKET} == "" ]]; then
#        aws s3api

    aws s3 cp cf.yaml s3://${S3_FOLDER}/cf.yaml
    aws s3 cp authorizer.zip s3://${S3_FOLDER}/authorizer/authorizer.zip

# Master has an extra step to launch into live
    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
        AWS_ACCESS_KEY_ID=$LIVE_AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY=$LIVE_AWS_SECRET_ACCESS_KEY
        S3_FOLDER=$LIVE_S3_BUCKET

        aws s3 cp cf.yaml s3://${S3_FOLDER}/cf.yaml
        aws s3 cp authorizer.zip s3://${S3_FOLDER}/authorizer/authorizer.zip
    fi
fi
