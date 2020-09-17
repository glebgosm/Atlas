Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "DataStructure.bas"
'#Uses "ParseSettings.bas"
'#Uses "utils.bas"
'#Uses "ColorScale.bas"
'#Uses "PlotCharts.bas"


' set image map defaults
Sub initPlotContour
	Addkey(defaults, "CFILL", "false")
	Addkey(defaults, "CLAB_NUM_DIGITS", "3")
	Addkey(defaults, "CLAB_FONTSIZE", "8")
	Addkey(defaults, "CLAB_FREQ", "1")
	Addkey(defaults, "CLEV_METHOD", "linear")
End Sub

' plot a contour as a part of a chart
Function PlotContour(Chart, contour)
	If Chart.MapFrame Is Nothing Then
		' create a new mapframe with one contour layer
		Set Chart.MapFrame = Doc.Shapes.AddContourMap(contour.grdFile)
		Set map = Chart.MapFrame.Overlays(1)
		' general settings of the MapFrame
		prepareChart(chart,"cnt")
	Else ' add a new layer to the existing mapFrame
		Set map = Doc.Shapes.AddContourLayer(map:=Chart.MapFrame, GridFileName:=contour.grdFile)
	End If
	' contour settings
	With map
		.Name = contour.treeName
		mn = .LevelMinimum
		mx = .LevelMaximum
		If ValueByKey(contour.dict,"MIN") <> "" Then mn = CDbl(ValueByKey(contour.dict,"MIN"))
		If ValueByKey(contour.dict,"MAX") <> "" Then mx = CDbl(ValueByKey(contour.dict,"MAX"))
		If LCase(ValueByKey(contour.dict, "CLEV_METHOD")) = "linear" Then
			.SetSimpleLevels(Min:=mn, Max:=mx, Interval:=.LevelInterval)
		Else
			.SetLogarithmicLevels(Min:=mn, Max:=mx, LevelsInDecade:=.LevelsInDecade)
		End If

		.FillContours = s2bool(ValueByKey(contour.dict, "CFILL"))
		.ShowMajorLabels = True
		.ShowMinorLabels = True
		.LabelEdgeDist = 0.01
		.LabelFormat.NumDigits = CInt(ValueByKey(contour.dict, "CLAB_NUM_DIGITS"))
		.LabelLabelDist = 0.2 * pow(.Height*.Width,0.5)
		.LabelTolerance = 1.5
		.LabelFont.Face = "Arial"
		.LabelFont.Size = CInt(ValueByKey(contour.dict, "CLAB_FONTSIZE"))
		.LevelMajorInterval = CInt(ValueByKey(contour.dict, "CLAB_FREQ"))
		'.MajorLine
		'.MinorLine
		.SmoothContours = srfConSmoothNone
	End With
	'map.ColorMap.SetDataLimits(imin, imax)
	'   color map
	Dim s As String
	s = ValueByKey(contour.dict, "LEVELS")
	If s <> "" Then map.Levels.LoadFile(FileName:=CurDir + "\surfer_presets\"+s)
	' 	missing data color
	s =	Replace( ValueByKey(contour.dict, "BLANK_COLOR"), "(", "")  ' e.g. "(100,100,100)"
	s =	Replace( s, ")", "")
	map.BlankFill.ForeColorRGBA.Red   = Split(s,",")(0)
	map.BlankFill.ForeColorRGBA.Green = Split(s,",")(1)
	map.BlankFill.ForeColorRGBA.Blue  = Split(s,",")(2)
	' 	color scale
	map.ShowColorScale = s2bool(ValueByKey(contour.dict, "SHOW_COLORSCALE"))
	map.ShowColorScale = map.ShowColorScale And s2bool(ValueByKey(contour.dict, "CFILL"))
	If map.ShowColorScale Then handleColorScale(map,chart,contour)
End Function
