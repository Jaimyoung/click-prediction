collapse_levels = function(x, target_nlevels = 10){
  # Input: character / factor vector x,
  # Output: factor(x) with up to target_nlevels levels.
  #   Top target_nlevels-1 levels with most observations are kept and other
  #   levels are merged into "Other" level.
  x = as.factor(x)
  if (nlevels(x) <= target_nlevels) return(x)
  (top_levles = names(sort(table(x), decreasing = TRUE)[1:(target_nlevels-1)]))
  levels(x)[!(levels(x) %in% top_levles)] = "Other"
  return(x)
}

