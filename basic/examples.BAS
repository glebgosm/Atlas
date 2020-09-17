' Call external program
Sub Main
	Shell("d:\list.exe")
End Sub


' Import data from netcdf
' Only 2d-fields are supported
' Automation import does not work (bug?)
Sub Main
	Dim SurferApp As Object
    Set SurferApp = CreateObject("Surfer.Application")
    SurferApp.Visible = True
    Dim Plot As Object
    Set Plot = SurferApp.Documents.Add(srfDocPlot)
    Plot.Import2(FileName:="D:\cp.nc", FilterId:="netcdf", Options:="VariableName=ssl_save_cp")
  ' Plot.Import2(FileName:="D:\lsm_int.NC", Options:="VariableName=lsm")
End Sub


	' throws exception!
	'Set MapFrame2 = map.Overlays.BreakApart(pOverlay:=map.Overlays(2))
	'Mapframe2.Select
	'Doc.Selection.Delete
