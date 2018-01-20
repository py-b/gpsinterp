# INITIALIZE --------------------------------------------------------------

#' Initialize data before interpolation
#'
#' List photos in input directory and creates an environment for storing
#' data during interpolation iterative process. This is a mandatory prerequisite
#' for interpolating positions.
#'
#' Search for image files in \code{input/photo} and stores them in a data.frame.
#'
#' As the process is iterative (a succession of manual modifications in
#' JOSM and interpolations in R), it is necessary to keep track of
#' intermediate results. Therefore, a temporary environment (named .exif)
#' is created.
#'
#' Once interpolation is over, it is possible to delete that environment
#' with \code{\link{interp_cleanup}}.
#'
#' @param path (optional) path where input and output are located.
#'   This is not necessary if the working directory is already set to
#'   that location.
#' @return Nothing. Only \code{.exif$base} is created.
#' @examples interp_init()
#' @export

interp_init <- function(path = ".") {

  # list images in "input"
  res <-
    tibble::tibble(
      PHOTO = list.files(
        file.path(path, "input", "photos"),
        pattern = "\\.JPG$" #jpg, jpeg
      )
    )

  if (nrow(res) == 0) {
    warning("no data in input/photos.")
    return(NULL)
  }

  message(
    paste0(
      nrow(res), " images found in \"",
      normalizePath(path, winslash = "/"), "/input/photos\"\n",
      " In JOSM, create a new layer and add (at least) two nodes :\n",
      " the first image (", res$PHOTO[1], ") and the last (",
      res$PHOTO[nrow(res)], ")\n",
      " with above filenames in the \"name\" attribute.\n",
      " Save as \"input/approx.osm\".\n",
      " Then run \"interp_josm()\" as many times as needed."
    )
  )

  # stores images list in newly created temporary environment
  assign(".exif", new.env(), envir = .GlobalEnv)
  .exif$images <- res

  invisible()

}

init_check <- function(path = ".") {
  msg <- "first initialize with interp_init()."
  if (!exists(".exif", envir = .GlobalEnv)) stop(msg)
  if (!exists("images", envir = .exif)) stop(msg)
}


# INTERMEDIATE FUNCTIONS --------------------------------------------------

read_exact <- function(path = ".") {

  init_check()

  res <-
    read_positions(file.path(path, "input", "approx.osm")) %>%
    dplyr::filter(EXACT)

  .exif$approx <- res

}

interp_missing_coord <- function() {

  init_check()

  # reads new exact positions and interpolates NAs
  .exif$base <-
    dplyr::left_join(.exif$images, .exif$approx, by = "PHOTO") %>%
    tidyr::replace_na(list(EXACT = FALSE)) %>%
    dplyr::mutate_at(
      c("LON", "LAT"),
      fill_lin_full
    )

}

#' @importFrom utils download.file
update_osm <- function(path = ".") {

  init_check()

  # update "approx.osm"
  approx_file <- file.path(path, "input", "approx.osm")
  .exif$base %>% df_to_osm(approx_file)

  # opens "approx.osm" in JOSM
  file_josm <- approx_file %>% normalizePath(winslash = "/")
  url_josm <- paste0("http://localhost:8111/open_file?filename=", file_josm)
  if (Sys.info()[["sysname"]] != "Windows") url_josm <- URLencode(url_josm)
  tryCatch(
    download.file(
      url_josm,
      destfile = "ok.txt",
      quiet = TRUE
    ),
    error = function(e) message("Make sure JOSM is opened and remote control enabled.")
  )
  unlink("ok.txt")

  invisible()

}


# READ & UPDATE -----------------------------------------------------------

#' Interpolation and JOSM update
#'
#' Reads exact positions, linearly interpolates non-exact positions,
#' updates osm file and displays it in JOSM.
#'
#' Reads \code{approx.osm} and detects exact locations (moved manually in JOSM).
#' Then interpotales linearly other points. Updates \code{approx.osm} and
#' opens it in JOSM (http://localhost:8111 is used to open the file in JOSM,
#' which must be opened beforehand).
#'
#' @inheritParams interp_init
#' @return Nothing. Only \code{.exif$base} and \code{approx.osm} are updated.
#' @examples # interp_josm()
#' @export

interp_josm <- function(path = ".") {
  read_exact(path)
  interp_missing_coord()
  update_osm(path)
}


# CLEAN UP ----------------------------------------------------------------

#' Clean up after interpolation
#'
#' Removes temporary environment (.exif) containing data that was used
#' during interpolation.
#'
#' As closing R session will also delete that environment,
#' this is not mandatory.
#'
#' @export
#'
interp_cleanup <- function() {
  if (exists(".exif", envir = .GlobalEnv)) rm(.exif, envir = .GlobalEnv)
}
