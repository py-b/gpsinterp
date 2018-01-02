# LECTURE IMAGES ----------------------------------------------------------

images <- tibble::tibble(
  PHOTO = list.files("input/photos", pattern = "\\.JPG")
)
# cat("First and last :")
# images$PHOTO[c(1, nrow(images))] %>% cat(sep = "\n")


# INITIALISATION POSITIONS ------------------------------------------------

# créer deux sous-dossiers input et output
# dans inout, créer un repertoire photos, placer les photos à géoloc
# A l'aide de JOSM créer un fichier "approx.osm" avec (au minimum) les
# positions de la première et de la dernière photo
# (renseigner les noms des fichiers dans le tag "name")
# placer ce fichier dans "/input"
# Répéter ensuite les étapes 1 à 5 jusqu'à une approximation satisfaisante


# 1 - LECTURE POSITIONS EXACTES (osm) -------------------------------------

#' @importFrom dplyr "%>%"
#' @importFrom dplyr filter

read_exact <- function(path = ".") {
  read_positions(file.path(path, "input", "approx.osm")) %>%
  filter(EXACT)
}

# approx <- read_exact()

# 2 - FUSION --------------------------------------------------------------

base <-
  left_join(images, approx, by = "PHOTO") %>%
  replace_na(list(EXACT = FALSE))


# 3 - INTERPOLATION NA ----------------------------------------------------

base <-
  base %>%
  mutate_at(
    c("LON", "LAT"),
    fill_lin_full
  )


# 4 - CONVERSION OSM ------------------------------------------------------

base %>% df_to_osm("input/approx.osm")
# check id ?


# 5 - OUVRE DANS JOSM -----------------------------------------------------

file_josm <- file.path(getwd(), "input", "approx.osm")
url_josm <- paste0("http://localhost:8111/open_file?filename=", file_josm)

download.file(
  url_josm,
  destfile = "ok.txt",
  quiet = TRUE
)
unlink("ok.txt")

# dans JOSM, placer les points connus au bon endroit sur la carte
# enregistrer le document
# retourner à l'étape 1


# ECRITURE BATCH exiftool -------------------------------------------------

direction <- TRUE

if (direction) {
  base <-
    base %>%
    mutate(ANGLE = angles_next(LON, LAT)) %>%
    fill(ANGLE)
}

# writeLines
sink("write_xy.bat")
glue_data(
  base,
  paste(
    "exiftool",
    "-GPSLatitude={LAT}",
    "-GPSLongitude={LON}",
    if (direction) "-GPSImgDirection={ANGLE}",
    "-o \"output\" \"input/photos/{PHOTO}\""
  )
)
sink()

# system("write_xy.bat")
