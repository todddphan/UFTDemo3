param(
    [Parameter(Mandatory=$true)]
    [string]$GroupFolder,       # Example input from GitHub Action: "group1"
    
    [Parameter(Mandatory=$true)]
    [string]$DataSheetName      # Example input from GitHub Action: "LoginScenarios"
)

# 1. DEFINE ROOT PATHS (Updated for UFTDemo3 structure)
$testRoot = "C:\VIP\Demos\Github\UFTDemo3\uft-one-tests"
$resultsRoot = "C:\VIP\Demos\Github\UFTDemo3\Results"
$tempParamsRoot = "C:\VIP\Demos\Github\UFTDemo3\TempParams"

# 2. DEFINE EXCEL DATA PATH (Configure this to the absolute path of your Excel file)
$excelDataPath = "C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx" 

# --- FOLDER SETUP AND CLEANUP ---

# 3. CLEAR out the TempParams folder content before starting the new run
if (Test-Path -Path $tempParamsRoot) {
    Write-Host "Clearing temporary parameter files from: $tempParamsRoot"
    Remove-Item -Path "$tempParamsRoot\*" -Recurse -Force | Out-Null
}

# 4. Ensure the TempParams folder exists (or is recreated after clearing)
if (!(Test-Path -Path $tempParamsRoot)) {
    New-Item -ItemType Directory -Path $tempParamsRoot | Out-Null
}

# --- EXECUTION LOGIC ---

# 5. Construct the full path to the specific group directory
$groupPath = "$testRoot\$GroupFolder"

Write-Host "Searching for UFT tests in: $groupPath"

# 6. Loop through each UFT test folder *inside* the specified group folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    # $_.Name is the test folder name (e.g., "LoginTest")
    $testName = $_.Name
    # $_.FullName is the full path to the UFT test folder
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Construct paths for results and param files
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $paramFile = "$tempParamsRoot\$testName`_params.txt"

    # 7. FIX: Convert Windows backslashes (\) to forward slashes (/) for FTToolsLauncher
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    Write-Host "Processing test: $testName"
    
    # 8. Create the parameter file content with CUSTOM DATA PARAMETERS
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

    # 9. Save the parameter file with ASCII encoding
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 10. Run the test using FTToolsLauncher
    & "C:\Tools\FTToolsLauncher\FTToolsLauncher.exe" -paramfile $paramFile
}

Write-Host "Finished processing tests in group: $GroupFolder"