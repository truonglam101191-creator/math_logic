#!/bin/bash
# Fix git push main branch conflict

# cd /Users/apple/Desktop/Projects/profersional/logic_mathematics
# chmod +x fix_git_push.sh
# ./fix_git_push.sh


# cd /Users/softozi/Desktop/my/logic_mathematics
# chmod +x fix_git_push.sh
# ./fix_git_push.sh


echo "🔍 Checking current git status..."
git status

echo "📋 Listing all branches..."
git branch -a

echo "🏷️ Checking current branch..."
git rev-parse --abbrev-ref HEAD

echo "🧹 Cleaning up any conflicts..."
# Delete any conflicting main branch references
git branch -D main 2>/dev/null || echo "No local main branch to delete"

# Remove any ambiguous refs
git update-ref -d refs/remotes/origin/main 2>/dev/null || echo "No remote main ref to delete"

echo "🔄 Pushing to origin main..."
# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $CURRENT_BRANCH"

# Push current branch to origin main explicitly
git push origin $CURRENT_BRANCH:refs/heads/main

# Set upstream
git branch --set-upstream-to=origin/main $CURRENT_BRANCH

echo "✅ Push completed!"