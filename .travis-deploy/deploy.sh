#!/usr/bin/env bash

BUCKET=$(aws s3api list-buckets | jq '.Buckets[].Name//empty' | grep "${S3_FOLDER}")

if [[ -z "$TRAVIS_PULL_REQUEST" ]] || [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY=$DEV_AWS_SECRET_ACCESS_KEY
    S3_FOLDER=$DEV_S3_BUCKET

#    if [[ -z ${BUCKET} ]] || [[ ${BUCKET} == "" ]]; then
#        aws s3api

    mkdir .aws
    echo "[default]" >> .aws/credentials
    echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> .aws/credentials
    echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> .aws/credentials

    aws s3 cp cf.yaml s3://${S3_FOLDER}/cf.yaml
    aws s3 cp authorizer.zip s3://${S3_FOLDER}/authorizer/authorizer.zip

# Master has an extra step to launch into live
    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
        AWS_ACCESS_KEY_ID=$LIVE_AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY=$LIVE_AWS_SECRET_ACCESS_KEY
        S3_FOLDER=$LIVE_S3_BUCKET

        rm -rf .aws
        mkdir .aws
        echo "[default]" >> .aws/credentials
        echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> .aws/credentials
        echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> .aws/credentials

        aws s3 cp cf.yaml s3://${S3_FOLDER}/cf.yaml
        aws s3 cp authorizer.zip s3://${S3_FOLDER}/authorizer/authorizer.zip
    fi
fi
