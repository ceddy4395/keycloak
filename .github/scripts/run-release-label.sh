#!/bin/bash -e

echo "Base REF:   $GITHUB_BASE_REF"
echo "**Branch:** [$GITHUB_BASE_REF](https://github.com/$GITHUB_REPOSITORY/tree/$GITHUB_BASE_REF)" >> $GITHUB_STEP_SUMMARY
echo "PR:         https://github.com/$GITHUB_REPOSITORY/pull/$PR_NUMBER"
echo "**PR:** [$PR_NUMBER](https://github.com/$GITHUB_REPOSITORY/pull/$PR_NUMBER)" >> $GITHUB_STEP_SUMMARY

if [ "$GITHUB_BASE_REF" == "main" ]; then
    LAST_MAJOR="$(gh api /repos/$GITHUB_REPOSITORY/branches --paginate --jq .[].name | grep '^release/' | cut -d '/' -f 2 | cut -d '.' -f 1 | sort -n -r | head -n 1)"
    NEXT_MAJOR="$(($LAST_MAJOR + 1))"
    LABEL="release/$NEXT_MAJOR.0.0"
    BACKPORT_LABEL="backport/main"
elif [[ "$GITHUB_BASE_REF" = release/* ]]; then
    MAJOR_MINOR="$(echo $GITHUB_BASE_REF | cut -d '/' -f 2)"
    LAST_MICRO="$(gh api /repos/$GITHUB_REPOSITORY/tags --jq .[].name | sort -n -r | grep $MAJOR_MINOR | head -n 1 | cut -d '.' -f 3)"
    NEXT_MICRO="$(($LAST_MICRO + 1))"
    LABEL="release/$MAJOR_MINOR.$NEXT_MICRO"
    BACKPORT_LABEL="backport/$MAJOR_MINOR"
fi

echo "Label:      $LABEL"
echo "**Label:** [$LABEL](https://github.com/$GITHUB_REPOSITORY/labels/$(echo $LABEL | sed 's|/|%2F|g'))" >> $GITHUB_STEP_SUMMARY

gh api "repos/$GITHUB_REPOSITORY/labels/$(echo $LABEL | sed 's|/|%2F|g')" --silent 2>/dev/null || gh label create -R "$GITHUB_REPOSITORY" "$LABEL" -c "0E8A16"

echo ""
echo "" >> $GITHUB_STEP_SUMMARY
echo "Updating issues:"
echo "**Updating issues:**" >> $GITHUB_STEP_SUMMARY

ISSUES=$(.github/scripts/pr-find-issues.sh "$PR_NUMBER" "$GITHUB_REPOSITORY")
for ISSUE in $ISSUES; do
    gh issue edit "$ISSUE" -R "$GITHUB_REPOSITORY" --add-label "$LABEL" --remove-label "$BACKPORT_LABEL"
    echo "* [$ISSUE](https://github.com/$GITHUB_REPOSITORY/issues/$ISSUE)" >> $GITHUB_STEP_SUMMARY
done