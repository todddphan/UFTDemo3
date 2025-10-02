$testRoot = "C:\VIP\Demos\Github\UFTDemo2\uft-one-tests"
$resultsRoot = "C:\VIP\Demos\Github\UFTDemo2\Results"
$tempParamsRoot = "C:\VIP\Demos\Github\UFTDemo2\TempParams"

# Ensure the root paths are defined with single backslashes for PowerShell to read them correctly
# Note: You can use single backslashes in variable assignments.

# Ensure the TempParams folder exists
if (!(Test-Path -Path $tempParamsRoot)) {
    New-Item -ItemType Directory -Path $tempParamsRoot | Out-Null
}

# Loop through each test folder
Get-ChildItem -Path $testRoot -Directory | ForEach-Object {
    $testName = $_.Name
    $testPath = $_.FullName
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Construct the full path for the results file and parameter file
    # Use double backslashes in double-quoted strings for variable concatenation
    $resultsFile = "$resultsRoot\\$testName`_$timestamp.html"
    $paramFile = "$tempParamsRoot\\$testName`_params.txt"

    # --- START OF FIX: Convert paths to use forward slashes for FTToolsLauncher ---
    # Convert Windows backslashes (\) to forward slashes (/) for the parameter file content
    $testPath_Fwd = $testPath -replace '\\', '/'
    $resultsFile_Fwd = $resultsFile -replace '\\', '/'
    # --- END OF FIX ---

    # Create the parameter file content with the FIXED paths
    # The paths now use forward slashes ($testPath_Fwd and $resultsFile_Fwd)
    $paramContent = @"
[General]
RunMode=Normal
runType=FileSystem
resultsFilename=$resultsFile_Fwd

[Test1]
TestPath=$testPath_Fwd
"@

    # Save the parameter file with explicit ASCII encoding
    # (Keeping -Encoding ASCII is crucial for compatibility)
    $paramContent | Out-File -FilePath $paramFile -Encoding ASCII

    # Run the test using FTToolsLauncher
    & "C:\Tools\FTToolsLauncher\FTToolsLauncher.exe" -paramfile $paramFile
}