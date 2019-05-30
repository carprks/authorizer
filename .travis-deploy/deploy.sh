#!/usr/bin/env bash
if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    if [ "$TRAVIS_BRANCH" == "master" ]; then
       pip install --user awscli
       export PATH=$PATH:$HOME/.local/bin
       aws cloudformation package --template-file template.yaml --s3-bucket=$S3_BUCKET --output-template-file outputtemplate.yml
    fi
fi