Attribute VB_Name = "Module1"
'#Uses "Dictionary.bas"
'#Uses "utils.bas"

Public Doc As Object
Public SurferApp As Object
Public PageSetup As Object

' Some global constants
Public Const MANY = 24
Public Const N_TS = 10000  ' max number of timesteps loaded

' default parameters, can be overriden inside a CHART-tag
Public defaults As Dictionary

' position on the document
Type Position
	x As Double
	y As Double
	width As Double
	height As Double
	xy_ratio As Double
End Type

' Chart Element data structure = ONE Caption or Contour, Image, Vectors or Base + Legend
Type ChartElement
	treeName As String
	eType As String		' Image, Contour, Vector, Basemap or Caption
	pos As Position
	dict As Dictionary	' dictionary of element settings
	' ids
	id  As String
	idx As String
	idy As String
	' paths
	grdFile  As String
	grdFileX As String
	grdFileY As String
	timeFile As String
	' time info
	timeStamps(1 To N_TS) As String
	timeSteps (1 To N_TS) As String
	n_times As Integer	' actual number of time steps
	tIndex As Integer  ' current time index in the timeStamps array
End Type

' Chart = set of overlayed Maps + Captions
Type Chart
	dict As Dictionary	' dictionary of chart settings
	el(1 To MANY) As ChartElement
	n_el As Integer
	n_captions As Integer
	pos As Position
	' mapFrame = set of maps: contours, images, vectors, etc.
	MapFrame As Object
	caption (1 To 10) As Object
End Type


Public charts (0 To MANY) As Chart  ' actually index starts from 1, zero is for convenience
Public nCharts As Integer






