#!/bin/bash -e

PROPS="-Dauth.server.db.host=${ENDPOINT}"
PROPS+=" -Dkeycloak.connectionsJpa.password=${PASSWORD}"

curl --fail-with-body https://truststore.pki.rds.amazonaws.com/${REGION}/${REGION}-bundle.pem -o aws.pem
PROPS+=" -Dkeycloak.connectionsJpa.jdbcParameters=\"?ssl=true&sslmode=verify-ca&sslrootcert=/opt/keycloak/aws.pem\""

TESTS=`testsuite/integration-arquillian/tests/base/testsuites/suite.sh database`
echo "Tests: $TESTS"

git archive --format=zip --output /tmp/keycloak.zip $GITHUB_REF
zip -u /tmp/keycloak.zip aws.pem

cd .github/scripts/ansible
export CLUSTER_NAME=keycloak_$(git rev-parse --short HEAD)
echo "ec2_cluster=${CLUSTER_NAME}" >> $GITHUB_OUTPUT
./aws_ec2.sh requirements
./aws_ec2.sh create ${REGION}
./keycloak_ec2_installer.sh ${REGION} /tmp/keycloak.zip
./mvn_ec2_runner.sh ${REGION} "clean install -B -DskipTests -Pdistribution"
./mvn_ec2_runner.sh ${REGION} "clean install -B -DskipTests -pl testsuite/integration-arquillian/servers/auth-server/quarkus -Pauth-server-quarkus -Pdb-aurora-postgres -Dmaven.build.cache.enabled=true"
./mvn_ec2_runner.sh ${REGION} "test -B ${SUREFIRE_RETRY} -Pauth-server-quarkus -Pdb-${DB} $PROPS -Dtest=$TESTS -pl testsuite/integration-arquillian/tests/base 2>&1 | misc/log/trimmer.sh"

# Copy returned surefire-report directories to workspace root to ensure they're discovered
results=(files/keycloak/results/*)
rsync -a $results/* ../../../
rm -rf $results
