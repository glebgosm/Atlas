Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "DataStructure.bas"
'#Uses "utils.bas"
'#Uses "PlotCharts.bas"
'#Uses "ColorScale.bas"

' set image map defaults
Sub initPlotImage
	AddKey(defaults, "INTERPOLATE_PIXELS", "false")
End Sub

' plot an image as a part of a chart
Function PlotImage(Chart, image)
	If Chart.MapFrame Is Nothing Then
		' create a new mapframe with one image layer
		Set Chart.MapFrame = Doc.Shapes.AddColorReliefMap(image.grdFile)
		Set map = Chart.MapFrame.Overlays(1)
		' general settings of the MapFrame
		prepareChart(Chart,"img")
	Else ' add a new layer to the existing mapFrame
		Set map = Doc.Shapes.AddColorReliefLayer(map:=Chart.MapFrame, GridFileName:=image.grdFile)
	End If
	' Image settings
	map.Name = image.treeName
	map.HillShading = False
	map.InterpolatePixels = s2bool(ValueByKey(image.dict, "INTERPOLATE_PIXELS"))
	'   set image min and max
	imin = map.Grid.zMin
	imax = map.Grid.zMax
	If ValueByKey(image.dict,"MIN") <> "" Then imin = CDbl(Replace(ValueByKey(image.dict,"MIN"), ".", ","))
	If ValueByKey(image.dict,"MAX") <> "" Then imax = CDbl(Replace(ValueByKey(image.dict,"MAX"), ".", ","))
	map.ColorMap.SetDataLimits(imin, imax)
	'   color map
	Dim s As String
	s = ValueByKey(image.dict, "COLORS")
	If s <> "" Then map.ColorMap.LoadFile(FileName:=CurDir + "\surfer_presets\"+s)
	' 	missing data color
	s =	Replace( ValueByKey(image.dict, "BLANK_COLOR"), "(", "")  ' e.g. "(100,100,100)"
	s =	Replace( s, ")", "")
	map.MissingDataColorRGBA.Red   = Split(s,",")(0)
	map.MissingDataColorRGBA.Green = Split(s,",")(1)
	map.MissingDataColorRGBA.Blue  = Split(s,",")(2)
	' 	color scale
	map.ShowColorScale = s2bool(ValueByKey(image.dict, "SHOW_COLORSCALE"))
	If map.ShowColorScale Then handleColorScale(map,Chart,image)
	' color map
	'	If image.colors <> "" Then		' load color map from file
	'		imageMap.ColorMap.LoadFile( LVL_DIR + Split(LCase(image.colors),".clr")(0) + ".clr" )
	'	Else							' generate color map
	'		Dim cnodes(1) As Double
	'		cnodes(0)=0.0
	'		cnodes(1)=1.0
	'		Dim Colors(1) As Long
	'		Colors(0)=srfColorSkyBlue
	'		Colors(1)=srfColorOrange
	'		imageMap.ColorMap.SetNodes(Positions:=cnodes, Colors:=Colors)
	'	End If
End Function
