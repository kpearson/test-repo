#!/bin/sh

set -o nounset
set -o errexit
set -o xtrace
set -o pipefail

BRANCHES=$1

for TARGET_BRANCH in $BRANCHES; do
  git push origin HEAD:"$TARGET_BRANCH" > /tmp/git-log 2>&1

  if [ "$?" -ne 0 ]; then
    PULL_REQUEST_LINK="https://github.com/ncmdev/$CIRCLE_PROJECT_REPONAME/pull/new/$TARGET_BRANCH...master"
    ERROR_LOG=$(cat /tmp/git-log)

    curl -H 'Content-type: application/json' \
      --data \
      "{ \
      \"attachments\": [ \
      { \
        \"text\": \"It's likley that there is maerge conflict when merging the 'master' branch into the *"$TARGET_BRANCH"* branch\nError: \`\`\`\n $ERROR_LOG \n\`\`\`  \", \
        \"title\": \"Deploy auto merge failed\", \
        \"actions\": [ \
        { \
          \"type\": \"button\", \
          \"text\": \"Create Pull Request\", \
          \"url\": \"$PULL_REQUEST_LINK\" \
        } \
        ], \
        \"color\": \"ff0000\" \
      } \
      ] \
    }" "$SLACK_WEBHOOK"
  fi
done
