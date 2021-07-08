# Set up -----------------------------------------------------------------------
library(tidyverse)


# Clean ------------------------------------------------------------------------
## Read data
raw_data <-
    read_csv("data/titanic.csv")

## Clean data
clean_data <-
    raw_data %>%
    rename_with(str_to_lower) %>%
    rename(
        passenger = passengerid,
        outcome = survived,
        class = pclass,
        sibling_spouse_count = sibsp,
        parent_child_count = parch,
        port = embarked
    )

clean_data <-
    clean_data %>%
    mutate(outcome =
        outcome %>%
        as_factor() %>%
        fct_recode("died" = "0", "survived" = "1") %>%
        fct_relevel("survived", "died")  # The predicted class should be the first class
    ) %>%
    mutate(class =
        class %>%
        as_factor() %>%
        fct_recode("first" = "1", "second" = "2", "third" = "3")
    ) %>%
    mutate(port =
        port %>%
        as_factor() %>%
        fct_recode("Cherbourg" = "C", "Queenstown" = "Q", "Southampton" = "S")
    )

clean_data <-
    clean_data %>%
    select(
        passenger,
        outcome,
        class,
        #name,
        sex,
        age,
        sibling_spouse_count,
        parent_child_count,
        #ticket,
        fare,
        #cabin,
        port,
    )

## Write data
write_rds(clean_data, "data/clean_titanic.rds")
