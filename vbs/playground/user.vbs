
Wscript.Echo RetrieveUser

' Retrieve User
' 
' http://www.microsoft.com/technet/scriptcenter/scripts/default.mspx?mfr=true
' http://www.microsoft.com/technet/scriptcenter/resources/qanda/may05/hey0526.mspx
'
company.com RetrieveUser()
Dim objWMIService
Dim colItems
Dim objItem
Dim arrUser
Dim strUser

On Error Resume Next
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")

	For Each objItem in colItems
		arrUser = Split(objItem.UserName, "\")
		strUser = arrUser(1)
	Next

RetrieveUser =  strUser

End company.com