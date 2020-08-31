#' @title Retrofit
#' @description Given a set of predictions and truth for two
#' models, calibrate the result of the second to yield the
#' same expected value as the result of the first.
#'
#' @param old_pred Vector of predictions of the old model
#' @param old_truth Vector of true results of the old model
#' @param new_pred Vector of predictions of the new model (the one to be calibrated)
#' @param new_truth Vector of true results of the new model
#' @param method Method used to perform the calibration
#'
#' @return An object of class `retrofit` that can be used to
#' convert the new model score to match the old model score.
#'
#' @export
retrofit = function(old_pred, old_truth, new_pred, new_truth, method = 'gpava') {

  checkmate::assert_numeric(old_pred)
  checkmate::assert_numeric(old_truth)
  checkmate::assert_numeric(new_pred)
  checkmate::assert_numeric(new_truth)
  checkmate::assert_subset(method, choices = c('gpava')) # TODO: add support for Platt, cumdist

  old = data.frame(pred = old_pred, truth = old_truth)
  old = dplyr::arrange(old, pred)

  new = data.frame(pred = new_pred, truth = new_truth)
  new = dplyr::arrange(new, new_pred)

  old_gpava = gpava(z = old$pred, y = old$truth)
  new_gpava = gpava(z = new$pred, y = new$truth)

  result = list(
    data = data.frame(old_pred, old_truth, new_pred, new_truth),
    gpava = list(old = old_gpava,
                 new = new_gpava),
    method = method
  )

  attr(result, "class") = 'retrofit'

  result
}

