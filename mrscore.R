# Usage:
#
# source("mrscore.R")
# calculateMRscore(Table(getGEO("GSM1886935")))

MRscoreCpgSites = read.csv("cpgsites_multipliers_cutoffs.csv", strip.white = TRUE, blank.lines.skip = TRUE, comment.char = "#")
RiskMapping =  read.csv("risk_to_hr_mapping.csv", strip.white = TRUE, blank.lines.skip = TRUE, comment.char = "#")
ContRiskMapping = read.csv("continousrisk_to_hr_mapping.csv", strip.white = TRUE, blank.lines.skip = TRUE, comment.char = "#")
EstherSpline = smooth.spline(ContRiskMapping$Risk, ContRiskMapping$HREsther, df=7)
KoraSpline = smooth.spline(ContRiskMapping$Risk, ContRiskMapping$HRKora, df=7)

calculateMRscore = function(geoMethylationTable) {
  if(!"ID_REF" %in% colnames(geoMethylationTable)) {
    stop("Missing ID_REF column")
  }
  mergedTable = merge(MRscoreCpgSites, geoMethylationTable, by.x = "CpGsites", by.y = "ID_REF")
  noncontMR = sum(mergedTable$VALUE <= mergedTable$Lower) + sum(mergedTable$VALUE >= mergedTable$Higher)
  noncontHREsther = subset(RiskMapping, Lower <= noncontMR & Upper >= noncontMR)$HREstherModel3
  noncontHRKora = subset(RiskMapping, Lower <= noncontMR & Upper >= noncontMR)$HRKoraModel3
  contMR = sum(mergedTable$VALUE * mergedTable$Multipliers)
  contHREster = predict(EstherSpline, contMR)$y
  contHRKora = predict(KoraSpline, contMR)$y
  return(list("MRscore" = noncontMR, "HREsther" = noncontHREsther, "HRKora" = noncontHRKora, "contMRscore" = contMR, "contHREsther" = contHREster, "contHKora" = contHRKora, "merged" = mergedTable))
}