context('Model class')

test_that('model object shoud be created', {
  model <- new_hawkes(par = c(K = 1, theta = 0.3), model_type = 'EXP')
  expect_s3_class(model, c('hawkes_EXP'))
  expect_s3_class(model, c('hawkes'))
})

test_that('model object shoud not be created due to wrong parameters', {
  expect_warning(new_hawkes(par = c(1, 0.3), model_type = 'EXP'))
  expect_error(new_hawkes(par = c(K = 1, theta = 0.3, N = 100), model_type = 'EXP'))
})

test_that('branching factors and viral scores are correctly computed', {
  model1 <- new_hawkes(par = c(K = 0.1, theta = 0.3), model_type = 'EXP')
  model2 <- new_hawkes(par = c(K = 0.1, beta = 1, theta = 0.3), model_type = 'mEXP')
  model3 <- new_hawkes(par = c(K = 0.1, c = 0.2, theta = 0.3), model_type = 'PL')
  model4 <- new_hawkes(par = c(K = 0.1, beta = 1, c = 0.2, theta = 0.3), model_type = 'mPL')

  model5 <- new_hawkes(par = c(K = 0.1, theta = 0.3, N = 100), model_type = 'EXPN')
  model6 <- new_hawkes(par = c(K = 0.1, beta = 1, theta = 0.3, N = 100), model_type = 'mEXPN')
  model7 <- new_hawkes(par = c(K = 0.1, c = 0.2, theta = 0.3, N = 100), model_type = 'PLN')
  model8 <- new_hawkes(par = c(K = 0.1, beta = 1, c = 0.2, theta = 0.3, N = 100), model_type = 'mPLN')

  model9 <- new_hawkes(par = c(K = 0.5, beta = 0.4, theta = 0.3), model_type = 'mEXP')
  model10 <- new_hawkes(par = c(K = 0.5, theta = 0.3), model_type = 'EXP')
  expect_equal(get_branching_factor(model1), 0.1, tolerance = 1e-6)
  expect_equal(get_viral_score(model1), 0.1 / (1 - 0.1), tolerance = 1e-6)
  expect_equal(get_branching_factor(model2), 6.35, tolerance = 1e-6)
  expect_equal(get_viral_score(model2, m_0 = 2), Inf, tolerance = 1e-6)
  expect_equal(get_viral_score(model2, m_0 = 0), 0, tolerance = 1e-6)
  expect_equal(get_branching_factor(model3), 0.5402189, tolerance = 1e-6)
  expect_equal(get_viral_score(model3), 0.5402189/(1 - 0.5402189), tolerance = 1e-6)
  expect_equal(get_branching_factor(model4), 34.3039, tolerance = 1e-6)

  expect_equal(get_branching_factor(model5), 0.1, tolerance = 1e-6)
  expect_equal(get_branching_factor(model6), 6.35, tolerance = 1e-6)
  expect_equal(get_branching_factor(model7), 0.5402189, tolerance = 1e-6)
  expect_equal(get_branching_factor(model8), 34.3039, tolerance = 1e-6)

  expect_equal(get_viral_score(model9, m_0 = 100), 100^0.4*get_branching_factor(model10)/(1-get_branching_factor(model9)), tolerance = 1e-6)
})

test_that('fianl popularities are correctly computed', {
  data <- list(data.frame(time = seq(0, 5), magnitude = rep(1, 6)),
               data.frame(time = seq(0, 5), magnitude = rep(1, 6)))
  model <- new_hawkes(model_type = 'EXP', par = c(K=0.8, theta = 1), data = data, observation_time = 10)
  expect_equal(predict_final_popularity(model), c(12.08506), tolerance = 1e-6)

  model <- new_hawkes(model_type = 'mEXP', par = c(K=0.8, beta = 0.1, theta = 1), data = data, observation_time = 10)
  expect_equal(predict_final_popularity(model), c(12.151), tolerance = 1e-6)

  model <- new_hawkes(model_type = 'mEXP', par = c(K=1, beta = 0.1, theta = 1), data = data, observation_time = 10)
  expect_warning(expect_equal(predict_final_popularity(model), c(Inf), tolerance = 1e-6))

  model <- new_hawkes(model_type = 'PL', par = c(K=0.8, theta = 1, c = 1), data = data, observation_time = 10)
  expect_equal(predict_final_popularity(model), c(8.9461760*2), tolerance = 1e-6)

  model <- new_hawkes(model_type = 'mPL', par = c(K=0.8, beta = 0.1, theta = 1, c = 1), data = data, observation_time = 10)
  expect_equal(predict_final_popularity(model), c(11.2300334*2), tolerance = 1e-6)

  model <- new_hawkes(model_type = 'EXPN', par = c(K=0.8, theta = 1, N = 100), data = data, observation_time = 10)
  expect_error(predict_final_popularity(model))
})

test_that('SEISMIC prediction works', {
  library(seismic)
  data(tweet)
  pred.time <- 1000
  infectiousness <- get.infectiousness(tweet[, 1], tweet[, 2], pred.time)
  pred <- pred.cascade(pred.time, infectiousness$infectiousness, tweet[, 1], tweet[, 2], n.star = 100)[1,1] + 1
  names(tweet) <- c('time', 'magnitude')
  fitted <- fit_series(data = tweet, model_type = 'SEISMIC', observation_time = pred.time)
  expect_lt(abs(pred - predict_final_popularity(fitted)), 1e-7)
})
