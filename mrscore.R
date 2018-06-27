# Usage:
#
# source("mrscore.R")
# calculateMRscore(Table(getGEO("GSM1886935")))


MRscoreCpgSites = read.csv("cpgsites_multipliers_cutoffs.csv", strip.white = TRUE, blank.lines.skip = TRUE, comment.char = "#")
HRMapping =  read.csv("continousrisk_to_hr_mapping.csv", strip.white = TRUE, blank.lines.skip = TRUE, comment.char = "#")
EstherSpline = smooth.spline(HRMapping$Risk, HRMapping$HREsther, df=7)
KoraSpline = smooth.spline(HRMapping$Risk, HRMapping$HRKora, df=7)

calculateMRscore = function(geoMethylationTable) {
  mergedTable = merge(MRscoreCpgSites, geoMethylationTable, by.x = "CpGsites", by.y = "ID_REF")
  noncontMR = sum(mergedTable$VALUE <= mergedTable$Lower) + sum(mergedTable$VALUE >= mergedTable$Higher)
  contMR = sum(mergedTable$VALUE * mergedTable$Multipliers)
  contHREster = predict(EstherSpline, contMR)$y
  contHRKora = predict(KoraSpline, contMR)$y
  return(list("MRscore" = noncontMR, "contMRscore" = contMR, "contHREsther" = contHREster, "contHKora" = contHRKora, "merged" = mergedTable))
}