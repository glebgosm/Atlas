Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "DataStructure.bas"
'#Uses "ParseSettings.bas"
'#Uses "utils.bas"
'#Uses "PlotCharts.bas"
'#Uses "ColorScale.bas"
'#Uses "PlotImage.bas"
'#Uses "PlotVectors.bas"
'#Uses "PlotContour.bas"
'#Uses "PlotBasemap.bas"

Dim ATLAS_PATH As String
Dim outDir As String
Dim inDir As String

Dim animation As Boolean

Dim matrix_dim_x As Integer
Dim matrix_dim_y As Integer

Sub Main
	'ATLAS_PATH = "D:\ATLAS\"
	'ChDir ATLAS_PATH
	Debug.Clear
	Debug.Print "CurDir = " + CurDir

' initialize defaults
	AddKey(defaults, "CHARTS_PER_DOC", "1")
	AddKey(defaults, "MATRIX_DIM_X", "1")
	AddKey(defaults, "MATRIX_DIM_Y", "1")
	Addkey(defaults, "BLANK_COLOR", "(250,190,120)")
	Addkey(defaults, "SHOW_COLORSCALE", "true")
	Addkey(defaults, "COLORSCALE_NUM_DIGITS", "3")
	Addkey(defaults, "COLORSCALE_FONTSIZE", "12")
	' set defaults
	initPlotImage
	initPlotContour
	initPlotVectors
	initPlotBasemap

' read settings
	nCharts = 0
	ParseSettings(CurDir + "\_defaults.cfg")
	ParseSettings(CurDir + "\_plot.cfg")
	convertVarTags

' handle paths
 	 inDir = ValueByKey(defaults,  "INPUT_DIR")
	outDir = ValueByKey(defaults, "OUTPUT_DIR")
	 inDir = dirPath( inDir)
	outDir = dirPath(outDir)
	makeDir(outDir)

' output settings
	saveSrf = False
	printOut = False
	exportPng = False
	animation = False
	If InStr(LCase(valueByKey(defaults, "OUTPUT_MODE")), "srf")       > 0 Then saveSrf = True
	If InStr(LCase(valueByKey(defaults, "OUTPUT_MODE")), "print")     > 0 Then printOut = True
	If InStr(LCase(valueByKey(defaults, "OUTPUT_MODE")), "png")       > 0 Then exportPng = True
	If InStr(LCase(valueByKey(defaults, "OUTPUT_MODE")), "animation") > 0 Then animation = True

' Load data on time steps and make time stamps for every map
	loadTimeInfo

' initialize Surfer
	Set SurferApp = CreateObject("Surfer.Application")

' compute script parameters
	nChartsPerDoc = CInt(ValueByKey(defaults,"CHARTS_PER_DOC"))
	nDocs = nCharts  \  nChartsPerDoc
	If nCharts Mod nChartsPerDoc > 0 Then nDocs += 1
	matrix_dim_x = CInt(ValueByKey(defaults,"MATRIX_DIM_X"))
	matrix_dim_y = CInt(ValueByKey(defaults,"MATRIX_DIM_Y"))

' Plot and output
	nRuns = 1
	If animation Then nRuns = N_TS
	For nRun = 1 To nRuns Step 1
		nChart = 0
		For nDoc = 1 To nDocs Step 1
		' open new clean document
			Set Doc = SurferApp.Documents.Add(srfDocPlot)
			Set Plotwindow = Doc.Windows(1)
			Set PageSetup = Doc.PageSetup

		' make document title
			If valueByKey(defaults, "TITLE") <> "" Then
				Set docTitle = Doc.Shapes.AddText(0.0, 0.997*PageSetup.Height, valueByKey(defaults, "TITLE"))
				docTitle.Font.Size = 12
				docTitle.Left = PageSetup.LeftMargin ' put title at the doc left
				If saveSrf Or matrix_dim_x > 1 Then ' put title at the doc center
					docTitle.Left = docTitle.Left + 0.5*(PageSetup.Width - PageSetup.LeftMargin - PageSetup.RightMargin - docTitle.Width)
				End If
			End If

		' put time index into map dictionaries
			If animation Then
				For nch = nChart+1 To nChart + nChartsPerDoc Step 1
					For nmap = 1 To charts(nch).n_el Step 1
						AddKey(charts(nch).el(nmap).dict, "T", Trim(Str(nRun)))
					Next nmap
				Next nch
			End If

		' Plot doc
			PlotCharts(nChart+1, nChart + nChartsPerDoc)
			nChart = nChart + nChartsPerDoc

		' Output as image, .srf file or print out
			outFileName = valueByKey(defaults, "TARGET_FILE")
			If outFileName = "" Then outFileName = "atlas"

			If saveSrf Then
				If Not endsWith(outFileName,".srf") Then _
					outFileName = outFileName + ".srf"
				Doc.SaveAs(FileName:= outDir + outFileName)
			End If

			If printOut Then Doc.PrintOut(Method:=srfTruncate)

			If exportPng Or animation Then
				If outFileName = "" Then outFileName = "atlas.png"
				If animation Then outFileName = Trim(Str(nRun))
				If endsWith(outFileName,".srf") Then _
					outFileName = Mid(outFileName, 1, Len(outFileName)-4)
				If Not endsWith(outFileName,".png") Then _
					outFileName = outFileName + ".png"
				png_size_x = valueByKey(defaults, "PNG_SIZE_X")
				png_size_y = valueByKey(defaults, "PNG_SIZE_Y")
				Doc.Export(FileName:= outDir + outFileName, _
						   Options := "Width=" + png_size_x + ", Height=" + png_size_y)
				delFile(outDir + outFileName + ".gsr2")
			End If

			If Not saveSrf Then
				SurferApp.Documents.CloseAll(SaveChanges:=srfSaveChangesNo)
				SurferApp.Quit
			End If

		' Show doc and finish
			If nDoc = nDocs Then
				SurferApp.Visible = True
				SurferApp.WindowState = srfWindowStateMaximized
			End If
		Next nDoc
	Next nRun

	'MsgBox "done!"
End Sub


Function PlotCharts(n1,n2)
	nx = 0
	ny = 0
	' chart cell width and height (constant)
	cell_width = (PageSetup.Width -PageSetup.LeftMargin-PageSetup.RightMargin ) / matrix_dim_x
	cell_height= (PageSetup.Height-PageSetup.TopMargin -PageSetup.BottomMargin) / matrix_dim_y
	' top of a row of charts (variable)
	top_of_row = PageSetup.Height - PageSetup.TopMargin
	' max height of a row of charts
	max_row_height = 0
	' chart x-position
	x_pos_1d = PageSetup.LeftMargin

	' PLOT!
	For nChart = n1 To n2 Step 1
		If nChart > nCharts Then Exit Function
		With charts(nChart)
			' Position
			.pos.x = x_pos_1d
			If matrix_dim_y > 1 Then .pos.x = PageSetup.LeftMargin + nx * cell_width
			.pos.y = top_of_row
			.pos.Width = 0.98 * cell_width
			.pos.Height= 0.98 * cell_height
			nx = nx + 1

			' plot maps of the chart
			For nel = 1 To .n_el Step 1
				If .el(nel).eType = "CAPTION" Then GoTo next_nel
				.el(nel).pos = .pos
				' data path
				pth = dirPath( ValueByKey(.el(nel).dict, "INPUT_DIR") ) ' default dir
				If InStr(ValueByKey(.el(nel).dict, "FILE"), ":") > 0 Then pth = ""  ' don't use default dir for absolute file paths
				' file name
				fName = ValueByKey(.el(nel).dict, "FILE")
				.el(nel).grdFile = pth + fName
				If .el(nel).eType = "VECTOR" Then
					If Not isNCFile(fName) Then	' not an nc-file is provided => split grd-file names around "+"
						.el(nel).grdFileX = pth + Trim(Split(fName, "+")(0))
						.el(nel).grdFileY = pth + Trim(Split(fName, "+")(1))
					End If
				End If
				' set time tag "T" and time index tIndex of the map
				defineTimeIndex(.el(nel))
				' convert NetCDF file into grd
				If isNCFile(fName) Then convertNetCDF_to_grd(.el(nel))
				' set name of the map
				   .el(nel).treeName = ValueByKey(.el(nel).dict, "NAME")
				If .el(nel).treeName = "" Then .el(nel).treeName = CStr(nChart) + "_" _
														+ LCase(.el(nel).eType) + "_" + CStr(nel)
				' plot a map
				Select Case .el(nel).eType
				Case "IMAGE"
					PlotImage(charts(nChart), .el(nel))
				Case "CONTOUR"
					PlotContour(charts(nChart), .el(nel))
				Case "VECTOR"
					PlotVectors(charts(nChart), .el(nel))
				Case "BASE"
					PlotBasemap(charts(nChart), .el(nel))
				End Select
				next_nel:
			Next nel

			' make time stamp
			tStamp = ""
			For nel = 1 To .n_el Step 1
				If .el(nel).eType <> "CAPTION" Then
					indx = .el(nel).tIndex
					If indx > 0 Then tStamp = .el(nel).timeStamps(indx)
					If tStamp <> "" Then Exit For
				End If
			Next nel

			' delete temp files
			delFile(CurDir + "\nc2grd_1.grd")
			delFile(CurDir + "\nc2grd_2.grd")

			' update max height of the row
			max_row_height = max(.MapFrame.Height, max_row_height)

			' chart x-position
			If matrix_dim_y = 1 Then x_pos_1d = x_pos_1d + 1.05*.MapFrame.Width

            ' make captions
			For nel = 1 To .n_el Step 1
				.el(nel).pos = .pos
				' file paths
				If .el(nel).eType = "CAPTION" Then
					Dim capt As String
					capt = ValueByKey(.el(nel).dict, "CAPTION")
					' add timeStamp to caption
					If tStamp <> "" Then capt = capt + tStamp + String(1,10)
					If ValueByKey(.dict,"CAPTION_FONT_SIZE") = "" Then
						fontSize = 16 / matrix_dim_x
					Else
						fontSize = CDbl(ValueByKey(.dict,"CAPTION_FONT_SIZE"))
					End If
					capHeight = 10000
					.n_captions = 0
					For i=0 To UBound(Split(capt, String(1,10)))-1 Step 1
						Set .Caption(i+1) = Doc.Shapes.AddText(x:=.pos.x, _
															   y:=.pos.y-.MapFrame.Height-i*capHeight, _
															   Text := Split(capt, String(1,10))(i) )
						.Caption(i+1).Font.Size = fontSize
						capHeight = .Caption(i+1).Height
						.n_captions += 1
					Next i
				End If
			Next nel

            ' If mapframe doesn't fit into the cell with sizes  "pos.width by pos.height"
			' due to color scales, vector legends or captions => squeeze them all
			'    Step 1: find the squeeze ratio
			ratio = 1.
			' maps
			For nel = 1 To .n_el Step 1
				If .el(nel).eType = "CAPTION" Then GoTo Next_nel1  ' is there a continue operator in Basic???
				Set map = .MapFrame.Overlays(nel)
				csLegWidth = 0.0
				Select Case .el(nel).eType
				Case "IMAGE", "CONTOUR"
					If map.ShowColorScale Then csLegWidth = map.ColorScale.Width
					ratio= max(ratio, (csLegWidth + .MapFrame.Width*1.01) / .pos.Width)
				Case "VECTOR"
					If map.ShowLegend Then csLegWidth = map.Legend.Height
					ratio= max(ratio, (csLegWidth + .MapFrame.Height*1.01) / .pos.Height)
				End Select
				Next_nel1:
			Next nel

			' captions
			For nel = 1 To .n_el Step 1
				If .el(nel).eType = "CAPTION" And .n_captions > 0 Then
					ratio= max(ratio, (.n_captions * .Caption(.n_captions).Height + .MapFrame.Height*1.01) / .pos.Height)
				End If
			Next nel

			'    Step 2: squeeze the maps, legends and move captions
			.MapFrame.Width  = .MapFrame.Width  / ratio
			.MapFrame.Height = .MapFrame.Height / ratio
			' squeeze legends
			For nel = 1 To .n_el Step 1
				If .el(nel).eType = "CAPTION" Then GoTo Next_nel2
				Set map = .MapFrame.Overlays(nel)
				Select Case .el(nel).eType
				Case "IMAGE", "CONTOUR"
					If map.ShowColorScale Then
						map.ColorScale.Width  = map.ColorScale.Width  / ratio
						map.ColorScale.Height = map.ColorScale.Height / ratio
						map.ColorScale.Left = .pos.x + .MapFrame.Width * 1.01
						map.ColorScale.Top  = .pos.y - (.MapFrame.Height-map.ColorScale.Height)/2
						x_pos_1d = map.ColorScale.Left + 1.3*map.ColorScale.Width
					End If
				Case "VECTOR"
					If map.ShowLegend Then
						map.Legend.Width  = map.Legend.Width  / ratio
						map.Legend.Height = map.Legend.Height / ratio
						map.Legend.Left = .pos.x + .MapFrame.Width - map.Legend.Width
						map.Legend.Top  = .pos.y - .MapFrame.Height
						max_row_height = max(max_row_height, .pos.y - map.Legend.Top + map.Legend.Height*1.5)
					End If
				End Select
				Next_nel2:
			Next nel

			' move captions
			For i=1 To .n_captions Step 1
				'.Caption(i).Width  = .Caption(i).Width  /ratio
				'.Caption(i).Height = .Caption(i).Height /ratio
				.Caption(i).Top = .pos.y - .MapFrame.Height - (i-1)*.Caption(i).Height
				max_row_height = max(max_row_height, .pos.y - .Caption(i).Top + .Caption(i).Height*2)
			Next i

			' prepare a new chart row
			If nx >= Int(matrix_dim_x) Then
				nx = 0
				ny = ny+1
				top_of_row = top_of_row - max_row_height * 1.05
				max_row_height = 0
			End If

			' prepare next animation frame
			If animation Then Set .MapFrame = Nothing
		End With
	Next nChart
End Function


' Convert a data array from NetCDF input file into .grd-file.
' For vector fields convert 2 arrays.
Sub convertNetCDF_to_grd(map)
	' select 2-grd or 1-grd-file mode
	doVector = False
	ndim = 1
	If map.eType = "VECTOR" Then
		doVector = True
		ndim = 2
	End If

	' Form command line to convert netcdf to grd
	For i = 1 To ndim Step 1
		field = Split(ValueByKey(map.dict, "FIELD"), "+")(i-1)
		cKeys = ""
		v = ValueByKey(map.dict, "I")
		If v <> "" Then	cKeys = cKeys + " " + "i " + v + " "
		v = ValueByKey(map.dict, "J")
		If v <> "" Then	cKeys = cKeys + " " + "j " + v + " "
		v = ValueByKey(map.dict, "K")
		If v <> "" Then	cKeys = cKeys + " " + "k " + v + " "
		v = ValueByKey(map.dict, "T")
		If v <> "" Then	cKeys = cKeys + " " + "t " + v + " "
		v = ValueByKey(map.dict, "I1")
		If v <> "" Then	cKeys = cKeys + " " + "i1 " + v + " "
		v = ValueByKey(map.dict, "I2")
		If v <> "" Then	cKeys = cKeys + " " + "i2 " + v + " "
		v = ValueByKey(map.dict, "J1")
		If v <> "" Then	cKeys = cKeys + " " + "j1 " + v + " "
		v = ValueByKey(map.dict, "J2")
		If v <> "" Then	cKeys = cKeys + " " + "j2 " + v + " "
		v = ValueByKey(map.dict, "K1")
		If v <> "" Then	cKeys = cKeys + " " + "k1 " + v + " "
		v = ValueByKey(map.dict, "K2")
		If v <> "" Then	cKeys = cKeys + " " + "k2 " + v + " "
		v = ValueByKey(map.dict, "T1")
		If v <> "" Then	cKeys = cKeys + " " + "t1 " + v + " "
		v = ValueByKey(map.dict, "T2")
		If v <> "" Then	cKeys = cKeys + " " + "t2 " + v + " "
		v = ValueByKey(map.dict, "LC")
		If v <> "" Then	cKeys = cKeys + " " + "lc " + v + " "

		' file name
		outFile = CurDir + "\nc2grd_" + Trim(Str(i)) + ".grd"

		' delete the temp file
		delFile(outFile)

		' call nc2grd utility to extract data from nc-file and put it in a grd file
		cmd = CurDir + "\utils\nc2grd.exe " + map.grdFile + " " + field + " " + cKeys + outFile
		Debug.Print CurDir + ">" + cmd
		Shell(cmd)
		waitFileCreation(outFile)

		' replace file name with grd file
		If doVector Then
			If i=1 Then map.grdFileX = outFile
			If i=2 Then map.grdFileY = outFile
		Else
						map.grdFile  = outFile
		End If

	Next i
End Sub


' Define which time step to plot, if needed:
' use value of the TIMESTEP tag or prompt user to make T-tag
Sub defineTimeIndex(map)
	map.tIndex = 1
	If animation Then
		map.tIndex = CLng( valueByKey(map.dict, "T") )
	Else
		timestep = LCase(ValueByKey(map.dict, "TIMESTEP"))
		If timestep = "ask" Then
			' make a copy of map.timeStamps array to feed it to the DropListBox
			Dim ts_list(1 To N_TS) As String
			For i=1 To map.n_times Step 1
				ts_list(i) = map.timeStamps(i)
			Next i
			' Choose custom time step
			Begin Dialog UserDialog 350,100
			        Text 10,10,280,15, "Choose the timestep for the map " + ValueByKey(map.dict, "NAME")
			        DropListBox 10,25,330,400, ts_list$(), .nn
			        OKButton 125,65,100,20
			End Dialog
			Dim dlg As UserDialog
			dlg.nn = map.n_times
			Dialog dlg ' show dialog (wait for ok)
			map.tIndex = dlg.nn
		Else
			If timestep = "last" Then
				map.tIndex = map.n_times
			Else
				If timestep <> "" Then
					For i = 1 To map.n_times Step 1
						If timestep = Trim(map.timeSteps(i)) Then
							map.tIndex = i
							Exit For
						End If
					Next i
				End If
			End If
		End If
		AddKey(map.dict, "T", CStr(map.tIndex))
	End If
End Sub


' Load time info from data files for each map of every chart
' Store time-stamps array (timeStamps)
Sub loadTimeInfo
	For nch = 1 To nCharts Step 1
	With charts(nch)
		For nel = 1 To .n_el Step 1
			If .el(nel).eType = "CAPTION" Then GoTo skipEl
			' create txt file with time info
			fName = inDir + valueByKey(.el(nel).dict, "FILE")
			If isNCFile(fName) Then
				' set time-file name
				.el(nel).timeFile = Mid(fName, 1, Len(fName)-3) + "_time.txt"
				' delete the old time file
				delFile(.el(nel).timeFile)
				' export time steps from .nc-file as a txt file
				cmd = CurDir + "\utils\timeInfo.exe " + fName + " " + .el(nel).timeFile
				Debug.Print CurDir + ">" + cmd
				Shell(cmd)
				waitFileCreation(.el(nel).timeFile)
			Else
				' the file must have been created in advance
				.el(nel).timeFile = inDir + "time.in"
				' if time file is absent => exit
				If Not fileExists(.el(nel).timeFile) Then
					Debug.Print "Time-file " + inDir + "time.in" + " doesn't exist."
					Exit Sub
				End If
			End If

			' read time data from the txt file
			Dim ts     As String
			Dim tMin   As String
			Dim tHour  As String
			Dim tDay   As String
			Dim tMonth As String
			Dim tYear  As String
			n = 0
			Open .el(nel).timeFile For Input As #1
			Do
				If EOF(1) Then Exit Do
				n = n+1
				Input #1,            			   ts, tYear, tMonth, tDay, tHour, tMin
				.el(nel).timeStamps(n) = timeStamp(ts, tYear, tMonth, tDay, tHour, tMin)
				.el(nel).timeSteps(n) = ts
			Loop
			.el(nel).n_times = n
			Close #1
			skipEl:
		Next nel
	End With
	Next nch
End Sub



'Sub serializeCharts
'	For nChart = 1 To nCharts Step 1
'		For nel = 1 To .n_el Step 1
'
'		Next
'	Next
'End Sub
