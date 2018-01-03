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
      " - First : ", res$PHOTO[1], "\n",
      " - Last  : ", res$PHOTO[nrow(res)], "\n",
      "Now, open JOSM. In a new layer, create at least two nodes :\n",
      "the first and last image filename (in \"name\" attribute).\n",
      "Save as \"input/approx.osm\"."
    )
  )

  # stores images list in newly created temporary environment
  assign(".exif", new.env(), envir = .GlobalEnv)
  .exif$images <- res

  invisible()

}

init_check <- function(path = ".") {
  msg <- "first initialize with init()."
  if (!exists(".exif", envir = .GlobalEnv)) stop(msg)
  if (!exists("images", envir = .exif)) stop(msg)
}

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

update_osm <- function(path = ".") {

  init_check()

  # update "approx.osm"
  approx_file <- file.path(path, "input", "approx.osm")
  .exif$base %>% df_to_osm(approx_file)

  # opens "approx.osm" in JOSM
  file_josm <- approx_file %>% normalizePath(winslash = "/")
  url_josm <- paste0("http://localhost:8111/open_file?filename=", file_josm)
  download.file(
    url_josm,
    destfile = "ok.txt",
    quiet = TRUE
  )
  unlink("ok.txt")

  invisible()

}

#' @export
interp_gps <- function(path = ".") {
  read_exact(path)
  interp_missing_coord()
  update_osm(path)
}

#' @export
interp_cleanup <- function() {
  if (exists(".exif", envir = .GlobalEnv)) rm(.exif, envir = .GlobalEnv)
}
