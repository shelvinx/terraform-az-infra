param(
    [Parameter(Mandatory = $true)]
    [string]$GithubUsername,
    
    [Parameter(Mandatory = $true)]
    [string]$AnsibleRepoName
)

Write-Host "Triggering Ansible workflow in GitHub..."
$repoPath = "$GithubUsername/$AnsibleRepoName"
gh workflow run ansible-runner.yml --repo $repoPath --ref main

Write-Host "Waiting for GitHub to register the run..."
Start-Sleep -Seconds 5

# Fetch the latest Run ID
$runJson = gh run list --repo $repoPath --workflow ansible-runner.yml --limit 1 --json databaseId
$runId = ($runJson | ConvertFrom-Json)[0].databaseId

Write-Host "Watching GitHub Run ID: $runId"

# Dynamic step-by-step polling loop
$status = "in_progress"
$completedSteps = @()

while ($status -eq "in_progress" -or $status -eq "queued" -or $status -eq "waiting" -or $status -eq "requested") {
    Start-Sleep -Seconds 5
    # Fetch the full job data including individual steps
    $runInfo = gh run view $runId --repo $repoPath --json "status,conclusion,jobs" | ConvertFrom-Json
    $status = $runInfo.status
    
    # If the job has started, iterate through its steps
    if ($runInfo.jobs -and $runInfo.jobs.Count -gt 0) {
        foreach ($step in $runInfo.jobs[0].steps) {
            # If a step is done, and we haven't printed it yet, print it!
            if ($step.status -eq "completed" -and $completedSteps -notcontains $step.name) {
                # Emulate the gh interface, but printing linearly line-by-line
                if ($step.conclusion -eq "success") {
                    Write-Host "  Success: $($step.name)" -ForegroundColor Green
                }
                elseif ($step.conclusion -eq "skipped") {
                    Write-Host "  Skipped: $($step.name)" -ForegroundColor Yellow
                }
                else {
                    Write-Host "  Failed: $($step.name)" -ForegroundColor Red
                }
                $completedSteps += $step.name
            }
        }
    }
}

if ($runInfo.conclusion -ne "success") {
    Write-Error "Ansible workflow failed with conclusion: $($runInfo.conclusion)"
    exit 1
}

Write-Host "Ansible workflow completed successfully!"
