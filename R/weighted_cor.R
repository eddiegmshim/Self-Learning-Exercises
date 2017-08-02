# calculates weighted correlation

weighted_cor <- function (x,y,weights){
  w_mean_x = sum(x*weights) / sum(weights)
  w_mean_y = sum(y*weights) / sum(weights)
  
  w_variance_x = sum(weights*(x - w_mean_x)^2) / sum(weights)
  w_variance_y = sum(weights*(y - w_mean_y)^2) / sum(weights)
  
  w_cov = sum(weights*(x - w_mean_x) * (y - w_mean_y)) / sum(weights)

  w_cor = w_cov / sqrt(w_variance_x * w_variance_y)
  
  return(w_cor)
}
