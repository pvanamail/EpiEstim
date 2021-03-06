% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimate_r.R
\name{estimate_R}
\alias{estimate_R}
\title{Estimated Instantaneous Reproduction Number

\code{estimate_R} estimates the reproduction number of an epidemic, given the
incidence time series and the serial interval distribution.}
\usage{
estimate_R(
  incid,
  method = c("non_parametric_si", "parametric_si", "uncertain_si", "si_from_data",
    "si_from_sample"),
  si_data = NULL,
  si_sample = NULL,
  config = make_config(incid = incid, method = method)
)
}
\arguments{
\item{incid}{One of the following
\itemize{

\item{A vector (or a dataframe with a single column) of non-negative integers
containing the incidence time series}

\item{A dataframe of non-negative integers with either i) \code{incid$I}
containing the total incidence, or ii) two columns, so that
\code{incid$local} contains the incidence of cases due to local transmission
and \code{incid$imported} contains the incidence of imported cases (with
\code{incid$local + incid$imported} the total incidence). If the dataframe
contains a column \code{incid$dates}, this is used for plotting.
\code{incid$dates} must contains only dates in a row.}

\item{An object of class \code{\link{incidence}}}

}

Note that the cases from the first time step are always all assumed to be
imported cases.}

\item{method}{One of "non_parametric_si", "parametric_si", "uncertain_si",
"si_from_data" or "si_from_sample" (see details).}

\item{si_data}{For method "si_from_data" ; the data on dates of symptoms of
pairs of infector/infected individuals to be used to estimate the serial
interval distribution (see details).}

\item{si_sample}{For method "si_from_sample" ; a matrix where each column
gives one distribution of the serial interval to be explored (see details).}

\item{config}{An object of class \code{estimate_R_config}, as returned by 
function \code{make_config}.}
}
\value{
{
an object of class \code{estimate_R}, with components:
\itemize{

\item{R}{: a dataframe containing:
the times of start and end of each time window considered ;
the posterior mean, std, and 0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975
quantiles of the reproduction number for each time window.}

\item{method}{: the method used to estimate R, one of "non_parametric_si",
"parametric_si", "uncertain_si", "si_from_data" or "si_from_sample"}

\item{si_distr}{: a vector or dataframe (depending on the method) containing
 the discrete serial interval distribution(s) used for estimation}

\item{SI.Moments}{: a vector or dataframe (depending on the method)
containing the mean and std of the discrete serial interval distribution(s)
used for estimation}

\item{I}{: the time series of total incidence}

\item{I_local}{: the time series of incidence of local cases (so that
\code{I_local + I_imported = I})}

\item{I_imported}{: the time series of incidence of imported cases (so that
\code{I_local + I_imported = I})}

\item{dates}{: a vector of dates corresponding to the incidence time series}

\item{MCMC_converged}{ (only for method \code{si_from_data}): a boolean
showing whether the Gelman-Rubin MCMC convergence diagnostic was successful
(\code{TRUE}) or not (\code{FALSE})}
}
}
}
\description{
Estimated Instantaneous Reproduction Number

\code{estimate_R} estimates the reproduction number of an epidemic, given the
incidence time series and the serial interval distribution.
}
\details{
Analytical estimates of the reproduction number for an epidemic over
predefined time windows can be obtained within a Bayesian framework,
for a given discrete distribution of the serial interval (see references).

Several methods are available to specify the serial interval distribution.

In short there are five methods to specify the serial interval distribution
(see help for function \code{make_config} for more detail on each method).
In the first two methods, a unique serial interval distribution is
considered, whereas in the last three, a range of serial interval
distributions are integrated over:
\itemize{
\item{In method "non_parametric_si" the user specifies the discrete
distribution of the serial interval}
\item{In method "parametric_si" the user specifies the mean and sd of the
serial interval}
\item{In method "uncertain_si" the mean and sd of the serial interval are
each drawn from truncated normal distributions, with parameters specified by
the user}
\item{In method "si_from_data", the serial interval distribution is directly
estimated, using MCMC, from interval censored exposure data, with data
provided by the user together with a choice of parametric distribution for
the serial interval}
\item{In method "si_from_sample", the user directly provides the sample of
serial interval distribution to use for estimation of R. This can be a useful
 alternative to the previous method, where the MCMC estimation of the serial
 interval distribution could be run once, and the same estimated SI
 distribution then used in estimate_R in different contexts, e.g. with
 different time windows, hence avoiding to rerun the MCMC every time
 estimate_R is called.}
}
}
\examples{
## load data on pandemic flu in a school in 2009
data("Flu2009")

## estimate the reproduction number (method "non_parametric_si")
## when not specifying t_start and t_end in config, they are set to estimate
## the reproduction number on sliding weekly windows                          
res <- estimate_R(incid = Flu2009$incidence, 
                  method = "non_parametric_si",
                  config = make_config(list(si_distr = Flu2009$si_distr)))
plot(res)

## the second plot produced shows, at each each day,
## the estimate of the reproduction number over the 7-day window 
## finishing on that day.

## to specify t_start and t_end in config, e.g. to have biweekly sliding
## windows      
t_start <- seq(2, nrow(Flu2009$incidence)-13)   
t_end <- t_start + 13                 
res <- estimate_R(incid = Flu2009$incidence, 
                  method = "non_parametric_si",
                  config = make_config(list(
                      si_distr = Flu2009$si_distr, 
                      t_start = t_start, 
                      t_end = t_end)))
plot(res)

## the second plot produced shows, at each each day,
## the estimate of the reproduction number over the 14-day window 
## finishing on that day.

## example with an incidence object

## create fake data
library(incidence)
data <- c(0,1,1,2,1,3,4,5,5,5,5,4,4,26,6,7,9)
location <- sample(c("local","imported"), length(data), replace=TRUE)
location[1] <- "imported" # forcing the first case to be imported

## get incidence per group (location)
incid <- incidence(data, groups = location)

## Estimate R with assumptions on serial interval
res <- estimate_R(incid, method = "parametric_si",
                  config = make_config(list(
                  mean_si = 2.6, std_si = 1.5)))
plot(res)
## the second plot produced shows, at each each day,
## the estimate of the reproduction number over the 7-day window
## finishing on that day.

## estimate the reproduction number (method "parametric_si")
res <- estimate_R(Flu2009$incidence, method = "parametric_si",
                  config = make_config(list(mean_si = 2.6, std_si = 1.5)))
plot(res)
## the second plot produced shows, at each each day,
## the estimate of the reproduction number over the 7-day window
## finishing on that day.

## estimate the reproduction number (method "uncertain_si")
res <- estimate_R(Flu2009$incidence, method = "uncertain_si",
                  config = make_config(list(
                  mean_si = 2.6, std_mean_si = 1,
                  min_mean_si = 1, max_mean_si = 4.2,
                  std_si = 1.5, std_std_si = 0.5,
                  min_std_si = 0.5, max_std_si = 2.5,
                  n1 = 100, n2 = 100)))
plot(res)
## the bottom left plot produced shows, at each each day,
## the estimate of the reproduction number over the 7-day window
## finishing on that day.

\dontrun{
## Note the following examples use an MCMC routine
## to estimate the serial interval distribution from data,
## so they may take a few minutes to run

## load data on rotavirus
data("MockRotavirus")

## estimate the reproduction number (method "si_from_data")
MCMC_seed <- 1
overall_seed <- 2
R_si_from_data <- estimate_R(MockRotavirus$incidence,
                            method = "si_from_data",
                            si_data = MockRotavirus$si_data,
                            config = make_config(list(si_parametric_distr = "G",
                                        mcmc_control = make_mcmc_control(list(burnin = 1000,
                                        thin = 10, seed = MCMC_seed),
                                        n1 = 500, n2 = 50,
                                        seed = overall_seed))))

## compare with version with no uncertainty
R_Parametric <- estimate_R(MockRotavirus$incidence,
                          method = "parametric_si",
                          config = make_config(list(
                          mean_si = mean(R_si_from_data$SI.Moments$Mean),
                             std_si = mean(R_si_from_data$SI.Moments$Std))))
## generate plots
p_uncertainty <- plot(R_si_from_data, "R", options_R=list(ylim=c(0, 1.5)))
p_no_uncertainty <- plot(R_Parametric, "R", options_R=list(ylim=c(0, 1.5)))
gridExtra::grid.arrange(p_uncertainty, p_no_uncertainty,ncol=2)

## the left hand side graph is with uncertainty in the SI distribution, the
## right hand side without.
## The credible intervals are wider when accounting for uncertainty in the SI
## distribution.

## estimate the reproduction number (method "si_from_sample")
MCMC_seed <- 1
overall_seed <- 2
SI.fit <- coarseDataTools::dic.fit.mcmc(dat = MockRotavirus$si_data,
                 dist = "G",
                 init.pars = init_mcmc_params(MockRotavirus$si_data, "G"),
                 burnin = 1000,
                 n.samples = 5000,
                 seed = MCMC_seed)
si_sample <- coarse2estim(SI.fit, thin = 10)$si_sample
R_si_from_sample <- estimate_R(MockRotavirus$incidence,
                               method = "si_from_sample",
                               si_sample = si_sample,
                               config = make_config(list(n2 = 50, 
                               seed = overall_seed)))
plot(R_si_from_sample)

## check that R_si_from_sample is the same as R_si_from_data
## since they were generated using the same MCMC algorithm to generate the SI
## sample (either internally to EpiEstim or externally)
all(R_si_from_sample$R$`Mean(R)` == R_si_from_data$R$`Mean(R)`)
}

}
\references{
{
Cori, A. et al. A new framework and software to estimate time-varying
reproduction numbers during epidemics (AJE 2013).
Wallinga, J. and P. Teunis. Different epidemic curves for severe acute
respiratory syndrome reveal similar impacts of control measures (AJE 2004).
Reich, N.G. et al. Estimating incubation period distributions with coarse
data (Statis. Med. 2009)
}
}
\seealso{
\code{\link{discr_si}} \code{\link{make_config}}
}
\author{
Anne Cori \email{a.cori@imperial.ac.uk}
}
