
<!-- README.md is generated from README.Rmd. Please edit that file -->
gpsinterp
=========

gpsinterp is an R package designed to interpolate gps-exif-tags (longitude, latitude and directon), given a certain number of known points. The position of those exact points will be entered using JOSM (Java editor for OpenstreetMap).

It may be particularly useful for geolocating a sequence of photos (i.e. taken with small amount of time between each photo), typically a [mapillary](http://mapillary.com/app) sequence.

Installation
------------

You can install **gpsinterp** from github with :

``` r
# install.packages("devtools")
devtools::install_github("the-knife/gpsinterp")
```

Note : *on Windows*, you need to have [RTools](https://cran.r-project.org/bin/windows/Rtools) to make devtools working.

Other components to install
---------------------------

### *JOSM* (mandatory)

[JOSM](http://josm.openstreetmap.de) is an offline editor for OpenStreetMap. For this package, it is not used for uploading information to osm, but for manually locating exact points.

JOSM can display various aerial imagery and detect which points where moved by the user between two interpolations. *gpsinterp* will load local files in JOSM, therefore you have to enable the following options (in preferences menu) :

-   "Enable remote control"
-   "Open local files"

### *exiftool* (optional)

[exiftool](http://sno.phy.queensu.ca/~phil/exiftool/) is a command line for writing exif tags to photos. It only will be needed if you want to write computed information into image files (other export type are possible).

On Linux, you can install exiftool with : `sudo apt install libimage-exiftool-perl`

Typical iterative process for interpolation
-------------------------------------------

``` r
## initialize data
## create a new JOSM layer with at least two nodes and tagged with name="---.JPG"
## save as "approx.osm" in the input directory
## compute positions
## update in JOSM
```

Exporting results
-----------------

### *csv*

You can save latitude, longitude (and optionally direction) in a csv file.

Once the interpolation seems good enough, Use the `write_coord_csv` function.

### *write exif in images*

If exiftool is installed on your system, you can write latitude, longitude (and optionally direction) into the images.

Once the interpolation seems good enough, use the `write_exiftool` function.
