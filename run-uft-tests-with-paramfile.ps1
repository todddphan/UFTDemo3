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

# ... (Cleanup and Setup Steps 3, 4, 5 omitted for brevity, assume they are present) ...

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

    # Convert Windows backslashes (\) to forward slashes (/) 
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'

    Write-Host "Processing test: $testName"
    
    # 9. Create the parameter file content (Includes DataTableSheet)
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Fwd
DataTableSheet=$DataSheetName  

[Test1]
Test1=$testPath_Fwd
"@

    # 10. Save the parameter file
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # 11. ⭐ FINAL CRITICAL FIX: Use cmd /c to reliably set the environment variable 
    # and execute the launcher in the same command shell.
    
    # Prepare the environment variable setting command (using a custom variable name)
    $UFT_DATA_PATH_Command = "UFT_DATA_PATH=`"$excelDataPath`"" 

    # Prepare the FTToolsLauncher command
    $LauncherCommand = "`"C:\Tools\FTToolsLauncher\FTToolsLauncher.exe`" -paramfile `"$paramFile`""
    
    Write-Host "Executing test with parameter file: $paramFile"
    
    # Execute: cmd /c "SET_VAR & LAUNCHER_COMMAND" to ensure both variables are passed correctly.
    & cmd /c "$UFT_DATA_PATH_Command & $LauncherCommand"
}

Write-Host "Finished processing tests in group: $GroupFolder"