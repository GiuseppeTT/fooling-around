# Define auxiliary functions ---------------------------------------------------
# zero_first <- function(
#     x
# ) {
#     x[1] <- 0

#     return(x)
# }

base_theme <- function(

) {
    base_theme_ <- list(
        theme_bw(18)
    )

    return(base_theme_)
}

humanize_string <- function(
    string
) {
    string %>%
        str_replace_all(r"([_\.])", r"( )") %>%
        upper_first() %>%
        return()
}

upper_first <- function(
    string
) {
    str_sub(string, 1, 1) <- str_to_upper(str_sub(string, 1, 1))

    return(string)
}
