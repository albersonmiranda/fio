# helper functions


# set colnames and rownames of a matrix or data frame
set_colnames = function(vec) {
  if (!is.null(vec)) {
    # ensure vec is a matrix or data frame
    if (!is.matrix(vec) && !is.data.frame(vec)) {
      stop("vec must be a matrix or a data frame")
    }
    # check if ncols is 1
    if (ncol(vec) != 1) {
      stop("vec must have only one column")
    }
    # if colnames are missing, set them to the name of the vector
    if (is.null(colnames(vec)) || is.na(colnames(vec))) {
      colnames(vec) <- deparse(substitute(vec))
    }
  }

  return(vec)
}

set_rownames = function(vec) {
  if (!is.null(vec)) {
    # ensure vec is a matrix or data frame
    if (!is.matrix(vec) && !is.data.frame(vec)) {
      stop("vec must be a matrix or a data frame")
    }
    # check if nrows is 1
    if (nrow(vec) > 1) {
      stop("vec must have only one row")
    }
    # if rownames are missing, set them to the name of the vector
    if (is.null(rownames(vec)) || is.na(rownames(vec))) {
      rownames(vec) <- deparse(substitute(vec))
    }
  }

  return(vec)
}
