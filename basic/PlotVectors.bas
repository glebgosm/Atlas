Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "DataStructure.bas"
'#Uses "utils.bas"
'#Uses "PlotCharts.bas"

' vector map defaults
Sub initPlotVectors
	' vector map defaults
	AddKey(defaults, "VSHOW_LEGEND", "true")
	AddKey(defaults, "VECTOR_SIZE", "0.2")
	AddKey(defaults, "SHOW_VECTOR_LEGEND", "true")
	AddKey(defaults, "VLEGEND_FONTSIZE", "12")
	AddKey(defaults, "VCOLOR", "(0,0,0)")
End Sub



			'VectorMap.SymbolLine.Width = 0.05

Function PlotVectors(Chart, vector)
	If Chart.MapFrame Is Nothing Then
		' create a new mapframe with one image layer
        Set Chart.MapFrame = Doc.Shapes.AddVectorMap(GridFileName1 := vector.grdFileX, _
                                                     GridFileName2 := vector.grdFileY)
        Set map = Chart.MapFrame.Overlays(1)
        ' general settings of the MapFrame
		prepareChart(Chart,"vec")
    Else ' add a new layer to the existing mapFrame
        Set map = Doc.Shapes.AddVectorLayer(map:=Chart.MapFrame, GridFileName1 := vector.grdFileX, _
                                                                 GridFileName2 := vector.grdFileY)
    End If
	' vectors settings
    map.Name = vector.treeName
    map.SymbolOrigin = srfOrgCenter
	map.Symbol = 1 ' simple arrow
	' arrow color
	s =	Replace( ValueByKey(vector.dict, "VCOLOR"), "(", "")  ' e.g. "(100,100,100)"
	s =	Replace( s, ")", "")
	map.SymbolLine.ForeColorRGBA.Red   = Split(s,",")(0)
	map.SymbolLine.ForeColorRGBA.Green = Split(s,",")(1)
	map.SymbolLine.ForeColorRGBA.Blue  = Split(s,",")(2)
	' arrow frequency
	If valueByKey(vector.dict, "VFREQ") <> "" Then
		map.xFrequency = CLng( valuebykey(vector.dict, "VFREQ") )
		map.yFrequency = CLng( valuebykey(vector.dict, "VFREQ") )
	Else
		map.xFrequency = 1 + map.AspectGrid.NumCols \ 125
		map.yFrequency = map.xFrequency
	End If
	' max value to show
	If valueByKey(vector.dict, "MAX") = "" Then
		map.SetScaling(srfVSMagnitude  , 0.0, map.MaxDataMagnitude)
	Else
		map.SetScaling(srfVSMagnitude  , 0.0, valueByKey(vector.dict, "MAX"))
	End If
	' arrow size
	s = valueByKey(vector.dict, "VECTOR_SIZE")
	map.SetScaling(srfVSShaftLength, 0.0, CDbl(Replace(s, ".", ",") )  )
	map.SetScaling(srfVSHeadLength , 0.0, CDbl(Replace(s, ".", ",") )/3)
	map.SetScaling(srfVSSymWidth   , 0.0, CDbl(Replace(s, ".", ",") )/3)
	' arrow thickness
	map.SymbolLine.Width = 0.0015
	s = valueByKey(vector.dict, "VWIDTH")
	If s <> "" Then map.SymbolLine.Width = CDbl(Replace(s,".",","))
	' vector legend
	map.ShowLegend = s2bool(ValueByKey(vector.dict, "SHOW_VECTOR_LEGEND"))
	If map.ShowLegend Then
    	map.Legend.Title = ""
		map.Legend.FrameLine.Style = "Invisible"
		map.Legend.LabelFont.Size = ValueByKey(vector.dict, "VLEGEND_FONTSIZE")
		' Truncate legend to 1 digit value
		vm = map.MaxDataMagnitude
		'   get value in the range 1.0 .. 9.999
		c = 0
		If vm <> 0 Then
			While Abs(vm) < 1.
				vm = vm * 10.0
				c = c+1
			Wend
			While Abs(vm) > 10.
				vm = vm / 10.0
				c = c-1
			Wend
			vm = CInt(vm) ' get value in the range 1..9
			For i=1 To Abs(c) Step 1
				If c > 0 Then vm = vm / 10.0
				If c < 0 Then vm = vm * 10.0
			Next
		End If
		map.Legend.Magnitudes = Replace(CStr(vm), ",", ".")
	End If
End Function
