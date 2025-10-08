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
# Ensure directories exist
if (-not (Test-Path $resultsRoot)) { New-Item -Path $resultsRoot -ItemType Directory | Out-Null }
if (-not (Test-Path $tempParamsRoot)) { New-Item -Path $tempParamsRoot -ItemType Directory | Out-Null }

# Clean up old .mtbx files before starting
Get-ChildItem -Path $tempParamsRoot -Filter "*.mtbx" | Remove-Item -Force

# --- Execution Logic ---

$groupPath = "$testRoot\$GroupFolder"
Write-Host "Searching for UFT tests in: $groupPath"

# Loop through each UFT test folder inside the specified group folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Construct paths for results and .mtbx files
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $mtbxFile = "$tempParamsRoot\$testName.mtbx"

    Write-Host "Processing test: $testName"
    
    # Convert all backslashes to forward slashes for XML path compatibility
    # The .mtbx format generally handles forward slashes better than the old .txt format
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    # 9. Create the .mtbx XML content, including InputParameters
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

    # 10. Save the .mtbx parameter file
    $mtbxContent | Out-File -FilePath $mtbxFile -Encoding UTF8

    # 11. Run the test using FTToolsLauncher and the -mtbxfile argument
    Write-Host "Executing test with .mtbx file: $mtbxFile"
    & $launcherPath -mtbxfile $mtbxFile
}

Write-Host "Finished processing tests in group: $GroupFolder"