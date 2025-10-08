param(
    [Parameter(Mandatory=$true)]
    [string]$GroupFolder,       
    
    [Parameter(Mandatory=$true)]
    [string]$DataSheetName       
)

# 1. DEFINE ROOT PATHS
$testRoot = "C:\VIP\Demos\Github\UFTDemo3\uft-one-tests"
$resultsRoot = "C:\VIP\Demos\Github\UFTDemo3\Results"
$tempParamsRoot = "C:\VIP\Demos\Github\UFTDemo3\TempParams"

# 2. DEFINE EXCEL DATA PATH
$excelDataPath = "C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx" 

# 3. Construct the full path to the specific group directory
$groupPath = "$testRoot\$GroupFolder"

Write-Host "Searching for UFT tests in: $groupPath"

# 4. Loop through each UFT test folder inside the specified group folder
Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Construct paths for results and param files
    $resultsFile = "$resultsRoot\$testName`_$timestamp.html"
    $paramFile = "$tempParamsRoot\$testName`_params.txt"

    # Convert to forward slashes for FTToolsLauncher compatibility
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    $excelDataPath_Fwd = $excelDataPath -replace '\\', '/'

    Write-Host "Processing test: $testName"
    
    # 5. Create the parameter file content with both Excel path and sheet name
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

    # 6. Save the parameter file with compatible encoding
    $paramContent | Out-File -FilePath $paramFile -Encoding Default

    # 7. Run the test using FTToolsLauncher
    Write-Host "Executing test with parameters: $paramFile"
    & "C:\Tools\FTToolsLauncher\FTToolsLauncher.exe" -paramfile $paramFile
}

Write-Host "Finished processing tests in group: $GroupFolder"