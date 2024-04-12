#!/bin/bash -e
SEP=""
PROJECTS=""
for i in `find -name '*Test.java' -type f | egrep -v './(testsuite|quarkus|docs)/' | sed 's|/src/test/java/.*||' | sort | uniq | sed 's|./||'`; do
    PROJECTS="$PROJECTS$SEP$i"
    SEP=","
done

./mvnw test -pl "$PROJECTS" -am