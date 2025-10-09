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
Write-Host "Searching for UFT tests in: $groupPath"

Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $mtbxFile = "$tempParamsRoot\$testName.mtbx"
    $paramFile = "$tempParamsRoot\$testName.txt"

    Write-Host "Processing test: $testName"
    
    # Convert all paths to forward slashes for cross-file consistency
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    # 1. Create the .txt parameter file (Mandatory run settings AND [Test1])
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Fwd

[Test1]
Test1=$testPath_Fwd
"@
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 2. Create the .mtbx XML content (Using the simplified <Mtbx> structure)
    $mtbxContent = @"
<Mtbx>
  <Test name="$testName" path="$testPath_Fwd" reportPath="$resultsFile_Fwd">
    <Parameter name="DataTablePath" value="$excelDataPath_Fwd" type="string"/>
    <Parameter name="DataTableSheet" value="$DataSheetName" type="string"/>
  </Test>
</Mtbx>
"@
    $mtbxContent | Out-File -FilePath $mtbxFile -Encoding UTF8

    # 3. Run the test using FTToolsLauncher, passing BOTH -paramfile and -source
    Write-Host "Executing test with .txt: $paramFile and .mtbx: $mtbxFile"
    & $launcherPath -paramfile $paramFile -source $mtbxFile
}

Write-Host "Finished processing tests in group: $GroupFolder"