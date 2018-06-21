# Usage:
#
# source("mrscore.R")
# calculateMRscore(Table(getGEO("GSM1886935")))


MRscoreCpgSites = read.csv("cpgsites_multipliers_cutoffs.csv", strip.white = TRUE, blank.lines.skip = TRUE, comment.char = "#")

calculateMRscore = function(geoMethylationTable) {
  mergedTable = merge(MRscoreCpgSites, geoMethylationTable, by.x = "CpGsites", by.y = "ID_REF")
  noncontMR = sum(mergedTable$VALUE <= mergedTable$Lower) + sum(mergedTable$VALUE >= mergedTable$Higher)
  contMR = sum(mergedTable$VALUE * mergedTable$Multipliers)
  return(list("MRscore" = noncontMR, "contMRscore" = contMR, "merged" = mergedTable))
}