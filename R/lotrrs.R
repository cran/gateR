#' A single gate for two conditions
#'
#' Estimates a ratio of relative risk surfaces and computes the asymptotic p-value surface for a single gate with two conditions. Includes features for basic visualization. This function is used internally within the \code{\link{gating}} function to extract the points within the significant areas. This function can also be used as a standalone function.
#'
#' @param dat Input data frame flow cytometry data with five (5) features (columns): 1) ID, 2) Condition A ID, 3) Condition B ID, 4) Marker A as x-coordinate, 5) Marker B as y-coordinate.
#' @param bandw Optional, numeric. Fixed bandwidth for the kernel density estimation. Default is based on the internal \code{[sparr]{OS}} function.
#' @param alpha Numeric. The two-tailed alpha level for significance threshold (default is 0.05).
#' @param p_correct Optional. Character string specifying whether to apply a correction for multiple comparisons including a False Discovery Rate \code{p_correct = "FDR"}, a spatially dependent Sidak correction \code{p_correct = "correlated Sidak"}, a spatially dependent Bonferroni correction \code{p_correct = "correlated Bonferroni"}, an independent Sidak correction \code{p_correct = "uncorrelated Sidak"}, an independent Bonferroni correction \code{p_correct = "uncorrelated Bonferroni"}, and a correction based on Random Field Theory using an equation by Adler and Hasofer \code{p_correct = "Adler and Hasofer"} or an equation by Friston et al. \code{p_correct = "Friston"}. If \code{p_correct = "none"} (the default), then no correction is applied. 
#' @param nbc Optional. An integer for the number of bins when \code{p_correct = "correlated"}. Similar to \code{nbclass} argument in \code{\link[SpatialPack]{modified.ttest}}. The default is 30. 
#' @param plot_gate Logical. If \code{TRUE}, the output includes basic data visualization.
#' @param save_gate Logical. If \code{TRUE}, the output saves the visualization as a separate PNG file.
#' @param name_gate Optional, character. The filename of the visualization. The default is "gate".
#' @param path_gate Optional, character. The path of the visualization. The default is the current working directory.
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
#' @details This function estimates a ratio of relative risk surfaces and computes the asymptotic p-value surface for a single gate with two conditions using three successive \code{\link[sparr]{risk}} functions. A relative risk surface is estimated for Condition A at each level of Condition B, and then a ratio of the two relative risk surfaces is computed. 
#' 
#' \deqn{RR_{Condition B1} = \frac{Condition A2 of B1}{Condition A1 of B1}}
#' \deqn{RR_{Condition B2} = \frac{Condition A2 of B2}{Condition A1 of B2}}
#' \deqn{ln(rRR) = ln\left (\frac{RR_{Condition B2}}{CRR_{Condition B2}}\right )}
#' 
#' The p-value surface of the ratio of relative risk surfaces is estimated assuming asymptotic normality of the ratio value at each gridded knot. The bandwidth is fixed across all layers. Basic visualization is available if \code{plot_gate = TRUE}. 
#' 
#' Provides functionality for a correction for multiple testing. If \code{p_correct = "FDR"}, calculates a False Discovery Rate by Benjamini and Hochberg. If \code{p_correct = "uncorrelated Sidak"}, calculates an independent Sidak correction. If \code{p_correct = "uncorrelated Bonferroni"}, calculates an independent Bonferroni correction. If \code{p_correct = "correlated Sidak"} or if \code{p_correct = "correlated Bonferroni"}, then the corrections take into account the into account the spatial correlation of the surface. (NOTE: If \code{p_correct = "correlated Sidak"} or if \code{p_correct = "correlated Bonferroni"}, it may take a considerable amount of computation resources and time to calculate). If \code{p_correct = "Adler and Hasofer"} or if \code{p_correct = "Friston"}, then calculates a correction based on Random Field Theory. If \code{p_correct = "none"} (the default), then the function does not account for multiple testing and uses the uncorrected \code{alpha} level. See the internal \code{pval_correct} function documentation for more details.
#' 
#' The two condition variables (Condition A and Condition B) within \code{dat} must be of class 'factor' with two levels. The first level in each variable is considered the numerator (i.e., "case") value, and the second level is considered the denominator (i.e., "control") value. The levels can also be specified using the \code{c1n} and \code{c2n} parameters.
#'
#' @return An object of class 'list' where each element is a object of class 'rrs' created by the \code{\link[sparr]{risk}} function with two additional components:
#' 
#' \describe{
#' \item{\code{rr}}{An object of class 'im' with the relative risk surface.}
#' \item{\code{f}}{An object of class 'im' with the spatial density of the numerator.}
#' \item{\code{g}}{An object of class 'im' with the spatial density of the denominator.}
#' \item{\code{P}}{An object of class 'im' with the asymptotic p-value surface.}
#' \item{\code{lrr}}{An object of class 'im' with the log relative risk surface.}
#' \item{\code{alpha}}{A numeric value for the alpha level used within the gate.}
#' }
#'
#' @importFrom fields image.plot
#' @importFrom graphics close.screen par screen split.screen 
#' @importFrom grDevices chull dev.off png
#' @importFrom lifecycle badge deprecate_warn deprecated is_present
#' @importFrom spatstat.geom owin ppp 
#' @importFrom sparr OS risk
#' @importFrom stats relevel
#' @importFrom terra ext values
#' @export 
#'
#' @examples
#' test_lotrrs <- lotrrs(dat = randCyto)
#' 
lotrrs <- function(dat, 
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
    lifecycle::deprecate_warn("0.1.5", "gateR::lotrrs(doplot = )", "gateR::lotrrs(plot_gate = )")
    plot_gate <- doplot
  }
  if (lifecycle::is_present(verbose)) {
    lifecycle::deprecate_warn("0.1.5", "gateR::lotrrs(verbose = )")
  }

  ## dat
  if ("data.frame" %!in% class(dat)) { stop("'dat' must be class 'data.frame'") }
  
  ## group
  if (nlevels(dat[ , 2]) != 2) { stop("The second feature of 'dat' must be a binary factor") }
  
  if (nlevels(dat[ , 3]) != 2) { stop("The third feature of 'dat' must be a binary factor") }
  
  ## p_correct
    match.arg(p_correct, choices = c("none", "FDR", "correlated Sidak", "correlated Bonferroni", "uncorrelated Sidak", "uncorrelated Bonferroni", "Adler and Hasofer", "Friston"))
  
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
  if (is.null(win)) {
    dat <- as.data.frame(dat)
    dat <- dat[!is.na(dat[ , 4]) & !is.na(dat[ , 5]) , ]
    chul <- grDevices::chull(dat[ , 4:5])
    chul_coords <- dat[ , 4:5][c(chul, chul[1]), ]
    win <- spatstat.geom::owin(poly = list(x = rev(chul_coords[ , 1]),
                                           y = rev(chul_coords[ , 2])))
  }
  
  Vnames <- names(dat) # axis names
  names(dat) <- c("id", "G1", "G2", "V1", "V2")
  
  if (!is.null(c1n)) {
    if (!is.character(c1n)) { stop("The argument 'c1n' must be class 'character'") }
    if ("try-error" %in% class(try(stats::relevel(dat$G1, c1n), silent = T))) {
      stop("The argument 'c1n' must be an existing level within condition A")
    } else {
      dat$G1 <- stats::relevel(dat$G1, c1n)
    }
  }
  
  if (!is.null(c2n)) {
    if (!is.character(c2n)) { stop("The argument 'c2n' must be class 'character'") }
    if ("try-error" %in% class(try(stats::relevel(dat$G2, c2n), silent = T))) {
      stop("The argument 'c2n' must be an existing level within condition B")
    } else {
      dat$G2 <- stats::relevel(dat$G2, c2n)
    }
  }
  
  # Create two PPPs
  numer_df <- dat[dat$G2 == levels(dat$G2)[1], ]
  denom_df <- dat[dat$G2 == levels(dat$G2)[2], ]
  suppressMessages(suppressWarnings(both_ppp <- spatstat.geom::ppp(x = dat$V1,
                                                                   y = dat$V2,
                                                                   marks = dat$G1,
                                                                   window = win)))
  suppressMessages(suppressWarnings(denom_ppp <- spatstat.geom::ppp(x = denom_df$V1,
                                                                    y = denom_df$V2,
                                                                    marks = denom_df$G1,
                                                                    window = win)))
  suppressMessages(suppressWarnings(numer_ppp <- spatstat.geom::ppp(x = numer_df$V1,
                                                                    y = numer_df$V2,
                                                                    marks = numer_df$G1,
                                                                    window = win)))
  
  # Estimate two SRRs
  if (is.null(bandw)){ bandw <- sparr::OS(both_ppp, "geometric") }
  
  rm(both_ppp) # conserve memory
  denom_rr <- sparr::risk(denom_ppp,
                          h0 = bandw,
                          log = FALSE,
                          edge = "diggle",
                          verbose = FALSE,
                          ...)
  numer_rr <- sparr::risk(numer_ppp,
                          h0 = bandw,
                          log = FALSE,
                          edge = "diggle",
                          verbose = FALSE,
                          ...)
  
  # Create objects of class 'bivden'
  denom_bd <- sparr::bivariate.density(denom_ppp,
                                       h0 = bandw,
                                       edge = "diggle",
                                       verbose = FALSE,
                                       ...)
  numer_bd <- sparr::bivariate.density(numer_ppp,
                                       h0 = bandw,
                                       edge = "diggle",
                                       verbose = FALSE,
                                       ...)
  denom_rr_bd <- list("z" = denom_rr$rr,
                      "h0" = denom_rr$f$h0,
                      "hp" = denom_rr$f$hp,
                      "h" = denom_rr$f$h,
                      "him" = denom_rr$f$him,
                      "q" = denom_bd$q,
                      "gamma" = denom_rr$f$gamma,
                      "geometric" = denom_rr$f$geometric,
                       "pp" = denom_ppp)
  numer_rr_bd <- list("z" = numer_rr$rr,
                      "h0" = numer_rr$f$h0,
                      "hp" = numer_rr$f$hp,
                      "h" = numer_rr$f$h,
                      "him" = numer_rr$f$him,
                      "q" = numer_bd$q,
                      "gamma" = numer_rr$f$gamma,
                      "geometric" = numer_rr$f$geometric,
                      "pp" = numer_ppp)
  class(denom_rr_bd) <- "bivden"
  class(numer_rr_bd) <- "bivden"
  rm(denom_ppp, numer_ppp, denom_bd, numer_bd) # conserve memory
  
  # Estimate the spatial relative risk surface of the two spatial relative risks
  ## Also estimate the asymptotic p-value surface
  suppressMessages(suppressWarnings(out <- sparr::risk(f = numer_rr_bd,
                                                       g = denom_rr_bd,
                                                       h0 = bandw,
                                                       tolerate = TRUE,
                                                       edge = "diggle",
                                                       verbose = FALSE,
                                                       log = FALSE,
                                                       ...)))
  
  suppressMessages(suppressWarnings(out$rr <- numer_rr_bd$z/denom_rr_bd$z))
  suppressMessages(suppressWarnings(out$lrr <- log(numer_rr_bd$z) - log(denom_rr_bd$z)))
  rm(denom_rr_bd, numer_rr_bd) # conserve memory
  
  if (all(is.na(out$rr$v))) { 
    message("relative risk unable to be estimated")
    return(out)
  }
  
  # Alpha level
  if (p_correct == "none") { p_critical <- alpha 
  } else {
    if (p_correct == "correlated Sidak" | p_correct == "correlated Bonferroni") {
      message("Please be patient... Calculating spatially dependent correction")
    }
    p_critical <- pval_correct(input = out, type = p_correct, alpha = alpha, nbc = nbc)
  }
  
  out$alpha <- p_critical
  
  if (plot_gate == TRUE) {
    # Graphics
    op <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(op))
    # Plotting inputs
    ## Colorkeys
    tr_plot <- lrr_plot(input = out$lrr,
                        cols = rcols,
                        midpoint = 0,
                        upper_lrr = upper_lrr,
                        lower_lrr = lower_lrr)
    ## Extent
    blim <- as.vector(terra::ext(tr_plot$v))
    xlims <- blim[1:2]
    ylims <- blim[3:4]

    # Plot of ratio and p-values
    #Vnames <- names(dat) # axis names
    Ps <- pval_plot(out$P, alpha = out$alpha)
    if (all(terra::values(Ps)[!is.na(terra::values(Ps))] == 2) | all(is.na(terra::values(Ps)))) {
      pcols <- rcols[2]
      brp <- c(1, 3)
      atp <- 2
      labp <- "No"
    } else {
      pcols <- rcols
      brp <- c(1, 1.67, 2.33, 3)
      atp <- c(1.33, 2, 2.67)
      labp <- c("numerator", "insignificant", "denominator")
    }
    
    # If save plot as a PNG file
    if (save_gate == TRUE) { 
      if (is.null(name_gate)) { name_gate <- "gate" } # capture name 
      gate_file <- paste(path_gate, name_gate, ".png", sep = "") # set filename for image
      grDevices::png(filename = gate_file, width = 800, height = 600) # open graphics device
    }

    graphics::par(pty = "s", bg = "white")
    invisible(graphics::split.screen(matrix(c(0, 0.45, 0.55, 1, 0.14, 0.14, 0.86, 0.86),
                                            ncol = 4)))
    graphics::screen(1)
    fields::image.plot(tr_plot$v,
                       breaks = tr_plot$breaks,
                       col = tr_plot$cols,
                       xlim = xlims,
                       ylim = ylims,
                       axes = TRUE,
                       cex.lab = 1,
                       xlab = paste(Vnames[4], "\n", sep = ""),
                       ylab = Vnames[5],
                       cex = 1,
                       horizontal = TRUE,
                       axis.args = list(at = tr_plot$at,
                                        labels = tr_plot$labels,
                                        cex.axis = 0.67),
                       main = paste("log of the\nrelative risk surfaces\n(bandwidth:",
                                    round(bandw, digits = 3),
                                    "units)",
                                    sep = " "))
    par(bg = "transparent")
    graphics::screen(2)
    fields::image.plot(Ps,
                       breaks = brp,
                       col = pcols,
                       xlim = xlims,
                       ylim = ylims,
                       xlab = paste(Vnames[4], "\n", sep = ""),
                       ylab = "",
                       cex = 1,
                       axes = TRUE,
                       horizontal = TRUE,
                       axis.args = list(at = atp,
                                        labels = labp,
                                        cex.axis = 0.67),
                       main = paste("significant p-values\n(alpha = ",
                                    formatC(out$alpha, format = "e", digits = 2),
                                    ")",
                                    sep = ""))
    graphics::close.screen(all = TRUE) # exit split-screen mode
  }
  if (save_gate == TRUE) { grDevices::dev.off() } # close graphics device

  return(out)
}
