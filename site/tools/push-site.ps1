<#
.SYNOPSIS
  Push the `site/` folder to the repository on a new branch `sam-site-update`.

.DESCRIPTION
  This script stages files under the `site/` folder, creates a new branch named
  `sam-site-update`, commits with a sensible message, and pushes the branch to
  the `origin` remote. It will not modify `main` or `master` branches.

.USAGE
  From the repository root (C:\Users\Shamsher):
    Set-Location -Path 'C:\Users\Shamsher'
    .\site\tools\push-site.ps1

#>
param(
    [string]$BranchName = 'sam-site-update',
    [switch]$ForcePush
)

function Exec-Git {
    param([string]$Args)
    Write-Host "git $Args"
    $p = Start-Process -FilePath git -ArgumentList $Args -NoNewWindow -PassThru -Wait -RedirectStandardOutput stdout.txt -RedirectStandardError stderr.txt
    $out = Get-Content stdout.txt -Raw -ErrorAction SilentlyContinue
    $err = Get-Content stderr.txt -Raw -ErrorAction SilentlyContinue
    Remove-Item stdout.txt, stderr.txt -ErrorAction SilentlyContinue
    return @{ ExitCode = $p.ExitCode; StdOut = $out; StdErr = $err }
}

# Ensure we're in a git repo
$check = Exec-Git 'rev-parse --is-inside-work-tree'
if ($check.ExitCode -ne 0) {
    Write-Error 'Not a git repository or git not found. Install git and run this from the repository root.'; exit 1
}

# Make sure working tree is clean or warn
$status = Exec-Git 'status --porcelain'
if ($status.StdOut.Trim().Length -ne 0) {
    Write-Warning 'You have uncommitted changes. This script will only stage files under site/ and commit them. Consider committing other changes first.'
}

# Create branch from current HEAD
$res = Exec-Git "checkout -b $BranchName"
if ($res.ExitCode -ne 0) {
    Write-Warning "Could not create branch '$BranchName' (it may already exist). Attempting to checkout existing branch."
    $res2 = Exec-Git "checkout $BranchName"
    if ($res2.ExitCode -ne 0) { Write-Error 'Failed to checkout branch.'; exit 1 }
}

# Stage site/ files only
$add = Exec-Git 'add --all -- site'
if ($add.ExitCode -ne 0) { Write-Error 'git add failed: ' + $add.StdErr; exit 1 }

# Commit
$msg = "Update site at $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$commit = Exec-Git "commit -m `"$msg`" --no-verify"
if ($commit.ExitCode -ne 0) {
    if ($commit.StdErr -match 'nothing to commit') {
        Write-Host 'No changes to commit in site/';
    } else {
        Write-Warning 'git commit returned: ' + $commit.StdErr
    }
}

# Push
if ($ForcePush) { $pushArgs = "-u origin $BranchName --force" } else { $pushArgs = "-u origin $BranchName" }
$push = Exec-Git "push $pushArgs"
if ($push.ExitCode -ne 0) { Write-Error 'git push failed: ' + $push.StdErr; exit 1 }

Write-Host "Pushed branch '$BranchName' to origin. Open GitHub and create a PR to merge into main/master when ready."
