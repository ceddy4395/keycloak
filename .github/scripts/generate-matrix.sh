#!/bin/bash -e

STORES="postgres, mysql, oracle, mssql, mariadb"
if [[ $GITHUB_EVENT_NAME != "pull_request" && -n "$AWS_SECRET_ACCESS_KEY" ]]; then
    STORES+=", aurora-postgres"
fi
echo "matrix=$(echo $STORES  | jq -Rc 'split(", ")')" >> $GITHUB_OUTPUT