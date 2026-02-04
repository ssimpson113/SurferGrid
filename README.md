# SurferGrid - Grid and Color Relief Map Script

A Surfer Scripter (BAS) script that grids a comma-delimited `.dat` data file and displays it as a color relief map with logarithmic color scaling.

## What the Script Does

1. **Grids** a comma-delimited `.dat` file using **Triangulation with Linear Interpolation**
2. Applies a **log Z-transform** during gridding and saves the output as **linear values** (ideal for data spanning several orders of magnitude)
3. **Blanks** grid nodes outside a BLN boundary polygon (assigns NoData)
4. Creates a **new plot** with a **Color Relief** map layer
5. Sets terrain representation to **Color Only** (no hill shading)
6. Loads colors from a **Surfer CLR color map file**
7. Applies **logarithmic scaling** to the color map (levels distributed at 1, 10, 100, etc.)
8. **Saves** both the grid (`.grd`) and map (`.srf`) to the script's working directory

## Requirements

- **Golden Software Surfer 30**
- **Scripter** (included with Surfer, located in the Surfer installation directory)

### Input Files

| File | Description |
|------|-------------|
| `.dat` data file | Comma-delimited text file with headers and X, Y, Z columns |
| `.bln` boundary file | Golden Software blanking file defining the NoData boundary |
| `.clr` color map file | Surfer color map file for the color relief display |

## Usage

1. Open **Scripter** (`Scripter.exe` in your Surfer installation folder, typically `C:\Program Files\Golden Software\Surfer`)
2. Open `GridAndMap.bas` (File > Open)
3. Edit the **CONFIGURATION** section at the top of the script:
   - Set the input file paths for your `.dat` file, `.bln` file, and `.clr` file
   - Set column assignments if your data columns differ from the defaults (X=1, Y=2, Z=3)
   - Set the grid cell spacing (`CellSpacing`)
4. Run the script (Script > Run)

Output files (`output_grid.grd` and `output_map.srf`) are saved to the same directory as the script.

## Configuration Reference

```vb
' Input file paths
DataFile     = "C:\Data\input_data.dat"
BlnFile      = "C:\Data\boundary.bln"
ColorMapFile = "C:\Data\colormap.clr"

' Data columns (1-based)
xCol = 1
yCol = 2
zCol = 3

' Grid cell spacing (used for both X and Y)
CellSpacing = 100.0
```

## Notes

- The **Z-transform** (log, save as linear) requires data with positive, non-zero Z values.
- The output grid is saved in **Surfer 7 (.grd)** format.
- The script blanks the grid in-place, overwriting the output grid file with the blanked version.
- Logarithmic color scaling pairs well with the log-save-as-linear Z-transform: the grid stores original linear values while the map displays the logarithmic distribution.
- Progress messages are printed to Scripter's output window via `Debug.Print`. A message box appears on completion with the output file paths.

## Surfer API Reference

- [GridData6 method](https://surferhelp.goldensoftware.com/auto_ah/link_application_GridData6.htm)
- [GridBlank method](https://surferhelp.goldensoftware.com/auto_ah/link_application_gridblank.htm)
- [ColorMap object](https://surferhelp.goldensoftware.com/autoobjects/link_colormap2.htm)
- [Color Relief Layer properties](https://surferhelp.goldensoftware.com/vec_shd_img/idd_imagemap.htm)
- [Surfer Automation examples](https://surferhelp.goldensoftware.com/auto_chp/automation_examples.htm)
