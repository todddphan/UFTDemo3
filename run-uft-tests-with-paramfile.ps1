param(
    [Parameter(Mandatory=$true)]
    [string]$GroupFolder,       # Example input from GitHub Action: "group1"
    
    [Parameter(Mandatory=$true)]
    [string]$DataSheetName       # Example input from GitHub Action: "LoginScenarios"
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

    # 8. ⭐ CRITICAL FIX: Escape backslashes for FTToolsLauncher parameter file
    # Replace all single backslashes (\) with double backslashes (\\).
    # This is required for the UFT engine to correctly parse the Windows paths 
    # when reading the INI-style parameter file.
    $testPath_Escaped = $testPath -replace '\\', '\\\\'
    $resultsFile_Escaped = $resultsFile -replace '\\', '\\\\'
    $excelDataPath_Escaped = $excelDataPath -replace '\\', '\\\\'

    Write-Host "Processing test: $testName"
    
    # 9. Create the parameter file content with ESCAPED PATHS
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Escaped
DataTablePath=$excelDataPath_Escaped
DataTableSheet=$DataSheetName

[Test1]
Test1=$testPath_Escaped
"@

    # 10. Save the parameter file using default encoding (safe assumption)
    $paramContent | Out-File -FilePath $paramFile

    # 11. Run the test using FTToolsLauncher
    Write-Host "Executing test with parameters: $paramFile"
    & "C:\Tools\FTToolsLauncher\FTToolsLauncher.exe" -paramfile $paramFile
}

Write-Host "Finished processing tests in group: $GroupFolder"