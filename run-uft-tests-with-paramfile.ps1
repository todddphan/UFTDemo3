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

# --- Execution Logic ---

$groupPath = "$testRoot\$GroupFolder"
Write-Host "Searching for UFT tests in: $groupPath"

# Loop through each UFT test folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $mtbxFile = "$tempParamsRoot\$testName.mtbx"
    $paramFile = "$tempParamsRoot\$testName.txt"

    Write-Host "Processing test: $testName"
    
    # Paths for the MTBX content (using FORWARD SLASHES for XML readability)
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    # ⭐ CRITICAL FIX: Path for the .txt file must use DOUBLE BACKSLASHES (\\)
    # The value of Test1 must point to the escaped MTBX file path.
    $mtbxFile_Escaped = $mtbxFile -replace '\\', '\\'
    
    # The results file path also needs to be escaped for the .txt file
    $resultsFile_Escaped = "$resultsRoot\$testName`_$timestamp.html" -replace '\\', '\\'


    # 1. Create the .mtbx XML content (Simplified structure with parameters)
    $mtbxContent = @"
<Mtbx>
  <Test name="$testName" path="$testPath_Fwd" reportPath="$resultsFile_Fwd">
    <Parameter name="DataTablePath" value="$excelDataPath_Fwd" type="string"/>
    <Parameter name="DataTableSheet" value="$DataSheetName" type="string"/>
  </Test>
</Mtbx>
"@
    $mtbxContent | Out-File -FilePath $mtbxFile -Encoding UTF8

    # 2. Create the .txt parameter file (Test1 NOW points to the escaped MTBX file)
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Escaped

[Test1]
Test1=$mtbxFile_Escaped
"@
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 3. Run the test using ONLY the -paramfile argument
    Write-Host "Executing test using ONLY -paramfile to load the nested MTBX: $paramFile"
    & $launcherPath -paramfile $paramFile
}

Write-Host "Finished processing tests in group: $GroupFolder"