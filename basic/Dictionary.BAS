''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Dictionary module: the object contains key-value pairs
' AddKey method adds a new pair. If the key is already
'        defined, then replace the value
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Const NPARAMS = 100

Type Dictionary
	n_param As Integer
	key  (1 To NPARAMS) As String
	value(1 To NPARAMS) As String
End Type

Sub AddKey(dict, key, value)
	k = dict.n_param + 1
	' search the same tag already defined
	For n = 1 To dict.n_param Step 1
		If dict.key(n) = key Then
			k = n
			Exit For
		End If
    Next n
    If k = dict.n_param+1 Then dict.n_param = dict.n_param+1
	dict.key  (k) = key
	dict.Value(k) = value
End Sub

Function ValueByKey(dict,key)
	For n = 1 To dict.n_param Step 1
		If dict.key(n) = key Then
			ValueByKey = dict.Value(n)
			Exit Function
		End If
    Next n
    ValueByKey = ""
End Function

' debug sub
Sub printDict(dict)
	For n = 1 To dict.n_param Step 1
		Debug.Print dict.key(n) + " : " + dict.Value(n)
    Next n
End Sub


' Test
Sub Main1
	Debug.Clear
	Dim dict As Dictionary
	AddKey(dict, "a", "b")
	AddKey(dict, "a", "d")
	Debug.Print ValueByKey(dict,"a")
End Sub
