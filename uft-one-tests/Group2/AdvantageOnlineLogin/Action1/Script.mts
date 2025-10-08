' Code to run in the DataSetup Action

' ⭐ MODIFIED LINE: Reference the new environment variable name set by the PowerShell script (UFT_DATA_PATH)
Dim ExcelPath : ExcelPath = Environment.Value("UFT_DATA_PATH") 
Dim SheetName : SheetName = Environment.Value("DataTableSheet")  ' This name is still passed via the parameter file

' ⭐ NEW DEBUG CODE: Report the retrieved environment values
Reporter.ReportEvent micDone, "Data Table Path Check", "ExcelPath retrieved: " & "C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx"
Reporter.ReportEvent micDone, "Data Table Sheet Check", "SheetName retrieved: " & SheetName


' Imports the data into the current Action's data sheet
Dim CurrentActionName : CurrentActionName = DataTable.LocalSheet.Name

DataTable.ImportSheet ExcelPath, SheetName, CurrentActionName 

' -------------------------------------------------------------------------------------------------------

' Code to run in the Main Action (or whichever Action contains the login steps)

' 1. Retrieve values from the Action's local data table
Dim sUserName : sUserName = DataTable.Value("Username", CurrentActionName)
Dim sPassword : sPassword = DataTable.Value("Password", CurrentActionName)

' 2. Use the variables in the test steps

Browser("Advantage Shopping").Page("Advantage Shopping").Link("UserMenu").Click

Browser("Advantage Shopping").Page("Advantage Shopping").WebEdit("username").Set sUserName 

Browser("Advantage Shopping").Page("Advantage Shopping").WebEdit("password").Set sPassword 

Browser("Advantage Shopping").Page("Advantage Shopping").WebButton("sign_in_btn").Click

Browser("Advantage Shopping").Page("Advantage Shopping").Link("SpeakersCategoryTxt").Click
