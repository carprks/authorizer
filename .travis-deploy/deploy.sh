#!/usr/bin/env bash

if [[ -z "$TRAVIS_PULL_REQUEST" ]] || [[ "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    AWS_ACCESS_KEY_ID=$DEV_AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY=$DEV_SECRET_ACCESS_KEY
    S3_FOLDER=$DEV_S3_FOLDER

    aws s3 cp cf.yaml s3://${S3_FOLDER}/cf.yaml
    aws s3 cp authorizer.zip s3://${S3_FOLDER}/authorizer/authorizer.zip

    if [[ "$TRAVIS_BRANCH" == "master" ]]; then
        AWS_ACCESS_KEY_ID=$LIVE_AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY=$LIVE_SECRET_ACCESS_KEY
        S3_FOLDER=$LIVE_S3_FOLDER

        aws s3 cp cf.yaml s3://${S3_FOLDER}/cf.yaml
        aws s3 cp authorizer.zip s3://${S3_FOLDER}/authorizer/authorizer.zip
    fi
fi
