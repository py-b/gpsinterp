# CALCUL ANGLE vers SUIVANT -----------------------------------------------

add_direction <- function() {

  .exif$base <-
    .exif$base %>%
    dplyr::mutate(ANGLE = angles_next(LON, LAT)) %>%
    tidyr::fill(ANGLE)

}


# EXPORT pour EXIFTOOL ----------------------------------------------------

#' @export
write_exiftool_bat <- function(path = ".",
                               file = "write_exiftool.bat",
                               direction = TRUE) {

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

  writeLines(cmds, file.path(path, file))

}


# EXPORT CSV --------------------------------------------------------------

#' @export
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
