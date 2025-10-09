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

# Loop through each UFT test folder inside the specified group folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $mtbxFile = "$tempParamsRoot\$testName.mtbx"
    $paramFile = "$tempParamsRoot\$testName.txt"

    Write-Host "Processing test: $testName"
    
    # Paths for the MTBX content (using forward slashes)
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    # CRITICAL FIX: Path for the .txt file must use DOUBLE BACKSLASHES to be safe
    # This path is what Test1= will use to load the MTBX file.
    $mtbxFile_Escaped = $mtbxFile -replace '\\', '\\'

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

    # 2. Create the .txt parameter file (Mandatory run settings, pointing Test1 to the MTBX file)
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Fwd

[Test1]
Test1=$mtbxFile_Escaped
"@
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 3. Run the test using ONLY the -paramfile argument
    Write-Host "Executing test using ONLY -paramfile to load the nested MTBX: $paramFile"
    & $launcherPath -paramfile $paramFile
}

Write-Host "Finished processing tests in group: $GroupFolder"