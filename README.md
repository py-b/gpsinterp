
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gpsinterp

gpsinterp is an R package designed to interpolate gps-exif-tags
(longitude, latitude and directon), given a certain number of known
points. The position of those exact points will be entered using JOSM
(Java editor for OpenstreetMap).

It may be particularly useful for geolocating a sequence of photos
(i.e. taken with small amount of time between each photo), typically a
[mapillary](http://mapillary.com/app) sequence.

## Installation

You can install **gpsinterp** from github with :

``` r
# install.packages("devtools")
devtools::install_github("py-b/gpsinterp")
```

Note : *on Windows*, you need to have
[RTools](https://cran.r-project.org/bin/windows/Rtools) to make devtools
working.

## Other components to install

### *JOSM* (required)

[JOSM](http://josm.openstreetmap.de) is an offline editor for
OpenStreetMap. For this package, it is not used for uploading
information to osm, but for locating exact points manually.

JOSM can display various aerial imageries and detect which points where
moved by the user between two interpolations. *gpsinterp* will load
local files in JOSM, therefore you have to enable the following options
(in preferences menu) :

-   “Enable remote control”
-   “Open local files”

### *exiftool* (optional)

[exiftool](http://sno.phy.queensu.ca/~phil/exiftool/) is a command line
software for writing exif tags to photos. It only will be needed if you
want to write computed information into image files (other export type
are possible).

On Linux, you can install exiftool with :
`sudo apt install libimage-exiftool-perl`

## Exporting results

### *csv file*

You can save latitude, longitude (and optionally direction) in a csv
file. Once the interpolation seems good enough, use the
`write_coord_csv` function.

### *write exif in images*

If exiftool is installed on your system, you can write latitude,
longitude (and optionally direction) into the images. Once the
interpolation seems good enough, use the `write_exiftool` function.

## Local directory architecture

You need to create two directories **input** and **output** on your
machine.

-   Put the orignal images in **input/photos**.

-   Geolocated photos will be written in **output**.

## Typical iterative process for interpolation

``` r
library(gpsinterp)

setwd("path/where/input/and/output/are")

# Initialize data
interp_init()

# Open JOSM.
# Create a new JOSM layer with at least two nodes and tagged with
# name="photo_xxx.JPG" (use the real names of the files)

# Save as "approx.osm" in the input directory

# Compute positions of missing points
interp_josm()

# 1/ Update some points in JOSM (don't forget to save)

# 2/ Compute new positions
interp_josm()
# (exact points will automatically be tagged as tourism=viepoint
# to distinguish them from interpolated ones)

# ....... Repeat 1/ and 2/ as many times as needed .......

# Save
write_exiftool()
  # or (if you don't have exiftool)
  write_coord_csv(file = "photos_coord.csv")

# Cleanup (optional, see help page)
interp_cleanup()
```
