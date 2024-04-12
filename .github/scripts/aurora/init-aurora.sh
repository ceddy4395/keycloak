#!/bin/bash -e

AWS_REGION=us-east-1
echo "Region: ${AWS_REGION}"

aws configure set aws_access_key_id ${secrets.AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${secrets.AWS_SECRET_ACCESS_KEY}
aws configure set region ${AWS_REGION}
PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
echo "::add-mask::${PASS}"

echo "name=gh-action-$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT
echo "password=${PASS}" >> $GITHUB_OUTPUT
echo "region=${AWS_REGION}" >> $GITHUB_OUTPUT