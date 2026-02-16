# -----------------------------------------------------------------------------
# SETUP
# -----------------------------------------------------------------------------
  
# 1. Create a vector with the packages to be installed
  packages <- c(
    "dplyr",
    "ggplot2",
    "lubridate",
    "tidyverse"
  )
  
# 2. If the package is not installed, then install it
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message("!! Package '", pkg, "' not found. Installing it...")
      tryCatch(
        install.packages(pkg, dependencies = TRUE),
        error = function(e) {
          message("!! Error while trying to install the '", pkg, "' package: ", e$message)
        }
      )
    }
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }
  
# 3. Delete unnecessary vectors
  rm("pkg", "packages")

  
# -----------------------------------------------------------------------------  
# DATA IMPORT
# -----------------------------------------------------------------------------
  
# 1. Import data from .csv files
  files <- list.files(
    path = "data",
    pattern = "surgical_data_\\d{4}\\.csv",
    full.names = TRUE
  )
  
  icd9proc <- read.csv(
    "data/icd9_procedures.csv",
    header = TRUE,
    sep = ";",
    colClasses = "character"
  ) |>
  select(c("code", "long_descr", "short_descr"))

# 2. Bind data into a single dataframe
  surgeries_total <- files |>
    set_names() |>
    map_df(~read.csv(
      .x, 
      header = TRUE, 
      sep = ";", 
      na.strings = c("")
    ))
  rm("files")
  
  
# -----------------------------------------------------------------------------
# DATA TRANSFORMATION
# -----------------------------------------------------------------------------
  
# 1. Set variables classes
  surgeries_total <- surgeries_total |>
    mutate(
      date       = dmy(date),
      start_time = hms(start_time),
      end_time   = hms(end_time),
      gender     = as.factor(gender),
      dob        = dmy(dob),
      procedure  = as.character(procedure),
      role       = as.factor(role)
    )

# 2. Create new dataframes
  surgeries_stats <- surgeries_total |>
    mutate(year = year(date)) |>
    group_by(year) |>
    summarise(
      procedures = n(),
      lead = sum(role == 1, na.rm = TRUE),
      pct_lead = lead / procedures * 100,
  )
  procedures_stats <- surgeries_total |>
    mutate(year = year(date)) |>
    group_by(procedure) |>
    summarise(procedures = n()) |>
    arrange(desc(procedures)) |>
    head(15) |>
    mutate(procedure = as.character(procedure)) |>
    left_join(icd9proc, by = c("procedure" = "code")) |>
    mutate(long_descr = reorder(long_descr, procedures))
  rm("icd9proc")
  

# -----------------------------------------------------------------------------
# PLOTTING
# -----------------------------------------------------------------------------

# 1. Create plot theme
  my_plot_theme <- theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 22, hjust = 0.5, margin = margin(t = 10, b = 20)),
      axis.title = element_text(face = "bold", size = 12),
      axis.text  = element_text(face = "bold", size = 12),
      axis.line  = element_line(color = "black", size = 0.5),
      axis.ticks = element_line(color = "black")
    )  
  
# 2. Procedures per year  
  surgeries_plot <- ggplot(
      data = surgeries_stats,
      aes(x = year)
    ) +
    geom_bar(
      aes(y = procedures),
      stat = "identity",
      fill = "lightgrey",
      color = "black",
      alpha = 0.6
    ) +
    geom_text(
      aes(y = procedures, label = procedures),
      vjust = -0.5,
      fontface = "bold",
      size = 5
    ) +
    scale_x_continuous(
      name ="",
      breaks = seq(min(surgeries_stats$year), max(surgeries_stats$year), by = 1)
    ) +
    scale_y_continuous(
      name = "",
      expand = expansion(mult = c(0, 0.05))
    ) +
    labs(
      title = paste0("TOTAL PROCEDURES PER YEAR (", min(surgeries_stats$year), "-", max(surgeries_stats$year), ")")
    ) +
    my_plot_theme
  print(surgeries_plot)

# 3. % as Lead Surgeon per year  
  lead_plot <- ggplot(
    data = surgeries_stats,
    aes(x = year)
  ) +
    geom_bar(
      aes(y = pct_lead),
      stat = "identity",
      fill = "lightgrey",
      color = "black",
      alpha = 0.6
    ) +
    geom_text(
      aes(y = pct_lead, label = paste0(round(pct_lead, 0), "%")),
      vjust = -0.5,
      fontface = "bold",
      size = 5
    ) +
    scale_x_continuous(
      name ="",
      breaks = seq(min(surgeries_stats$year), max(surgeries_stats$year), by = 1)
    ) +
    scale_y_continuous(
      name = "",
      expand = expansion(mult = c(0, 0.05))
    ) +
    labs(
      title = paste0("% AS LEAD SURGEON PER YEAR (", min(surgeries_stats$year), "-", max(surgeries_stats$year), ")")
    ) +
    my_plot_theme
  print(lead_plot)
  
# 4. Main procedures 
  procedures_plot <- ggplot(
    data = procedures_stats,
    aes(x = reorder(short_descr, procedures), y = procedures)
  ) +
    geom_col(
      fill = "lightgrey",
      color = "black"
    ) +
    geom_text(
      aes(label = procedure),
      y = 0,
      hjust = -0.1,
      fontface = "bold",
      size = 4
    ) +
    geom_text(
      aes(label = procedures),
      hjust = -0.5, 
      fontface = "bold",
      size = 5
      ) +
    scale_x_discrete(
      name = ""
    ) +
    scale_y_continuous(
      name="",
      expand = expansion(mult = c(0, 0.05))
    ) +
    labs(
      title = paste("TOP",length(procedures_stats$procedure),"ICD-9 PROCEDURES"),
    ) +
    coord_flip() +
    my_plot_theme
  print(procedures_plot)
  
  
# -----------------------------------------------------------------------------
# EXPORTING
# -----------------------------------------------------------------------------
  
#1. Export data for Markdown report
  save(
    surgeries_stats,
    procedures_stats,
    file = "surgical_analysis.RData"
  )