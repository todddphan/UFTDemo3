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

# Define the data paths
$excelDataPath = "C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx" 

# --- Directory Setup and Cleanup ---
# Ensure directories exist and clean up old files
if (-not (Test-Path $resultsRoot)) { New-Item -Path $resultsRoot -ItemType Directory | Out-Null }
if (-not (Test-Path $tempParamsRoot)) { New-Item -Path $tempParamsRoot -ItemType Directory | Out-Null }
Get-ChildItem -Path $tempParamsRoot -Filter "*.mtbx" | Remove-Item -Force
Get-ChildItem -Path $tempParamsRoot -Filter "*.txt" | Remove-Item -Force

# --- Execution Logic ---

$groupPath = "$testRoot\$GroupFolder"
Write-Host "Searching for UFT tests in: $groupPath"

# Loop through each UFT test folder inside the specified group folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Construct file paths
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $mtbxFile = "$tempParamsRoot\$testName.mtbx"
    $paramFile = "$tempParamsRoot\$testName.txt" # Simple required param file

    Write-Host "Processing test: $testName"
    
    # Convert all paths to forward slashes for cross-file consistency
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    # 1. Create the simple .txt parameter file (only required general settings)
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
"@
    # Save the .txt file
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 2. Create the .mtbx XML content (test list, results, and custom InputParameters)
    $mtbxContent = @"
<?xml version="1.0" encoding="utf-8"?>
<TestBatch xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.microfocus.com/mtb/TestBatch.xsd">
  <Test Type="GUITest" Path="$testPath_Fwd">
    <RunConfiguration>
      <OutputConfiguration>
        <ResultFileName>$resultsFile_Fwd</ResultFileName>
      </OutputConfiguration>
      <InputParameters>
        <Parameter Name="DataTablePath" Value="$excelDataPath_Fwd" />
        <Parameter Name="DataTableSheet" Value="$DataSheetName" />
      </InputParameters>
    </RunConfiguration>
  </Test>
</TestBatch>
"@
    # Save the .mtbx file
    $mtbxContent | Out-File -FilePath $mtbxFile -Encoding UTF8

    # 3. Run the test using FTToolsLauncher, passing BOTH -paramfile and -source
    Write-Host "Executing test with .txt: $paramFile and .mtbx: $mtbxFile"
    & $launcherPath -paramfile $paramFile -source $mtbxFile
}

Write-Host "Finished processing tests in group: $GroupFolder"