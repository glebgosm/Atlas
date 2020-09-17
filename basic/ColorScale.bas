Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "DataStructure.bas"
'#Uses "utils.bas"

Sub handleColorScale(map,Chart,ChartElement)
		map.ColorScale.Name = map.Name + " - ColorScale"
		' map.ColorScale.LabelInterval = (map.Grid.zMax - map.Grid.zMin)/5.
		'Debug.Print ValueByKey(ChartElement.dict, "COLORSCALE_NUM_DIGITS")
		map.ColorScale.LabelFormat.NumDigits = ValueByKey(ChartElement.dict, "COLORSCALE_NUM_DIGITS")
		map.ColorScale.LabelFont.Size = CLng(ValueByKey(ChartElement.dict, "COLORSCALE_FONTSIZE"))
		' color scale position and sizes
		ratio = map.ColorScale.Height / map.ColorScale.Width
		map.ColorScale.Height = Chart.MapFrame.Height * 0.85
		map.ColorScale.Width  = map.ColorScale.Height / ratio
		map.ColorScale.Left = Chart.pos.x +  Chart.MapFrame.Width * 1.01
		map.ColorScale.Top  = Chart.pos.y - (Chart.MapFrame.Height-map.ColorScale.Height)/2
		' limit colorscale width to 0.75 inches
		ratio = map.ColorScale.Width / min(map.ColorScale.Width, 0.75)
		map.ColorScale.Width  = map.ColorScale.Width  / ratio
		map.ColorScale.Height = map.ColorScale.Height / ratio
End Sub

