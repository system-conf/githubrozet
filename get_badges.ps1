
# GitHub Badges Automation Script - Retry Mode

Write-Host "Starting GitHub Badge Automation (Retry)..." -ForegroundColor Green
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Add GitHub CLI to Path for this session
$env:Path += ";C:\Program Files\GitHub CLI"

# Check if gh is available
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) not found even after adding to path. Please check installation."
    exit 1
}

# Ensure we are in the repo root
if (-not (Test-Path ".git")) {
    Write-Error "Please run this script from the root of the git repository."
    exit 1
}

# 1. Quickdraw: Create an issue and close it immediately
Write-Host "Attempting Quickdraw (Issue -> Close < 5 mins)..." -ForegroundColor Cyan
$issueTitle = "Quickdraw Test $timestamp"
$issueUrl = gh issue create --title $issueTitle --body "Testing for Quickdraw badge"
if ($issueUrl -and $issueUrl -match "https://") {
    $issueNumber = $issueUrl.Split("/")[-1]
    Start-Sleep -Seconds 2
    gh issue close $issueNumber --comment "Closing for badge!"
    Write-Host "Quickdraw attempt complete!" -ForegroundColor Green
}
else {
    Write-Error "Failed to create issue for Quickdraw."
}

# 2. YOLO: Merge PR without review
Write-Host "Attempting YOLO (Merge PR without review)..." -ForegroundColor Cyan
$yoloBranch = "yolo-$timestamp"
git checkout main
git pull
git checkout -b $yoloBranch
"YOLO Trigger $timestamp" | Out-File -FilePath yolo_$timestamp.txt
git add .
git commit -m "YOLO commit $timestamp"
git push origin $yoloBranch
$prTitle = "YOLO Badge PR $timestamp"
$prUrl = gh pr create --title $prTitle --body "Merging without review for YOLO badge"
if ($prUrl -and $prUrl -match "https://") {
    Start-Sleep -Seconds 5
    gh pr merge $prUrl --merge --delete-branch
    Write-Host "YOLO attempt complete!" -ForegroundColor Green
}
else {
    Write-Error "Failed to create PR for YOLO."
}
git checkout main
git pull

# 3. Pull Shark (Multiple PRs)
Write-Host "Attempting Pull Shark (2 additional PRs)..." -ForegroundColor Cyan
for ($i = 1; $i -le 2; $i++) {
    $branchName = "pull-shark-$timestamp-$i"
    git checkout -b $branchName
    "Shark $i $timestamp" | Out-File -FilePath shark_$timestamp_$i.txt
    git add .
    git commit -m "Shark commit $i"
    git push origin $branchName
    $sharkPrTitle = "Pull Shark PR $i $timestamp"
    $sharkPrUrl = gh pr create --title $sharkPrTitle --body "Automated PR for Pull Shark badge"
    if ($sharkPrUrl -and $sharkPrUrl -match "https://") {
        Start-Sleep -Seconds 2
        gh pr merge $sharkPrUrl --merge --delete-branch
        Write-Host "Pull Shark PR $i complete!" -ForegroundColor Green
    }
    else {
        Write-Error "Failed to create Pull Shark PR $i."
    }
    git checkout main
    git pull
}
Write-Host "Pull Shark attempts complete!" -ForegroundColor Green

# 4. Pair Extraordinaire (Co-authored commit)
Write-Host "Attempting Pair Extraordinaire..." -ForegroundColor Cyan
"Pairing $timestamp" | Out-File -FilePath pair_$timestamp.txt
git add .
git commit -m "Pair commit $timestamp
Co-authored-by: octocat <octocat@github.com>"
git push origin main
Write-Host "Pair Extraordinaire attempt complete (check commit history)!" -ForegroundColor Green

# 5. Heart on your Sleeve (React with emoji)
Write-Host "Attempting Heart on your Sleeve (React to issue)..." -ForegroundColor Cyan
$reactionIssueTitle = "Reaction Test $timestamp"
$reactionIssueUrl = gh issue create --title $reactionIssueTitle --body "React to me!"
if ($reactionIssueUrl -and $reactionIssueUrl -match "https://") {
    $rIssueNumber = $reactionIssueUrl.Split("/")[-1]
    Start-Sleep -Seconds 2
    # Create a comment to react to (optional, but good for activity)
    gh issue comment $rIssueNumber --body "Here is a comment to love."
    
    # React to the issue itself via API
    gh api "repos/system-conf/githubrozet/issues/$rIssueNumber/reactions" -f content="heart"
    
    Write-Host "Heart on your Sleeve attempt complete!" -ForegroundColor Green
}
else {
    Write-Error "Failed to create issue for Reaction test."
}

Write-Host "All automation steps finished! Check your GitHub profile." -ForegroundColor Magenta
