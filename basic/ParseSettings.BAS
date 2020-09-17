'#Uses "Dictionary.bas"
'#Uses "utils.bas"
'#Uses "DataStructure.bas"

Sub ParseSettings(path)
	Dim chart_tag_is_open As Boolean	' CHART tag is open
	Dim chelm_tag_is_open As Boolean	' chart element tag is open
	Dim caption_tag_is_open As Boolean  ' caption tag is open
	Dim mapTag As String ' currently opened map tag
	caption_tag_is_open = False

	Open path For Input As #1
	nline = 0
ReadTags:
	If EOF(1) Then
		Close #1
		Exit Sub
	End If

	' read tag
	Line Input #1, s
'	Debug.Print s
	nline += 1	' count lines for debug purposes
	If s = Empty Then GoTo ReadTags
	s = norm(s)
	If s = "" Then GoTo ReadTags

	' expand one-line tag into an exteded (multi-line) one
	eqpos = InStr(s,"=")
	If eqpos > 0 Then
		firstTag = Trim( Split(s, "=")(0) )
		Select Case UCase(firstTag)
		Case "IMAGE", "CONTOUR", "VECTOR", "BASE", "CAPTION"
			s = firstTag + "; FILE " + Mid(s, eqpos, Len(s)-eqpos+1) + "; /" + firstTag
		End Select
	End If

	' process tags separated by semicolon
	For ntag = 0 To UBound(Split(s,";"))
		If caption_tag_is_open And UCase(s)<>"\CAPTION" And UCase(s)<>"/CAPTION" Then
			' treat captions as just text, no splitting
		 	tag = ""
			tagValue = s
		Else
			' extract a tag unit (a string between 2 semicolons)
			tag_unit = Split(s,";")(ntag)
			' split the tag unit into TAG and VALUE (separated by =)
			tag = Trim(Split(tag_unit,"=")(0))
			If UBound(Split(tag_unit,"=")) > 0 Then
				tagValue = Trim(Split(tag_unit,"=")(1))
			Else
				tagValue = ""
			End If
		End If
		utag = UCase(tag)
		' process the tag
		Select Case utag
			Case "END"
				Close #1
				Exit Sub
			Case "CHART"
				assert(Not chart_tag_is_open, "Unexpected opening tag: " + tag, nline)
				chart_tag_is_open = True
				nCharts += 1
				charts(nCharts).dict = defaults
			Case "IMAGE", "CONTOUR", "VECTOR", "BASE", "CAPTION"
				assert(Not chelm_tag_is_open, "Unexpected opening tag: " + tag, nline)
				chelm_tag_is_open = True
				mapTag = utag
				charts(nCharts).n_el += 1
				charts(nCharts).el(charts(nCharts).n_el).eType = utag
				charts(nCharts).el(charts(nCharts).n_el).dict = charts(nCharts).dict
				If utag="CAPTION" Then
					assert(Not caption_tag_is_open, "Unexpected CAPTION tag: " + tag, nline)
					caption_tag_is_open = True
				End If
			Case "/IMAGE", "/CONTOUR", "/VECTOR", "/BASE", "/CAPTION", _
				 "\IMAGE", "\CONTOUR", "\VECTOR", "\BASE", "\CAPTION"
				assert(chelm_tag_is_open, "Unexpected closing tag: " + tag, nline)
				chelm_tag_is_open = False
				mapTag = ""
				If utag="\CAPTION" Or utag="/CAPTION" Then
					assert(caption_tag_is_open, "Unexpected closing CAPTION tag: " + tag, nline)
					caption_tag_is_open = False
				End If
			Case "/CHART", "\CHART"
				assert(chart_tag_is_open, "Unexpected closing tag: " + tag, nline)
				chart_tag_is_open = False
			Case Else
				' add the tag to either of: default, chart or chart-element dictionary
				If chart_tag_is_open Then
					If chelm_tag_is_open Then
'						If mapTag = "VECTOR" And utag = "FILE" Then _
'							assert(UBound(Split(tagValue,"+"))=1, "VECTOR tag must have x- and y-filenames. E.G.: FILE = u+v", nline)
						If caption_tag_is_open Then
							' if the caption has >1 lines then add these lines to CAPTION-key separated by EOL symbol (code 10)
							AddKey(         charts(nCharts).el(charts(nCharts).n_el).dict, "CAPTION", _
							   ValueByKey(charts(nCharts).el(charts(nCharts).n_el).dict, "CAPTION") + tagValue + String(1,10)  )
							'Debug.Print ValueByKey(charts(nCharts).el(charts(nCharts).n_el).dict, "CAPTION")
						Else
							AddKey(charts(nCharts).el(charts(nCharts).n_el).dict, utag, tagValue)
						End If
					Else
						AddKey(charts(nCharts).dict, utag, tagValue)
					End If
				Else
					AddKey(defaults, utag, tagValue)
				End If
		End Select
	Next ntag
GoTo ReadTags
End Sub

' Replace variable tag values with the actual ones
Sub convertVarTags
	For i = 1 To ncharts
		With charts(i)
			For n = 1 To .dict.n_param
				Do
					tagValue = .dict.Value(n)
					n1 = InStr(tagValue,"<")
					n2 = InStr(tagValue,">")
					If n1>0 And n2>0 Then
						varTag = Mid(tagValue, n1+1, n2-n1-1)
						.dict.Value(n) = Replace(.dict.Value(n)    , _
												 "<" + varTag + ">", _
												 ValueByKey(.dict, UCase(varTag)))
					Else
						Exit Do
					End If
				Loop
			Next n
			For m = 1 To .n_el
			For n = 1 To .el(m).dict.n_param
				Do
					tagValue = .el(m).dict.Value(n)
					n1 = InStr(tagValue,"<")
					n2 = InStr(tagValue,">")
					If n1>0 And n2>0 Then
						varTag = Mid(tagValue, n1+1, n2-n1-1)
						.el(m).dict.Value(n) = Replace(.el(m).dict.Value(n), _
													   "<" + varTag + ">"  , _
													   ValueByKey(.el(m).dict, UCase(varTag)))
					Else
						Exit Do
					End If
				Loop
			Next n
			Next m
		End With
	Next i
End Sub





Sub Main
	Debug.Clear
	nCharts = 0

' read settings
	ParseSettings(CurDir + "\_defaults.cfg")
	ParseSettings(CurDir + "\_plot.cfg")

	printDict(charts(1).el(3).dict)


Stop
Exit All

	Begin Dialog UserDialog 340,98 ' %GRID:10,7,1,1
		OKButton 30,21,270,49
	End Dialog
	Dim dlg As UserDialog
	Dialog dlg
End Sub


