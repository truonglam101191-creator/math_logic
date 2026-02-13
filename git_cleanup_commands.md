# Git Cleanup Commands - Chỉ giữ lại nhánh main

## 1. Checkout về nhánh main
git checkout main

## 2. Pull latest changes
git pull origin main

## 3. Xóa remote HEAD reference
git remote set-head origin --delete

## 4. Dọn dẹp remote tracking branches
git remote prune origin

## 5. Xóa tất cả local branches khác (trừ main)
git branch | grep -v "main" | grep -v "\*" | xargs -n 1 git branch -D

## 6. Force delete nếu cần thiết
# git branch -D <branch_name>

## 7. Kiểm tra kết quả
git branch -a

## 8. Nếu muốn xóa hoàn toàn origin/HEAD
git update-ref -d refs/remotes/origin/HEAD

## 9. Reset lại remote HEAD (optional)
# git remote set-head origin main

## 10. Hiển thị trạng thái cuối cùng
git status

# ==========================================
# Lệnh một dòng để thực hiện nhanh:
# ==========================================
# git checkout main && git pull origin main && git remote set-head origin --delete && git remote prune origin && git branch | grep -v "main" | grep -v "\*" | xargs -n 1 git branch -D