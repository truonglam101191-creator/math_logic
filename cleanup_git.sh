#!/bin/bash

# Script để dọn dẹp Git repository - chỉ giữ lại nhánh main

echo "🧹 Cleaning up Git repository..."

# 1. Checkout về nhánh main
git checkout main

# 2. Pull latest changes từ origin
git pull origin main

# 3. Xóa tất cả các nhánh local khác (ngoại trừ main)
echo "Deleting local branches (except main)..."
git branch | grep -v "main" | grep -v "\*" | xargs -n 1 git branch -D

# 4. Xóa tất cả remote tracking branches (ngoại trừ main)
echo "Cleaning up remote tracking branches..."
git remote prune origin

# 5. Xóa remote HEAD reference
echo "Removing remote HEAD reference..."
git remote set-head origin --delete

# 6. Chỉ track nhánh main từ origin
echo "Setting up clean main branch tracking..."
git branch --set-upstream-to=origin/main main

# 7. Hiển thị trạng thái sau khi dọn dẹp
echo "✅ Cleanup completed!"
echo ""
echo "Current branches:"
git branch -a

echo ""
echo "Current status:"
git status