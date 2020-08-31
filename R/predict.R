#' @title Predict using retrofit
#' @description Given a set of predictions and truth for two
#' models, calibrate the result of the second to yield the
#' same expected value as the result of the first.
#'
#' @param retrofit An object of class `retrofit` obtained using the `retrofit()` function
#' @param new_x A numeric vector containing new scores to retrofit using the above object
#'
#' @export
predict.retrofit = function(retrofit, new_x) {
  new_x_cal = cal_isotonic(new_x, retrofit$gpava$new)
  uncal_isotonic(new_x_cal, retrofit$gpava$old)
}
