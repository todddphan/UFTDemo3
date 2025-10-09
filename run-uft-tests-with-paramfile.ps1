param(
    [Parameter(Mandatory=$true)]
    [string]$GroupFolder,       
    
    [Parameter(Mandatory=$true)]
    [string]$DataSheetName       
)

# --- Configuration Paths ---
$testRoot = "C:\VIP\Demos\Github\UFTDemo3\uft-one-tests"
$resultsRoot = "C:\VIP\Demos\Github\UFTDemo3\Results"
$tempParamsRoot = "C:\VIP\Demos\Github\UFTDemo3\TempParams"
$launcherPath = "C:\Tools\FTToolsLauncher\FTToolsLauncher.exe"

# Define the source Excel path
$excelDataPath = "C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx" 

# --- Execution Logic ---

$groupPath = "$testRoot\$GroupFolder"
Write-Host "Searching for UFT tests in: $groupPath"

# Loop through each UFT test folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $paramFile = "$tempParamsRoot\$testName.txt"

    Write-Host "Processing test: $testName"
    
    # ⭐ CRITICAL FIX: Ensure ALL paths use DOUBLE BACKSLASHES (\\)
    $resultsFile_Escaped = "$resultsRoot\$testName`_$timestamp.html" -replace '\\', '\\'
    $excelDataPath_Escaped = $excelDataPath -replace '\\', '\\'
    $testPath_Escaped = $testPath -replace '\\', '\\'

    # 1. Create the .txt parameter file with ALL paths escaped
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
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 2. Run the test using ONLY the -paramfile argument
    Write-Host "Executing test using single, escaped paramfile: $paramFile"
    & $launcherPath -paramfile $paramFile
}

Write-Host "Finished processing tests in group: $GroupFolder"