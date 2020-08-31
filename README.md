# retrofit

## Motivation

It is sometimes useful when replacing one model (the "old model") with another (the "new model") to retrofit the predictions of the old model to the new in such a way as to ensure that a given model score is expected to yield the same outcome (truth) from both models. This package allows you to take a set of predictions and truths from two models and retrofit the predictions of one model to match the predictions of the other, such that both predictions of a given number would be expected to yield the same (truth) result.

## Installation

```
devtools::install_github('Prometheus77/retrofit')
```

## Retrofitting example

```
library(retrofit)
rf = retrofit(old_pred = old$pred, old_truth = old$truth, new_pred = new$pred, new_truth = new$truth)
```

The resulting object `rf` now contains instructions to take any number or vector representing a prediction from the new model, and represent it on the same scale of the old model, with the same expected result (truth).

## Prediction example

```
retroscores = predict(rf, new$pred)
```

The resulting object `retroscores` contains the predictions of `new$pred` calibrated to the same scale and expected result of `old$pred`.

## Note

Currently retrofit uses the `isotone` package to obtain a calibrated prediction from both models before matching them. It implements a smoothed version of the `gpava()` function which converts the steps into a smoothly sloped curve. Future enhancements planned include adding support for Platt scaling and scaling based off the cumulative distribution of the truth variable.

If you have any questions or comments, please submit an issue.
