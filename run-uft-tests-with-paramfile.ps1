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
$excelDataPath = "C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx" 

# --- Directory Setup and Cleanup (omitted for brevity) ---

# --- Execution Logic ---
$groupPath = "$testRoot\$GroupFolder"
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $mtbxFile = "$tempParamsRoot\$testName.mtbx"
    $paramFile = "$tempParamsRoot\$testName.txt"

    # Convert paths to forward slashes for cross-file consistency
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    # 1. Create the .txt parameter file (NOW INCLUDES resultsFilename)
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Fwd
"@
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 2. Create the .mtbx XML content (InputParameters are still here)
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
    $mtbxContent | Out-File -FilePath $mtbxFile -Encoding UTF8

    # 3. Run the test
    & $launcherPath -paramfile $paramFile -source $mtbxFile
}