# library(ggplot2)
# library(testthat)
# library(dplyr)
# library(purrr)

# Tests -------------------------------------------------------------------

# test_that("angles on trigo circle", {
  # expect_equal(angle_rad(c(0, 0), c(1, 0)),   0 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(1, 1)),   1 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(0, 1)),   2 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(-1, 1)),  3 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(-1, 0)),  4 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(-1, -1)), 5 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(0, -1)),  6 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(1, -1)),  7 / 4 * pi)
# })

# test_that("negative angles", {
  # expect_equal(angle_rad(c(0, 0), c(-1, -1), FALSE), - 3 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(0, -1), FALSE),  - 2 / 4 * pi)
  # expect_equal(angle_rad(c(0, 0), c(1, -1), FALSE),  - 1 / 4 * pi)
# })

# test_that("angle handles missing", {
  # expect_equal(angle_rad(c(0, 0), c(1, NA)), NA_integer_)
  # expect_equal(angle_rad(c(0, 0), c(NA, 0)), NA_integer_)
  # expect_equal(angle_rad(c(NA, 0), c(10, 0)), NA_integer_)
  # expect_equal(angle_rad(c(1, NA), c(10, 0)), NA_integer_)
# })


# Donnees -----------------------------------------------------------------

# ggplot(df, aes(x, y, angle = angle)) +
  # geom_point() + 
  # geom_spoke(
    # radius = pas * 3 / 4,
    # arrow = arrow(length = unit(0.2, "cm")),
    # na.rm = TRUE
  # ) +
  # geom_text(aes(label = angle_exif), nudge_y = .04) +
  # coord_equal()
