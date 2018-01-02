# INTERPOLATION NA --------------------------------------------------------

lin <- function(v1, v2, between) {
  if (between <= 0) return(c(v1, v2))
  larg <- (v2 - v1) / (between + 1)
  c(v1, v1 + (seq(between) * larg), v2)
}

fill_lin <- function(v) {
  if (is.na(v[1]) | is.na(v[length(v)])) message("!! pas de bornes")
  between <- sum(is.na(v))
  lin(v[1], v[length(v)], between)
}

fill_lin_full <- function(x) {
  .i <- which(!is.na(x))
  deb <- .i[-length(.i)]
  fin <- .i[-1]
  .i2 <- map2(
    deb, fin,
    function(a, b) fill_lin(x[a:b])[a-b-1]
  )
  c(unlist(.i2), last(x))
}


# ANGLE -------------------------------------------------------------------

angle_rad <- function(A , B, positive = TRUE) {
  # direction en radians entre deux points A et B d'un repere en 2 dim.
  # positive pour un resultat entre 0 et 2pi, sinon entre -pi et pi
  res <- atan2(B[2] - A[2], B[1] - A[1])
  if (positive) res <- res %% (2 * pi)
  res
}

angle_exif <- function(angle_rad) {
  # angle en degres avec 0 au Nord et sens horaire
  angle_deg <- angle_rad * 180 / pi
  round((90 - angle_deg) %% 360)
}

angles_next <- function(serie_x, serie_y) {
  p1 <- map2(serie_x, serie_y, c)
  p2 <- map2(lead(serie_x), lead(serie_y), c)
  angles <- map2_dbl(p1, p2, angle_rad)
  angle_exif(angles)
}
