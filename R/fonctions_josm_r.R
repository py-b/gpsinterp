# OSM -> R ----------------------------------------------------------------

#' @importFrom dplyr "%>%"

extract_node_info <- function(xml_node) {

  tags <-
    xml_node %>%
    xml_find_all(".//tag") %>%
    xml_attrs() %>%
    do.call(rbind, .) %>%
    as.tibble() %>%
    deframe()

  list(
    PHOTO = tags[["name"]],
    LAT = xml_attr(xml_node, "lat"),
    LON = xml_attr(xml_node, "lon"),
    ACTION = xml_attr(xml_node, "action"),
    EXACT = tags["tourism"] == "viewpoint"
  )

}

read_positions <- function(osm_file) {

  read_xml(osm_file) %>%
  xml_find_all("//node") %>%
  map(extract_node_info) %>%
  transpose() %>%
  map(unlist) %>%
  as.tibble() %>%
  mutate_at(c("LAT", "LON"), as.numeric) %>%
  replace_na(list(EXACT = FALSE, ACTION = "")) %>%
  mutate(
    EXACT = ifelse(ACTION == "modify", TRUE, EXACT)
  )

}


# R -> OSM ----------------------------------------------------------------

line_to_node <- function(id, name, lat, lon, exact) {

  paste(
    sprintf(
      "<node id='-%d' lat='%.11f' lon='%.11f'>\n",
      id, lat, lon
    ),
    sprintf("  <tag k='name' v='%s' />\n", name),
    if (exact) "  <tag k='tourism' v='viewpoint' />\n",
    "</node>"
  )

}

df_to_osm <- function(df, file) {

  line_to_nodev <- Vectorize(line_to_node)

  xml_inner <-
    df %>%
    transmute(
      TXT =
        line_to_nodev(
          id = seq(nrow(.)),
          lat = LAT,
          lon = LON,
          name = PHOTO,
          exact = EXACT
        )
    )

  sprintf(
    "<osm version='0.6' upload='false'>%s</osm>",
    xml_inner$TXT %>% paste(collapse = "")
  ) %>%
  read_xml() %>%
  write_xml(file)

}
