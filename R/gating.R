#' Gating strategy for mass cytometry data using spatial relative risk functions
#' 
#' Extracts cells within statistically significant combinations of fluorescent markers, successively, for a set of markers. Statistically significant combinations are identified using two-tailed p-values of a relative risk surface assuming asymptotic normality. This function is currently available for two-level comparisons of a single condition (e.g., case/control) or two conditions (e.g., case/control at time 1 and time 2). Provides functionality for basic visualization and multiple testing correction.
#'
#' @param dat Input data frame flow cytometry data with the following features (columns): 1) ID, 2) Condition A ID, 3) Condition B ID (optional), and a set of markers.
#' @param vars A vector of characters with the name of features (columns) within \code{dat} to use as markers for each gate. See details below.
#' @param n_condition A numeric value of either 1 or 2 designating if the gating is performed with one condition or two conditions. 
#' @param numerator Logical. If \code{TRUE} (the default), cells will be extracted within all statistically significant numerator (i.e., case) clusters. If \code{FALSE}, cells will be extracted within all statistically significant denominator (i.e., control) clusters.
#' @param bandw Optional, numeric. Fixed bandwidth for the kernel density estimation. Default is based on the internal \code{[sparr]{OS}} function.
#' @param alpha Numeric. The two-tailed alpha level for significance threshold (default is 0.05).
#' @param p_correct Optional. Character string specifying whether to apply a correction for multiple comparisons including a False Discovery Rate \code{p_correct = "FDR"}, a spatially dependent Sidak correction \code{p_correct = "correlated Sidak"}, a spatially dependent Bonferroni correction \code{p_correct = "correlated Bonferroni"}, an independent Sidak correction \code{p_correct = "uncorrelated Sidak"}, an independent Bonferroni correction \code{p_correct = "uncorrelated Bonferroni"}, and a correction based on Random Field Theory using an equation by Adler and Hasofer \code{p_correct = "Adler and Hasofer"} or an equation by Friston et al. \code{p_correct = "Friston"}. If \code{p_correct = "none"} (the default), then no correction is applied.
#' @param nbc Optional. An integer for the number of bins when \code{p_correct = "correlated"}. Similar to \code{nbclass} argument in \code{\link[SpatialPack]{modified.ttest}}. The default is 30.
#' @param plot_gate Logical. If \code{TRUE}, the output includes basic data visualizations.
#' @param save_gate Logical. If \code{TRUE}, the output saves each visualization as a separate PNG file.
#' @param name_gate Optional, character. The filename of the visualization(s). The default is "gate_k" where "k" is the gate number.
#' @param path_gate Optional, character. The path of the visualization(s). The default is the current working directory.
#' @param rcols Character string of length three (3) specifying the colors for: 1) group A (numerator), 2) neither, and 3) group B (denominator) designations. The defaults are \code{c("#FF0000", "#cccccc", "#0000FF")} or \code{c("red", "grey80", "blue")}.
#' @param lower_lrr Optional, numeric. Lower cut-off value for the log relative risk value in the color key (typically a negative value). The default is no limit, and the color key will include the minimum value of the log relative risk surface. 
#' @param upper_lrr Optional, numeric. Upper cut-off value for the log relative risk value in the color key (typically a positive value). The default is no limit, and the color key will include the maximum value of the log relative risk surface.
#' @param c1n Optional, character. The name of the level for the numerator of condition A. The default is NULL, and the first level is treated as the numerator. 
#' @param c2n Optional, character. The name of the level for the numerator of condition B. The default is NULL, and the first level is treated as the numerator.
#' @param win Optional. Object of class \code{owin} for a custom two-dimensional window within which to estimate the surfaces. The default is NULL and calculates a convex hull around the data.
#' @param ... Arguments passed to \code{\link[sparr]{risk}} to select resolution.
#' @param doplot `r lifecycle::badge("deprecated")` \code{doplot} is no longer supported and has been renamed \code{plot_gate}.
#' @param verbose `r lifecycle::badge("deprecated")` \code{verbose} is no longer supported; this function will not display verbose output from internal \code{\link[sparr]{risk}} function.
#'
#' @details This function performs a sequential gating strategy for mass cytometry data comparing two levels with one or two conditions. Gates are typically two-dimensional space comprised of two fluorescent markers. The two-level comparison allows for the estimation of a spatial relative risk function and the computation of p-value based on an assumption of asymptotic normality. Cells within statistically significant areas are extracted and used in the next gate. This function relies heavily upon the \code{\link[sparr]{risk}} function. Basic visualization is available if \code{plot_gate = TRUE}. 
#' 
#' The \code{vars} argument must be a vector with an even-numbered length where the odd-numbered elements are the markers used on the x-axis of a gate, and the even-numbered elements are the markers used on the y-axis of a gate. For example, if \code{vars = c("V1", "V2", "V3", and "V4")} then the first gate is "V1" on the x-axis and "V2" on the y-axis and then the second gate is V3" on the x-axis and "V4" on the y-axis. Makers can be repeated in successive gates. 
#' 
#' The \code{n_condition} argument specifies if the gating strategy is performed for one condition or two conditions. If \code{n_condition = 1}, then the function performs a one condition gating strategy using the internal \code{rrs} function, which computes the statistically significant areas (clusters) of a relative risk surface at each gate and selects the cells within the clusters specified by the \code{numerator} argument. If \code{n_condition = 2}, then the function performs a two conditions gating strategy using the internal \code{lotrrs} function, which computes the statistically significant areas (clusters) of a ratio of relative risk surfaces at each gate and selects the cells within the clusters specified by the \code{numerator} argument. The condition variable(s) within \code{dat} must be of class 'factor' with two levels. The first level is considered the numerator (i.e., "case") value, and the second level is considered the denominator (i.e., "control") value. The levels can also be specified using the \code{c1n} and \code{c2n} parameters. See the documentation for the internal \code{rrs} and \code{lotrrs} functions for more details.
#' 
#' The p-value surface of the ratio of relative risk surfaces is estimated assuming asymptotic normality of the ratio value at each gridded knot. The bandwidth is fixed across all layers.
#' 
#' Provides functionality for a correction for multiple testing. If \code{p_correct = "FDR"}, calculates a False Discovery Rate by Benjamini and Hochberg. If \code{p_correct = "uncorrelated Sidak"}, calculates an independent Sidak correction. If \code{p_correct = "uncorrelated Bonferroni"}, calculates an independent Bonferroni correction. If \code{p_correct = "correlated Sidak"} or if \code{p_correct = "correlated Bonferroni"}, then the corrections take into account the into account the spatial correlation of the surface. (NOTE: If \code{p_correct = "correlated Sidak"} or if \code{p_correct = "correlated Bonferroni"}, it may take a considerable amount of computation resources and time to calculate). If \code{p_correct = "Adler and Hasofer"} or if \code{p_correct = "Friston"}, then calculates a correction based on Random Field Theory. If \code{p_correct = "none"} (the default), then the function does not account for multiple testing and uses the uncorrected \code{alpha} level. See the internal \code{pval_correct} function documentation for more details.
#'
#' @return An object of class \code{list}. This is a named list with the following components:
#' 
#' \describe{
#' \item{\code{obs}}{An object of class 'tibble' of the same features as \code{dat} that includes the information for the cells extracted with significant clusters in the final gate.}
#' \item{\code{n}}{An object of class 'list' of the sample size of cells at each gate. The length is equal to the number of successful gates plus the final result.}
#' \item{\code{gate}}{An object of class 'list' of 'rrs' objects from each gate. The length is equal to the number of successful gates.}
#' \item{\code{note}}{An object of class 'character' of the gating diagnostic message.}
#' }
#' 
#' The objects of class 'rrs' is similar to the output of the \code{\link[sparr]{risk}} function with two additional components:
#' \describe{
#' \item{\code{rr}}{An object of class 'im' with the relative risk surface.}
#' \item{\code{f}}{An object of class 'im' with the spatial density of the numerator.}
#' \item{\code{g}}{An object of class 'im' with the spatial density of the denominator.}
#' \item{\code{P}}{An object of class 'im' with the asymptotic p-value surface.}
#' \item{\code{lrr}}{An object of class 'im' with the log relative risk surface.}
#' \item{\code{alpha}}{A numeric value for the alpha level used within the gate.}
#' }
#'
#' @importFrom grDevices chull
#' @importFrom lifecycle badge deprecate_warn deprecated is_present
#' @importFrom rlang abort inform
#' @importFrom spatstat.geom cut.im marks owin ppp
#' @importFrom tibble add_column
#' @export
#' 
#' @examples
#' if (interactive()) {
#' ## Single condition, no multiple testing correction
#'   test_gate <- gating(dat = randCyto,
#'                       vars = c("arcsinh_CD4", "arcsinh_CD38",
#'                                "arcsinh_CD8", "arcsinh_CD3"),
#'                       n_condition = 1)
#' }
#' 
gating <- function(dat,
                   vars,
                   n_condition = c(1, 2),
                   numerator = TRUE,
                   bandw = NULL,
                   alpha = 0.05,
                   p_correct = "none",
                   nbc = NULL,
                   plot_gate = FALSE,
                   save_gate = FALSE,
                   name_gate = NULL,
                   path_gate = NULL,
                   rcols = c("#FF0000", "#CCCCCC", "#0000FF"),
                   lower_lrr = NULL,
                   upper_lrr = NULL,
                   c1n = NULL,
                   c2n = NULL,
                   win = NULL,
                   ...,
                   doplot = lifecycle::deprecated(),
                   verbose = lifecycle::deprecated()) {
  
  # Checks
  ## deprecate
  if (lifecycle::is_present(doplot)) {
    lifecycle::deprecate_warn("0.1.5", "gateR::gating(doplot = )", "gateR::gating(plot_gate = )")
    plot_gate <- doplot
  }
  if (lifecycle::is_present(verbose)) {
    lifecycle::deprecate_warn("0.1.5", "gateR::gating(verbose = )")
  }
  
  ## dat
  if ("data.frame" %!in% class(dat)) { stop("'dat' must be class 'data.frame'") }
  
  ## vars
  colnames(dat) <- make.names(colnames(dat), unique = TRUE)
  
  if (!all(vars %in% colnames(dat))) {
    stop("All elements in the argument 'vars' must match named features of 'dat'" )
  }
  
  if ((length(vars) %% 2) != 0 ) {
    stop("The argument 'vars' must be a character vector with an even-numbered length")
  }
  
  ## n_condition
  match.arg(as.character(n_condition), choices = 1:2)
  
  ## p_correct
  match.arg(p_correct, choices = c("none", "FDR", "correlated Sidak", "correlated Bonferroni", "uncorrelated Sidak", "uncorrelated Bonferroni", "Adler and Hasofer", "Friston"))
  
  ## numerator
  if (numerator == TRUE) { type_cluster <- "numerator" 
  } else { 
    type_cluster <- "denominator" 
  }
  
  ## alpha
  if (alpha <= 0 | alpha >= 1 ) {
    stop("The argument 'alpha' must be a numeric value between zero (0) and one (1)")
  }
  
  ## rcols
  if (length(rcols) != 3) {
    stop("The argument 'rcols' must be a vector of length three (3)")
  }
  
  ## win
  if (!is.null(win) & !inherits(win, "owin")) { stop("'win' must be class 'owin'") }
  
  # Format data input
  dat <- dat[!is.na(dat[ , which(colnames(dat) %in% vars[1])]) &
               !is.na(dat[ , which(colnames(dat) %in% vars[2])]), ]

  if (n_condition == 1 & nlevels(dat[ , 2]) != 2) { stop("The second feature of 'dat' must be a binary factor") }
  
  if (n_condition == 2 & nlevels(dat[ , 2]) != 2) { stop("The second feature of 'dat' must be a binary factor") }
  
  if (n_condition == 2 & nlevels(dat[ , 3]) != 2) { stop("The third feature of 'dat' must be a binary factor") }
  
  if (n_condition == 2) { dat_gate <- dat[ , c(1:3, which(colnames(dat) %in% vars))]
  } else {
    dum_condition <- rep(1, nrow(dat))
    dat_gate <- dat[ , c(1:2, which(colnames(dat) %in% vars))]
    dat_gate <- tibble::add_column(dat_gate, condition = dum_condition, .after = 2)
  }
  dat <- as.data.frame(dat)
  dat_gate <- as.data.frame(dat_gate)
  n_gate <- length(vars) / 2 # calculate the number of gates

  # Create empty list to save output of each gate
  list_gate <- vector('list', length(n_gate))
  n_out <- vector('list', length(n_gate))

  # Gating
  for (k in 1:n_gate) {

  if (k == 1) { j <- 1 } else { j <- k * 2 - 1 } # vars indexing per gate

    # format data by selecting the desired vars
    dat_gate <- dat_gate[!is.na(dat_gate[ , which(colnames(dat_gate) %in% vars[j])]) &
                           !is.na(dat_gate[ , which(colnames(dat_gate) %in% vars[j + 1])]), ]
    xvar <-  which(colnames(dat_gate) %in% vars[j])
    yvar <-  which(colnames(dat_gate) %in% vars[j + 1])
    df <- dat_gate[ , c(1:3, xvar, yvar)]
    df <- df[!is.na(df[ , 4]) & !is.na(df[ , 5]), ] # remove NAs

    # Create custom window with a convex hull
    chul <- grDevices::chull(df[ , 4:5])
    chul_coords <- df[ , 4:5][c(chul, chul[1]), ]
    win_gate <- spatstat.geom::owin(poly = list(x = rev(chul_coords[ , 1]),
                                                y = rev(chul_coords[ , 2])))

    # Estimate significant relative risk areas
    ## Bonferroni correction only necessary in first gate
    if (k == 1) { p_correct <- p_correct } else { p_correct <- "none" }
    
    n_out[[k]] <- nrow(df)
    name_gate <- paste("gate", k, sep = "_")

    if (n_condition == 2) {
      out <- lotrrs(dat = df,
                    bandw = bandw,
                    win = win_gate,
                    plot_gate = plot_gate,
                    save_gate = save_gate,
                    name_gate = name_gate,
                    path_gate = path_gate,
                    alpha = alpha,
                    p_correct = p_correct,
                    nbc = nbc,
                    rcols = rcols,
                    lower_lrr = lower_lrr,
                    upper_lrr = upper_lrr,
                    c1n = c1n,
                    c2n = c2n,
                    ...)
    } else {
      out <- rrs(dat = df,
                 bandw = bandw,
                 win = win_gate,
                 plot_gate = plot_gate,
                 save_gate = save_gate,
                 name_gate = name_gate,
                 path_gate = path_gate,
                 alpha = alpha,
                 p_correct = p_correct,
                 nbc = nbc,
                 rcols = rcols,
                 lower_lrr = lower_lrr,
                 upper_lrr = upper_lrr,
                 c1n = c1n,
                 ...)
    }
    
    # Convert p-value surface into a categorized 'im'
    ## v == 2 : significant T1 numerator;  v == 1: not
    Ps <- spatstat.geom::cut.im(out$P, breaks = c(-Inf, out$alpha / 2, 1 - out$alpha / 2, Inf), labels = c("1", "2", "3")) 
    list_gate[[k]] <- out # save for output
    rm(out, df) # conserve memory

    # Go back one gate if current gate has no significant area and produce output of previous gate
    if (all(Ps$v == "2", na.rm = TRUE) | all(is.na(Ps$v))) {
      if (k > 1) {
        mess <- paste("Gate", k, "yielded no significant", type_cluster, "cluster(s)...",
                      "Returning results from Gate", k-1,
                      sep = " ")
        rlang::inform(mess, mess = mess)
        output <- dat[which(dat[ , 1] %in% dat_gate[ , 1]), ]
        out_list <- list("obs" = output, "n" = n_out, "gate" = list_gate, "note" = mess)
        return(out_list)
      } else {
        mess <- paste("Gate 1 yielded no significant clustering... Returning no results", sep = " ")
        out_list <- list("obs" = NULL, "n" = NULL, "gate" = list_gate, "note" = mess)
        rlang::abort(mess, out = out_list)
        return(out)
      }
    }

    if (numerator == TRUE) { v <- "1" } else { v <- "3" }

    if (!any(Ps$v == v, na.rm = TRUE)) {
      if (k > 1) {
        mess <- paste("Gate", k, "yielded no significant", type_cluster, "cluster(s)...",
                      "Returning results from Gate", k-1,
                      sep = " ")
        rlang::inform(mess, mess = mess)
        output <- dat[which(dat[ , 1] %in% dat_gate[ , 1]), ]
        out_list <- list("obs" = output, "n" = n_out, "gate" = list_gate, "note" = mess)
        return(out_list)
      } else {
        mess <- paste("Gate 1 yielded no significant", type_cluster, "cluster(s)... Returning no results", sep = " ")
        out_list <- list("obs" = NULL, "n" = NULL, "gate" = list_gate, "note" = mess)
        rlang::abort(mess, out = out_list)
        return(out)
      }
    }

    # Overlay points
    suppressMessages(suppressWarnings(full_ppp <- spatstat.geom::ppp(x = dat_gate[,which(colnames(dat_gate) %in% vars[j])],
                                                                     y = dat_gate[,which(colnames(dat_gate) %in% vars[j + 1])],
                                                                     marks = dat_gate,
                                                                     window = win_gate)))

    # extract points within significant cluster(s)
    spatstat.geom::marks(full_ppp)$gate <- Ps[full_ppp, drop = FALSE]
    dat_gate <- spatstat.geom::marks(full_ppp)[spatstat.geom::marks(full_ppp)$gate == v, ]

    # Output for the final gate
    if (k == n_gate) {
      mess <- paste("Observations within significant", type_cluster, "cluster(s) of Gate", k, sep = " ")
      rlang::inform(mess, mess = mess)
      output <- dat[which(dat[ , 1] %in% dat_gate[ , 1]), ]
      n_out[[k + 1]] <- nrow(output)
      out_list <- list("obs" = output, "n" = n_out, "gate" = list_gate, "note" = mess)
      return(out_list)
    }
  }
}
