#' @export
list_images <- function(path = ".") {

  # list images in "input"
  res <-
    tibble::tibble(
      PHOTO = list.files(
        file.path(path, "input", "photos"),
        pattern = "\\.JPG$" #jpg, jpeg
      )
    )

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

  # stores images list in temporary environment
  # tmp_env <- new.env()
  # assign("images", res, envir = tmp_env)

  res

}

#' @export
read_exact <- function(path = ".") {

  read_positions(
    file.path(path, "input", "approx.osm")
  ) %>%
  dplyr::filter(EXACT)

}

#' @export
update_osm <- function(path = ".") {

  # reads new exact positions and interpolates NAs
  base <-
    dplyr::left_join(images, approx, by = "PHOTO") %>%
    tidyr::replace_na(list(EXACT = FALSE)) %>%
    dplyr::mutate_at(
      c("LON", "LAT"),
      fill_lin_full
    )

  # update "approx.osm"
  approx_file <- file.path(path, "input", "approx.osm")
  base %>% df_to_osm(approx_file)

  # opens "approx.osm" in JOSM
  file_josm <- approx_file %>% normalizePath(winslash = "/")
  url_josm <- paste0("http://localhost:8111/open_file?filename=", file_josm)
  download.file(
    url_josm,
    destfile = "ok.txt",
    quiet = TRUE
  )
  unlink("ok.txt")

  base

}


# images <- list_images("..")

# approx <- read_exact("..")
# base <- update_osm("..")

