' =============================================================================
' GridAndMap.bas
' Golden Software Surfer - Scripter Script
'
' This script performs the following:
'   1. Grids a text data file using Triangulation with Linear Interpolation
'   2. Applies a log Z-transform during gridding (saves output as linear values)
'   3. Blanks the grid using a BLN boundary file (assigns NoData outside boundary)
'   4. Creates a new plot with a Color Relief map from the blanked grid
'   5. Configures terrain representation to Color Only
'   6. Loads a custom color map from a CLR file
'   7. Sets the color map to use logarithmic data scaling
'
' Requirements:
'   - Golden Software Surfer (version 16 or later recommended)
'   - A well-formatted text data file with X, Y, Z columns
'   - A BLN boundary file defining the NoData region
'   - A CLR color map file for the color relief display
'
' Usage:
'   1. Open Scripter (included with Surfer)
'   2. Open this script (File > Open)
'   3. Edit the CONFIGURATION section below to set your file paths and parameters
'   4. Run the script (Script > Run)
' =============================================================================

Sub Main

    ' =========================================================================
    ' CONFIGURATION - Edit these values before running the script
    ' =========================================================================

    ' --- File Paths ---
    Dim DataFile As String
    Dim BlnFile As String
    Dim ColorMapFile As String
    Dim OutGridFile As String

    DataFile     = "C:\Data\input_data.txt"       ' Input text data file (X, Y, Z)
    BlnFile      = "C:\Data\boundary.bln"          ' BLN boundary file for blanking
    ColorMapFile = "C:\Data\colormap.clr"           ' CLR color map file
    OutGridFile  = "C:\Data\output.grd"             ' Output grid file

    ' --- Data Column Assignments (1-based column index) ---
    Dim xCol As Long
    Dim yCol As Long
    Dim zCol As Long

    xCol = 1    ' Column containing X coordinates
    yCol = 2    ' Column containing Y coordinates
    zCol = 3    ' Column containing Z values

    ' --- Grid Cell Spacing ---
    Dim xSpacing As Double
    Dim ySpacing As Double

    xSpacing = 10.0     ' Cell size in the X direction
    ySpacing = 10.0     ' Cell size in the Y direction

    ' =========================================================================
    ' INITIALIZE SURFER
    ' =========================================================================

    Dim SurferApp As Object
    Set SurferApp = CreateObject("Surfer.Application")
    SurferApp.Visible = True

    Debug.Print "Surfer application started."

    ' =========================================================================
    ' STEP 1: CREATE THE GRID
    '   Method:      Triangulation with Linear Interpolation
    '   Z-Transform: Log, save as Linear
    '   Cell Size:   Defined by xSpacing and ySpacing above
    ' =========================================================================

    Debug.Print "Gridding data file: " & DataFile

    SurferApp.GridData6 _
        DataFile:=DataFile, _
        xCol:=xCol, _
        yCol:=yCol, _
        zCol:=zCol, _
        Algorithm:=srfTriangulation, _
        xSize:=xSpacing, _
        ySize:=ySpacing, _
        ZTransformMethod:=srfZTransformLogSaveAsLinear, _
        OutGrid:=OutGridFile, _
        OutFmt:=srfGridFmtS7, _
        ShowReport:=False

    Debug.Print "Grid created: " & OutGridFile

    ' =========================================================================
    ' STEP 2: BLANK THE GRID WITH THE BLN BOUNDARY
    '   Grid nodes outside the BLN boundary polygon are set to NoData.
    ' =========================================================================

    Debug.Print "Blanking grid with boundary: " & BlnFile

    SurferApp.GridBlank _
        InGrid:=OutGridFile, _
        BlankFile:=BlnFile, _
        OutGrid:=OutGridFile, _
        OutFmt:=srfGridFmtS7

    Debug.Print "Grid blanked successfully."

    ' =========================================================================
    ' STEP 3: CREATE A NEW PLOT WITH A COLOR RELIEF MAP
    ' =========================================================================

    Debug.Print "Creating color relief map..."

    ' Create a new plot document
    Dim PlotDoc As Object
    Set PlotDoc = SurferApp.Documents.Add(srfDocPlot)

    ' Add the blanked grid as a Color Relief map layer
    Dim MapFrame As Object
    Set MapFrame = PlotDoc.Shapes.AddColorReliefMap(GridFileName:=OutGridFile)

    ' =========================================================================
    ' STEP 4: CONFIGURE THE COLOR RELIEF LAYER
    '   - Terrain Representation: Color Only (no hill shading or reflectance)
    '   - Color Map:              Loaded from external CLR file
    '   - Scaling:                Logarithmic
    ' =========================================================================

    ' Access the Color Relief layer from the map frame overlays
    Dim ColorReliefLayer As Object
    Set ColorReliefLayer = MapFrame.Overlays(1)

    ' Set terrain representation to Color Only (no illumination effects)
    ColorReliefLayer.ReliefMethod = srfReliefColorOnly

    ' Show the color scale bar on the map
    ColorReliefLayer.ShowColorScale = True

    ' Load the custom color map from the CLR file
    ColorReliefLayer.ColorMap.LoadFile(ColorMapFile)

    ' Set the color map to use logarithmic data scaling
    ColorReliefLayer.ColorMap.ScalingMethod = srfColorScalingLog

    Debug.Print "Color relief map configured."
    Debug.Print "Script completed successfully."

End Sub
