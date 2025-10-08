' Code to run in the DataSetup Action
Dim ExcelPath : ExcelPath =  Environment.Value("DataTablePath") '"C:\VIP\Demos\Github\UFTDemo3\Test_Data\MasterData.xlsx" 
Dim SheetName : SheetName = "Sheet1" 
' Imports the data into the current Action's data sheet
'DataTable.ImportSheet ExcelPath, SheetName, DataTable.CurrentAction
Dim CurrentActionName : CurrentActionName = DataTable.LocalSheet.Name
DataTable.ImportSheet ExcelPath, SheetName, CurrentActionName 

' Code to run in the Main Action (or whichever Action contains the login steps)

' 1. Retrieve values from the Action's local data table
Dim sUserName : sUserName = DataTable.Value("Username", CurrentActionName)
Dim sPassword : sPassword = DataTable.Value("Password", CurrentActionName)

' 2. Use the variables in the test steps
Browser("Advantage Shopping").Page("Advantage Shopping").Link("UserMenu").Click
Browser("Advantage Shopping").Page("Advantage Shopping").WebEdit("username").Set sUserName 
Browser("Advantage Shopping").Page("Advantage Shopping").WebEdit("password").Set sPassword 
Browser("Advantage Shopping").Page("Advantage Shopping").WebButton("sign_in_btn").Click
Browser("Advantage Shopping").Page("Advantage Shopping").Link("SpeakersCategoryTxt").Click @@ script infofile_;_ZIP::ssf6.xml_;_
