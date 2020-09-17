' Auxiliary subs

' add trailing slash to dir paths if needed
Function dirPath(path)
	dirPath = path
	If InStrRev( path, "\") <> Len( path) And _
	   InStrRev( path, "/") <> Len( path)  Then dirPath = dirPath + "\"
End Function

' check file extention
Function endsWith(path,ext)
	endsWith = False
	If Len(path) >= Len(ext) And InStrRev(path,ext) = Len(path)-Len(ext)+1 Then _
		endsWith = True
End Function

' prepare a string for parsing
Function norm(s)
	txt = Split(s,"!")(0)  ' erase comments
	norm = fullTrim(txt)
End Function

' Earase all blanks in a string
Function fullTrim(s)
	txt = Replace(s  , Chr(13), " ")  ' eoln
	txt = Replace(txt, Chr(10), " ")  ' eoln
	txt = Replace(txt, Chr(9 ), " ")  ' tabs
	txt = Trim(txt)
	fullTrim = txt
End Function

' power function
Function pow(a,b)
	pow = Exp(b*Log(a))
End Function


' Error dialog
Function Error(txt)
  	    Begin Dialog UserDialog 400,100
	        Text 10,10,380,50,txt
	        OKButton 160,60,80,30
	    End Dialog
	    Dim dlg As UserDialog
	    Dialog dlg ' show dialog (wait for ok)
End Function

' if condition = False interupts the script
Sub assert(condition, errMsg, nline)
	If condition = False Then
		Error("Error in line " + Str(nline) + "::  " + errMsg)
		Exit All
	End If
End Sub

' convert string to boolean
Function s2bool(s)
	s = LCase(s)
	If s="true" Or s="yes" Or s="1" Then
		s2bool = True
	Else
		s2bool = False
	End If
End Function

' min of 2 values
Function min(a,b)
	If a<b Then
		min = a
	Else
		min = b
	End If
End Function

' max of 2 values
Function max(a,b)
	If a>b Then
		max = a
	Else
		max = b
	End If
End Function

' test if an nc-file name is provided
Function isNCFile(fName)
	isNCFile = Len(fName) >= 3 And InStrRev(fName,".nc") = Len(fName)-2
End Function

' create directory
Public Function makeDir(s)
	On Error Resume Next
	MkDir s
End Function

' Form a time stamp string from time vars
' If the time index ts >= 0 then it is added in the end
Function timeStamp(ts, y, m, d, h, min)
	timeStamp = ""
	If CLng(d) < 10 Then timeStamp = timeStamp + "0"
	timeStamp = timeStamp + d + "."
	If CLng(m) < 10 Then timeStamp = timeStamp + "0"
	timeStamp = timeStamp + m + "."
	If CLng(y) < 10 Then timeStamp = timeStamp + "0"
	timeStamp = timeStamp + y + " "
	If CLng(h) < 10 Then timeStamp = timeStamp + "0"
	timeStamp = timeStamp + h + ":"
	If CLng(min) < 10 Then timeStamp = timeStamp + "0"
	timeStamp = timeStamp + min
	If CLng(ts) >= 0 Then timeStamp = timeStamp + " — Time#" + ts
End Function

' File exists function
' Note: Scripter doesn't seem to have such a function (wtf!)
Function fileExists(path)
	fileExists = False
	' Scan a directory for the first file matching path
	F$ = Dir$(path)
	If F$ <> "" Then fileExists = True
End Function

' Delete a file
Sub delFile(path)
	' Only if file exists, delete it
	If fileExists(path) Then Kill(path)
End Sub

' Ensure a file exists
Sub waitFileCreation(path)
	Do
		' Wait a bit
		Wait(0.25)
		' if file exists then exit
		If fileExists(path) Then Exit Do
	Loop
	' Wait a bit more (till file creation has been finalized)
	Wait(0.5)
End Sub
