#!/bin/bash -e

./mvnw clean install ${SUREFIRE_RETRY} \
-Pauth-server-quarkus -Pdb-${DATABASE} -Pauth-server-migration \
-Dtest=MigrationTest \
-Dmigration.mode=auto \
-Dmigrated.auth.server.version=${OLD_VERSION} \
-Dmigration.import.file.name=migration-realm-${OLD_VERSION}.json \
-Dauth.server.ssl.required=false \
-Dauth.server.db.host=localhost \
-f testsuite/integration-arquillian/pom.xml 2>&1 | misc/log/trimmer.sh