# Define auxiliary functions ---------------------------------------------------
one_first <- function(
    x
) {
    x[1] <- 1

    return(x)
}

humanize_string <- function(
    string
) {
    string %>%
        stringr::str_replace_all(r"([_\.])", r"( )") %>%
        upper_first() %>%
        return()
}

upper_first <- function(
    string
) {
    stringr::str_sub(string, 1, 1) <- stringr::str_to_upper(stringr::str_sub(string, 1, 1))

    return(string)
}
