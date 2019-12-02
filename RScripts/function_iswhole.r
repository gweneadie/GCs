# function check that a number is a whole number

is.whole <- function(a) { 
  (is.numeric(a) && floor(a)==a) ||
    (is.complex(a) && floor(Re(a)) == Re(a) && floor(Im(a)) == Im(a))
}
