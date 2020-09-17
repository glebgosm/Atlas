Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "DataStructure.bas"
'#Uses "utils.bas"
'#Uses "PlotImage.bas"
'#Uses "PlotVectors.bas"
'#Uses "PlotContour.bas"
'#Uses "PlotBasemap.bas"



Sub prepareChart(Chart,mType)
	With Chart
		' Hide/Show Axes of the entire chart
        Dim Axes As Object
        Set Axes = .MapFrame.Axes
        For i=1 To 4
            Axes(i).Visible = s2bool(ValueByKey(.dict,"SHOW_MAP_AXES"))
        Next i
		' make mapframe proportions x:y = 1:1
		Set map = Chart.MapFrame.Overlays(1)
		If mType = "bln" Then
			.pos.xy_ratio = (map.yMax-map.yMin) / (map.xMax-map.xMin)
		End If
		If mType = "img" Or mType = "cnt" Then
			.pos.xy_ratio = (map.Grid.NumRows) / (map.Grid.NumCols)
		End If
		If mType = "vec" Then
			.pos.xy_ratio = (map.GradientGrid.NumRows) / (map.GradientGrid.NumCols)
		End If

	    If .pos.xy_ratio >= 1 Then
	        .MapFrame.Height = .pos.Height
	        .MapFrame.Width  = .MapFrame.Height / .pos.xy_ratio
	    Else
	        .MapFrame.Width = .pos.Width
	        .MapFrame.Height  = .MapFrame.Width * .pos.xy_ratio
	    End If
	    ' set position of the chart
	    .MapFrame.Left   = .pos.x
	    .MapFrame.Top    = .pos.y
	    ' set name of the chart
        .MapFrame.Name = ValueByKey(.dict, "NAME")
	End With
End Sub


