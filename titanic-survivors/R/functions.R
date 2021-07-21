# Define auxiliary functions ---------------------------------------------------
pull_best_workflow <- function(
    tuned_workflows
) {
    best_workflow_id <-
        tuned_workflows %>%
        workflowsets::rank_results() %>%
        magrittr::extract2(1, "wflow_id")

    best_workflow <-
        tuned_workflows %>%
        workflowsets::pull_workflow(best_workflow_id)

    return(best_workflow)
}
