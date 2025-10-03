param(
    [Parameter(Mandatory=$true)]
    [string]$GroupFolder,       # Example input from GitHub Action: "group1"
    
    [Parameter(Mandatory=$true)]
    [string]$DataSheetName      # Example input from GitHub Action: "LoginScenarios"
)

# 1. DEFINE ROOT PATHS
$testRoot = "C:\VIP\Demos\Github\UFTDemo3\uft-one-tests"
$resultsRoot = "C:\VIP\Demos\Github\UFTDemo3\Results"
$tempParamsRoot = "C:\VIP\Demos\Github\UFTDemo3\TempParams"

# 2. DEFINE EXCEL DATA PATH
$excelDataPath = "C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx" 

# --- FOLDER SETUP AND CLEANUP ---

# 3. CLEANUP STEP: Clear the TempParams folder content
if (Test-Path -Path $tempParamsRoot) {
    Write-Host "Clearing temporary parameter files from: $tempParamsRoot"
    Remove-Item -Path "$tempParamsRoot\*" -Recurse -Force | Out-Null
}

# 4. CLEANUP STEP: Clear the Results folder content before starting the new run
# This removes all previous HTML and XML result files.
if (Test-Path -Path $resultsRoot) {
    Write-Host "Clearing previous test results from: $resultsRoot"
    Remove-Item -Path "$resultsRoot\*" -Recurse -Force | Out-Null
}

# 5. Ensure both required folders exist (or are recreated after clearing)
if (!(Test-Path -Path $tempParamsRoot)) {
    New-Item -ItemType Directory -Path $tempParamsRoot | Out-Null
}
if (!(Test-Path -Path $resultsRoot)) {
    New-Item -ItemType Directory -Path $resultsRoot | Out-Null
}

# --- EXECUTION LOGIC ---

# 6. Construct the full path to the specific group directory
$groupPath = "$testRoot\$GroupFolder"

Write-Host "Searching for UFT tests in: $groupPath"

# 7. Loop through each UFT test folder *inside* the specified group folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Construct paths for results and param files
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $paramFile = "$tempParamsRoot\$testName`_params.txt"

    # 8. FIX: Convert Windows backslashes (\) to forward slashes (/) for FTToolsLauncher
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    Write-Host "Processing test: $testName"
    
    # 9. Create the parameter file content with CUSTOM DATA PARAMETERS
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Fwd
DataTablePath=$excelDataPath_Fwd
DataTableSheet=$DataSheetName

[Test1]
Test1=$testPath_Fwd
"@

    # 10. Save the parameter file
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 11. Run the test using FTToolsLauncher
    & "C:\Tools\FTToolsLauncher\FTToolsLauncher.exe" -paramfile $paramFile
}

Write-Host "Finished processing tests in group: $GroupFolder"