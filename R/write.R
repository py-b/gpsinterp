# CALCUL ANGLE vers SUIVANT -----------------------------------------------

add_direction <- function() {

  .exif$base <-
    .exif$base %>%
    dplyr::mutate(ANGLE = angles_next(LON, LAT)) %>%
    tidyr::fill(ANGLE)

}


# EXPORT pour EXIFTOOL ----------------------------------------------------

#' Writing exif tags with exiftool
#'
#' Create a batch file that contains \href{https://sno.phy.queensu.ca/~phil/exiftool/}{exiftool}
#' commands to write computed longitudes, latitudes (and directions) in image
#' files. Execute that file immediatly (or not if specified).
#'
#' In order to execute the batch file created by that function, \strong{exiftool}
#' must be installed.
#'
#' Files are not overwritten : a copy of the images including new exif tags
#' are written in the \code{output} directory.
#'
#' @param file the name of the batch file (default : "write_exiftool.bat")
#' @param direction should direction to next photo be calculated and included
#'   in the file?
#' @param run launch the batch file immediatly if \code{TRUE} (the default).
#' @inheritParams interp_josm
#' @export

write_exiftool <- function(path = ".",
                           file = "write_exiftool.bat",
                           direction = TRUE,
                           run = TRUE) {

  init_check()

  if (direction) add_direction()

  cmds <-
    with(.exif$base,
      paste0(
        "exiftool ",
        "-GPSLatitude=", LAT, " ",
        "-GPSLongitude=" , LON, " ",
        if (direction) paste0("-GPSImgDirection=", ANGLE, " "),
        "-o \"output\" \"input/photos/", PHOTO, "\""
      )
    )

  bat <- file.path(path, file)
  writeLines(
    c(paste("cd", path %>% normalizePath(winslash = "/")), cmds),
    bat
  )
  if (run) system(bat)

}


# EXPORT CSV --------------------------------------------------------------

#' Write coordinates and direction in a csv file.
#'
#' Write computed longitudes, latitudes (and directions) in a csv file.
#' Images are not modified.
#'
#' @inheritParams write_exiftool
#' @param file the name of the csv file (default : "interp_gps.csv")
#' @param ... other arguments passed to \code{write.csv}
#' @export
#' @importFrom utils write.csv

write_coord_csv <- function(path = ".",
                            file = "interp_gps.csv",
                            direction = TRUE,
                            ...) {

  init_check()

  if (direction) add_direction()

  write.csv(
    subset(.exif$base, select = -ACTION),
    file = file.path(path, file),
    row.names = FALSE,
    ...
  )

}
