' =============================================================================
' GridAndMap.bas
' Golden Software Surfer 30 - Scripter Script
'
' This script performs the following:
'   1. Grids a comma-delimited .dat data file using Triangulation with
'      Linear Interpolation, with a log Z-transform (saved as linear)
'   2. Blanks the grid using a BLN boundary file (NoData outside boundary)
'   3. Creates a new plot with a Color Relief map from the blanked grid
'   4. Sets terrain representation to Color Only
'   5. Loads a custom color map from a CLR file
'   6. Sets the color scale to use logarithmic scaling
'   7. Saves the grid (.grd) and map (.srf) to the script directory
'
' Requirements:
'   - Golden Software Surfer 30
'   - A comma-delimited .dat data file with headers and X, Y, Z columns
'   - A BLN boundary file defining the NoData region
'   - A Surfer CLR color map file
'
' Usage:
'   1. Open Scripter (included with Surfer)
'   2. Open this script (File > Open)
'   3. Edit the CONFIGURATION section below to set your file paths and
'      grid cell spacing
'   4. Run the script (Script > Run)
' =============================================================================

Sub Main

    ' =========================================================================
    ' CONFIGURATION - Edit these values before running the script
    ' =========================================================================

    ' --- Input File Paths ---
    Dim DataFile As String
    Dim BlnFile As String
    Dim ColorMapFile As String

    DataFile     = "C:\Data\input_data.dat"         ' Comma-delimited .dat file (X, Y, Z with headers)
    BlnFile      = "C:\Data\boundary.bln"           ' BLN boundary file for blanking
    ColorMapFile = "C:\Data\colormap.clr"            ' Surfer CLR color map file

    ' --- Data Column Assignments (1-based column index) ---
    Dim xCol As Long
    Dim yCol As Long
    Dim zCol As Long

    xCol = 1    ' Column containing X coordinates
    yCol = 2    ' Column containing Y coordinates
    zCol = 3    ' Column containing Z values

    ' --- Grid Cell Spacing ---
    Dim CellSpacing As Double

    CellSpacing = 100.0     ' Grid cell size (used for both X and Y directions)

    ' =========================================================================
    ' OUTPUT FILE PATHS (saved to the script's working directory)
    ' =========================================================================

    Dim OutDir As String
    Dim OutGridFile As String
    Dim OutMapFile As String

    OutDir       = CurDir() & "\"
    OutGridFile  = OutDir & "output_grid.grd"
    OutMapFile   = OutDir & "output_map.srf"

    ' =========================================================================
    ' INITIALIZE SURFER
    ' =========================================================================

    Dim SurferApp As Object
    Set SurferApp = CreateObject("Surfer.Application")
    SurferApp.Visible = True

    Debug.Print "Surfer application started."
    Debug.Print "Output directory: " & OutDir

    ' =========================================================================
    ' STEP 1: CREATE THE GRID
    '   Method:      Triangulation with Linear Interpolation
    '   Z-Transform: Log, save as Linear
    '   Cell Size:   Defined by CellSpacing above
    ' =========================================================================

    Debug.Print "Gridding data file: " & DataFile
    Debug.Print "  Algorithm:  Triangulation (Linear Interpolation)"
    Debug.Print "  Z-Transform: Log, save as Linear"
    Debug.Print "  Cell spacing: " & CellSpacing

    SurferApp.GridData6 _
        DataFile:=DataFile, _
        xCol:=xCol, _
        yCol:=yCol, _
        zCol:=zCol, _
        Algorithm:=srfTriangulation, _
        xSize:=CellSpacing, _
        ySize:=CellSpacing, _
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
    '   - Scaling:                Logarithmic (levels at 1, 10, 100, etc.)
    ' =========================================================================

    ' Access the Color Relief layer from the map frame overlays
    Dim ColorReliefLayer As Object
    Set ColorReliefLayer = MapFrame.Overlays(1)

    ' Set terrain representation to Color Only (no illumination effects)
    ColorReliefLayer.ReliefMethod = srfReliefColorOnly
    Debug.Print "  Terrain representation set to Color Only."

    ' Show the color scale bar on the map
    ColorReliefLayer.ShowColorScale = True

    ' Load the custom color map from the CLR file
    ColorReliefLayer.ColorMap.LoadFile(ColorMapFile)
    Debug.Print "  Color map loaded: " & ColorMapFile

    ' Set the color map to use logarithmic scaling so that color scale
    ' levels are logarithmically distributed (e.g. 1, 10, 100, 1000)
    ColorReliefLayer.ColorMap.ScalingMethod = srfColorScalingLog
    Debug.Print "  Logarithmic color scaling applied."

    Debug.Print "Color relief map configured."

    ' =========================================================================
    ' STEP 5: SAVE THE MAP DOCUMENT
    ' =========================================================================

    PlotDoc.SaveAs(OutMapFile)
    Debug.Print "Map saved: " & OutMapFile

    ' =========================================================================
    ' DONE
    ' =========================================================================

    Debug.Print "Script completed successfully."

    MsgBox "Script completed successfully!" & vbCrLf & vbCrLf & _
           "Grid file: " & OutGridFile & vbCrLf & _
           "Map file:  " & OutMapFile, _
           vbInformation, "GridAndMap"

End Sub
