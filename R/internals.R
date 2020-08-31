interpolate = function(x1, x2, y1, y2, x_new) {
  if(x1 != x2) {
    m = (y2 - y1) / (x2 - x1)
    b = y1 - m * x1
    y_new = m * x_new + b
    y_new
  } else {
    (y1 + y2) / 2
  }
}

sticky_match = function(x, index, direction) {
  if(direction == 'next') {
    min(index[index >= x])
  } else if(direction == 'prev') {
    max(index[index <= x])
  } else {
    stop("direction must be one of 'prev' or 'next'")
  }
}

smooth_isotonic = function(gpava) {
  df = data.frame(x = gpava$x,
                  z = gpava$z)

  cut_points = df %>% mutate(rn = 1:length(x),
                             cut_point = ifelse(is.na(lag(x, 1)), TRUE, x != lag(x, 1))) %>%
    filter(cut_point == TRUE) %>%
    pull(rn)

  cut_values = df$x[cut_points]
  midpoints = c(head(cut_values, 1), (cut_values + lag(cut_values)) / 2, tail(cut_values, 1))
  midpoints = midpoints[!is.na(midpoints)]
  cut_points = c(cut_points, length(df$x))

  y = rep(0, length(cut_points))

  for(i in 1:length(df$x)) {
    if(i == 1) {
      y[i] = head(midpoints, 1)
    } else if(i == length(df$x)) {
      y[i] = tail(midpoints, 1)
    } else {
      prev_cutpoint = sticky_match(i, cut_points, 'prev')
      next_cutpoint = sticky_match(i, cut_points, 'next')
      prev_midpoint = midpoints[match(prev_cutpoint, cut_points)]
      next_midpoint = midpoints[match(next_cutpoint, cut_points)]
      cut_points[match(prev_midpoint, midpoints)]

      if(prev_cutpoint == next_cutpoint) {
        y[i] = prev_midpoint
      } else {
        y[i] = interpolate(x1 = prev_cutpoint, x2 = next_cutpoint,
                           y1 = prev_midpoint, y2 = next_midpoint,
                           x_new = i)
      }
    }
  }
  y
}

# given an uncalibrated prediction and a gpava regression object,
# return the calibrated prediction

cal_isotonic = function(x, gpava) {

  df = data.frame(
    cal = smooth_isotonic(gpava),
    uncal = gpava$z
  )

  y = rep(0, length(x))

  for(i in 1:length(y)) {
    prev_pred = sticky_match(x[i], df$uncal, 'prev')
    next_pred = sticky_match(x[i], df$uncal, 'next')
    prev_cal = df$cal[which(df$uncal == prev_pred)]
    next_cal = df$cal[which(df$uncal == next_pred)]

    y[i] = interpolate(prev_pred, next_pred, prev_cal, next_cal, x[i])
  }

  y
}

# given an calibrated prediction and a gpava regression object,
# return the uncalibrated prediction

uncal_isotonic = function(x, gpava) {

  df = data.frame(
    cal = smooth_isotonic(gpava),
    uncal = gpava$z
  )

  y = rep(0, length(x))

  for(i in 1:length(y)) {
    prev_cal = sticky_match(x[i], df$cal, 'prev')
    next_cal = sticky_match(x[i], df$cal, 'next')
    prev_pred = df$uncal[which(df$cal == prev_cal)]
    next_pred = df$uncal[which(df$cal == next_cal)]

    y[i] = interpolate(prev_cal, next_cal, prev_pred, next_pred, x[i])
  }

  y
}
