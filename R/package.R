#' The gateR Package: Flow/Mass Cytometry Gating via Spatial Kernel Density Estimation
#'
#' Estimates statistically significant fluorescent marker combination values within which one immunologically distinctive group (i.e., disease case) is more associated than another group (i.e., healthy control), successively, using various combinations (i.e., "gates") of fluorescent markers to examine features of cells that may be different between groups.
#'
#' @details For a two-group comparison, the 'gateR' package uses the spatial relative risk function estimated using the \code{\link{sparr}} package. Details about the \code{\link{sparr}} package methods can be found in the tutorial: Davies et al. (2018) \doi{10.1002/sim.7577}. Details about kernel density estimation can be found in J. F. Bithell (1990) \doi{10.1002/sim.4780090616}. More information about relative risk functions using kernel density estimation can be found in J. F. Bithell (1991) \doi{10.1002/sim.4780101112}.
#' 
#' This package provides a function to perform a gating strategy for flow cytometry data. The 'gateR' package also provides basic visualization for each gate.
#' 
#' Key content of the 'gateR' package include:\cr
#' 
#' \bold{Gating Strategy}
#' 
#' \code{\link{gating}} Extracts cells within statistically significant combinations of fluorescent markers, successively, for a set of markers. Statistically significant combinations are identified using two-tailed p-values of a relative risk surface assuming asymptotic normality. This function is currently available for two-level comparisons of a single condition (e.g., case/control) or two conditions (e.g., case/control at time 1 and time 2). Provides functionality for basic visualization and multiple testing correction.
#' 
#' \code{\link{rrs}} Estimates a relative risk surface and computes the asymptotic p-value surface for a single gate with a single condition, including features for basic visualization. This function is used internally within the \code{\link{gating}} function to extract the points within the significant areas. This function can also be used as a standalone function.
#' 
#' \code{\link{lotrrs}} Estimates a ratio of relative risk surfaces and computes the asymptotic p-value surface for a single gate with two conditions, including features for basic visualization. This function is used internally within the \code{\link{gating}} function to extract the points within the significant areas. This function can also be used as a standalone function.
#' 
#' \bold{Flow Cytometry Data}
#' 
#' \code{\link{randCyto}} A sample dataset containing information about flow cytometry data with two binary categorical variables. The data are a random subset of the 'extdata' data in the 'flowWorkspaceData' package found on Bioconductor \url{https://bioconductor.org/packages/release/data/experiment/html/flowWorkspaceData.html} and formatted for 'gateR' input.
#' 
#' @name gateR-package
#' @aliases gateR-package gateR
#' @docType package
#' 
#' @section Dependencies: The 'gateR' package relies heavily upon \code{\link{sparr}}, \code{\link{spatstat.geom}}, and \code{\link{terra}}. For a two-level comparison, the spatial relative risk function uses the \code{\link[sparr]{risk}} function. The calculation of a Bonferroni correction for multiple testing accounting for the spatial correlation of the estimated surface uses the \code{\link[SpatialPack]{modified.ttest}} function. Basic visualizations rely on the \code{\link[fields]{image.plot}} function.
#' 
#' @author Ian D. Buller\cr \emph{Social & Scientific Systems, Inc., a division of DLH Corporation, Silver Spring, Maryland, USA (current); Occupational and Environmental Epidemiology Branch, Division of Cancer Epidemiology and Genetics, National Cancer Institute, National Institutes of Health, Rockville, Maryland, USA (former); Environmental Health Sciences, James T. Laney School of Graduate Studies, Emory University, Atlanta, Georgia, USA. (original)}\cr
#' 
#' Maintainer: I.D.B. \email{ian.buller@@alumni.emory.edu}
#'
#' @keywords package
NULL

#' @importFrom fields image.plot
#' @importFrom graphics close.screen par screen split.screen 
#' @importFrom grDevices chull colorRampPalette dev.off png
#' @importFrom lifecycle badge deprecate_warn deprecated is_present
#' @importFrom rlang abort inform
#' @importFrom sparr OS risk
#' @importFrom SpatialPack modified.ttest
#' @importFrom spatstat.geom as.im cut.im marks owin ppp
#' @importFrom stats na.omit pnorm relevel
#' @importFrom terra ext rast values
#' @importFrom tibble add_column
NULL
