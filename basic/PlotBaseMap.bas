Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "DataStructure.bas"
'#Uses "ParseSettings.bas"
'#Uses "utils.bas"
'#Uses "PlotCharts.bas"


' set base map defaults
Sub initPlotBasemap
	Addkey(defaults, "BFILL", "true")
	Addkey(defaults, "BFILL_COLOR", "(250,190,120)")
	Addkey(defaults, "BLINE_STYLE", "None")
	Addkey(defaults, "BLINE_COLOR", "(0,0,0)")
End Sub

' plot a basemap as a part of a chart
Function PlotBasemap(Chart, basemap)
	' add file extention if necessary
	If InStrRev(basemap.grdFile,".bln")<>Len(basemap.grdFile)-3 Then _
		basemap.grdFile = basemap.grdFile + ".bln"
	' plot
	If Chart.MapFrame Is Nothing Then
		' create a new mapframe with one basemap layer
		Set Chart.MapFrame = Doc.Shapes.AddVectorBaseMap(basemap.grdFile)
		Set map = Chart.MapFrame.Overlays(1)
		' general settings of the MapFrame
		prepareChart(Chart,"bln")
	Else ' add a new layer to the existing mapFrame
		Set map = Doc.Shapes.AddVectorBaseLayer(map:=Chart.MapFrame, ImportFileName:=basemap.grdFile)
	End If
	' basemap settings
	With map
		.Name = basemap.treeName
		If s2bool(ValueByKey(basemap.dict, "BFILL")) Then
			.Fill.Pattern = "Solid"
			s =	Replace( ValueByKey(basemap.dict, "BFILL_COLOR"), "(", "")  ' e.g. "(100,100,100)"
			s =	Replace( s, ")", "")
			.Fill.ForeColorRGBA.Red   = Split(s,",")(0)
			.Fill.ForeColorRGBA.Green = Split(s,",")(1)
			.Fill.ForeColorRGBA.Blue  = Split(s,",")(2)
		Else
			.Fill.Pattern = "None"
		End If
		Select Case LCase(ValueByKey(basemap.dict, "BLINE_STYLE"))
		Case "solid"
			.Line.Style = "Solid"
			s =	Replace( ValueByKey(basemap.dict, "BLINE_COLOR"), "(", "")  ' e.g. "(100,100,100)"
			s =	Replace( s, ")", "")
			.Line.ForeColorRGBA.Red   = Split(s,",")(0)
			.Line.ForeColorRGBA.Green = Split(s,",")(1)
			.Line.ForeColorRGBA.Blue  = Split(s,",")(2)
		Case Else
			.Line.Style = "invisible"
		End Select
	End With
End Function
