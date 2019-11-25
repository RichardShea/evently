evently: simulation, fitting of Hawkes processes
================

## Introduction

This package is designed for simulating and fitting the Hawkes processes
and the HawkesN processes with several options of kernel functions.
Currently, it assumes univariate processes without background event
rates. Prior knowledge about the models is assumed in the following
tutorial and please refer to \[1\] and \[2\] for details about the
models.

``` r
library(evently)
```

## Installation and dependencies

Several dependencies are required for running this package:

  - **poweRlaw**: r package, will be installed while installing the
    evently package
  - **AMPL**: download the demo version from
    <https://ampl.com/try-ampl/download-a-free-demo/>
  - **Ipopt**: compile from the source code here
    <https://www.coin-or.org/Ipopt/documentation/> so that the linear
    solver ma57 will be available.

Install the package by executing

``` r
if (!require('devtools')) install.packages('devtools')
devtools::install_github('qykong/evently')
```

## Available models

TODO: show a table of models here with equations?

## Simulating cascades

Let’s first simulate some event cascades.

``` r
set.seed(2)
sim_no <- 100
model <- generate_hawkes_event_series(par = c(K = 0.9, theta = 1), model_type = 'EXP', M = generate_user_influence(1), Tmax = 5, sim_no = sim_no)

head(model$data[[1]])
```

    ##   magnitude      time
    ## 1  1.222874 0.0000000
    ## 2  1.198520 0.3925436
    ## 3  1.145817 0.4308770
    ## 4  2.194375 0.5083655
    ## 5  4.082663 0.7011569
    ## 6  6.624717 1.1988347

## Fitting a model on data

We can then fit on
cascades.

``` r
fitted_model <- fit_series(model$data, model_type = 'EXP', observation_time = 5, cores = 10)

fitted_model
```

    ## Model: EXP 
    ## No. of cascades: 100 
    ## init_par
    ##   K 9.55e+00; theta 1.25e+00
    ## par
    ##   K 9.39e-01; theta 1.05e+00
    ## Neg Log Likelihood: 232.016 
    ## lower_bound
    ##   K 1.00e-100; theta 1.00e-100
    ## upper_bound
    ##   K 1.00e+04; theta 3.00e+02
    ## convergence: 0

## Acknowledgement

The development of this package is supported by the Green Policy grant
from the National Security College, Crawford School, ANU.

## Reference

> \[1\] Rizoiu, M. A., Lee, Y., Mishra, S., & Xie, L. (2017, December).
> Hawkes processes for events in social media. In Frontiers of
> Multimedia Research (pp. 191-218). Association for Computing Machinery
> and Morgan & Claypool.  
> \[2\] Rizoiu, M. A., Mishra, S., Kong, Q., Carman, M., & Xie, L.
> (2018, April). SIR-Hawkes: Linking epidemic models and Hawkes
> processes to model diffusions in finite populations. In Proceedings of
> the 2018 World Wide Web Conference (pp. 419-428). International World
> Wide Web Conferences Steering Committee.  
> \[3\] Mishra, S., Rizoiu, M. A., & Xie, L. (2016, October). Feature
> driven and point process approaches for popularity prediction. In
> Proceedings of the 25th ACM International on Conference on Information
> and Knowledge Management (pp. 1069-1078). ACM.  
> \[4\] Kong, Q., Rizoiu, M. A., & Xie, L. (2019). Modeling Information
> Cascades with Self-exciting Processes via Generalized Epidemic Models.
> arXiv preprint arXiv:1910.05451.
