\name{pn.modselect.step}
\alias{pn.modselect.step}
\title{Backwards Stepwise Selection of Positive-Negative Richards \eqn{nlslist} Models}

\usage{
pn.modselect.step(x,
y,
grp,
pn.options,
forcemod = 0,
existing = FALSE,
penaliz = "1/sqrt(n)",
taper.ends = 0.45,
Envir = .GlobalEnv,
...)
}
\arguments{
  \item{x}{a numeric vector of the primary predictor}
  \item{y}{a numeric vector of the response variable}
  \item{grp}{a factor of same length as x and y that distinguishes groups within
the dataset}
  \item{pn.options}{required character string specifying name of 
\code{\link{list}} object populated with starting 
parameter estimates, fitting options and bounds}
  \item{forcemod}{optional numeric value to constrain model selection (see Details)}
  \item{existing}{optional logical value specifying whether some of the relevant models
have already been fitted}
  \item{penaliz}{optional character value to determine how models are ranked (see Details)}
  \item{taper.ends}{numeric representing the proportion of the range of the x variable for which data are extended at 
the two ends of the data set. This is used in initial estimation (prior to optim and nls optimizations) and can 
speed up subsequent optimizations by imposing a more pronounced S-shape to both first and second curves. Defaults to 0.45.}
  \item{Envir}{a valid R environment to find pn.options in and export any output to, by default this is the global
  environment} 
  \item{...}{additional optional arguments to be passed to nlsList}
}
\description{This function performs backawards stepwise model selection for \code{\link{nlsList}}
models fitted using
\code{\link{SSposnegRichards}}.} 
\details{ First, whether parameter M should be fixed
(see \code{\link{SSposnegRichards}}) is determined by fitting models 12 and 32 and comparing
their perfomance using \code{\link{extraF}}.
If model 12 provides superior performance (variable values of M) then 16 models that estimate M
are run (models 1 through 16), otherwise the models with fixed M are fitted (models 21 through 36).
Model selection then proceeds by fitting the most general model (8-parameter, model 1 for variable M;
7-parameter, model 21 for fixed M). At each subsequent step reduced models are evaluated
by creating \code{\link{nlsList}} models through removal of a single parameter from the decreasing
section of the curve (i.e. RAsym, Rk, Ri or RM). This is repeated until all possible models with
one less parameter have been fitted and then these models are then ranked by modified pooled residual
standard error (see below) to determine which reduced parameter model provides the best fit. This ranking
esnures that in all cases subsequent extra sum-of-squares F-tests are only made between fully nested models. 
The best ranked reduced parameter model is then compared with the more general model retained from the
the previous step using the function \code{\link{extraF}} to determine whether the more general
model provides significant improvement over the best reduced model. The most appropriate model
is then retained to be used as the general model in the next step. This process continues
for up to six steps (all steps will be attempted even if the general model provides better
performance to allow for much more reduced models to also be evaluated). The most reduced model
possible to evaluate in this function contains only parameters for the positive section of the curve
(4-parameters for variable M, 3-parameters for fixed M).

Fitting these \code{\link{nlsList}} models can be time-consuming (2-4 hours using the dataset
\code{\link{posneg.data}} that encompasses 100 individuals) and if several of the relevant
models are already fitted the option existing=TRUE can be used to avoid refitting models that
already exist globally (note that a model object in which no grouping levels were successfully
parameterized will be refitted, as will objects that are not of class \code{\link{nlsList}}).

Specifying forcemod=3 will force model selection to only consider fixed M models and setting
forcemod=4 will force model selection to consider models with varying values of M only.
If fitting both models 12 and 32 fails, fixed M models will be used by default.

taper.ends can be used to speed up optimization as it extends the dataset at maximum and minimum extremes 
of x by repeatedly pasting the y values at these extremes for a specified proportion of the range of x. 
taper.ends is a numeric value representing the proportion of the range of x values are extended for and 
defaults to 0.45 (45%) at both ends. For growth analysis, where the end of the curves are more likely to 
tend towards a zero slope this is a suitable values. If tapered ends are not desirable then choose taper.ends = 0.

Competing non-nested models are ranked by modified pooled residual square error. By default this is residual 
standard error divided by the square root of sample size. This exponentially penalizes models for which very few
grouping levels (individuals) are successfully parameterized (the few individuals that are
parameterized in these models are fit unsuprisingly well) using a function based on the relationship
between standard error and sample size. However, different users may have different preferences
and these can be specified in the argument penaliz (which residual
standard error is multiplied by). This argument must be a character value
that contains the character n (sample size) and must be a valid right hand side (RHS) of a formula:
e.g. 1*(n), (n)^2. It cannot contain more than one n but could be a custom function, e.g. FUN(n).}
\value{A \code{\link{data.frame}} containing statistics produced by \code{\link{extraF}}
evaluations at each step, detailing the name of the general and best reduced model at each
step. The overall best model evaluated by the end of the function is saved globally as
\eqn{pn.bestmodel.lis}
The naming convention for models is a concatenation of 'richardsR', the modno and '.lis'
(see \code{\link{SSposnegRichards}}).}

\author{Stephen Oswald <steve.oswald@psu.edu>}
\note{If appropriate bounds (or starting parameters) are not available in the list specified by the variable supplied 
to \code{pn.options}, \code{\link{modpar}} will be called automatically prior to model selection. 
During selection, text is output to the screen to inform the user of the progress of model selection
(which model is being fitted)

  Version 1.5 saves many variables, and internal variables in the package environment:
  FlexParamCurve:::FPCEnv. By default, the pn.options file is copied to the environment
  specified by the functions (global environment by default). Model selection routines
  also copy from FPCenv to the global environment all nlsList models fitted during 
  model selection to provide backcompatibility with code for earlier versions. The user
  can redirect the directory to copy to by altering the Envir argument when calling the 
  function.
 }


\seealso{\code{\link{pn.mod.compare}}
\code{\link{extraF}}
\code{\link{SSposnegRichards}}
\code{\link{nlsList}}}
\examples{
\donttest{
#these examples will take a long while to run as they have to complete the 32 model comparison
#run model selection for posneg.data object (only first 3 group levels for example's sake)
   try( rm(myoptions), silent = TRUE)
   subdata <- subset(posneg.data, as.numeric(row.names (posneg.data) ) < 40)
   modseltable <- pn.modselect.step(subdata$age, subdata$mass,
      subdata$id, existing = FALSE, pn.options = "myoptions")
   modseltable

#fit nlsList model initially and then run model selection
#for posneg.data object when at least one model is already fit
#(only first 3 group levels for example's sake)
    richardsR22.lis <- nlsList(mass ~ SSposnegRichards(age, Asym = Asym, K = K,
      Infl = Infl, RAsym = RAsym, Rk = Rk, Ri = Ri , modno = 22, pn.options = "myoptions")
                        ,data = subdata)
   modseltable <- pn.modselect.step(subdata$age, subdata$mass,
      subdata$id, forcemod = 3, existing = TRUE, pn.options = "myoptions")
   modseltable

#run model selection ranked by residual standard error*sample size
#(only first 3 group levels for example's sake)
    modseltable <- pn.modselect.step(subdata$age, subdata$mass,
      subdata$id, penaliz='1*(n)', existing = TRUE, pn.options = "myoptions")
    modseltable
    }
}
