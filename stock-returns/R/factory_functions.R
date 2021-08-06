# Define factory functions -----------------------------------------------------
## Stan ------------------------------------------------------------------------
complement_stan_mcmc <- function(
    name,
    model
) {
    name <- deparse(substitute(name))
    model <- deparse(substitute(model))

    summary <- as.symbol(str_glue("{name}_summary_{model}"))
    draws <- as.symbol(str_glue("{name}_draws_{model}"))

    name_parameter_table <- str_glue("{name}_parameter_table_{model}")
    command_parameter_table <- substitute(tidy_stan_summary(summary), env = list(summary = summary))

    name_parameter_plots <- str_glue("{name}_parameter_plots_{model}")
    command_parameter_plots <- substitute(plot_parameters(tidy_stan_draws(draws)), env = list(draws = draws))

    targets <- list(
        tar_target_raw(
            name_parameter_table,
            command_parameter_table
        ),
        tar_target_raw(
            name_parameter_plots,
            command_parameter_plots
        )
    )

    return(targets)
}
