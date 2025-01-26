library(targets)
library(tarchetypes)
library(quarto)

### LOOK AT SECTION 7.5 TO FIND HOW TO RENDER PRESENTATION

library(tidyverse)
library(ggplot2)
library(readr)
library(dplyr)
library(purrr)
library(broom)
library(forcats)
library(ggstats)
library(gridExtra)
library(HH)
library(grid)
library(cowplot)
library(lattice)

list(
  tar_target(
    dead_by_daylight,
    read_csv("Dead by Daylight Data.csv")
  ),
  
  # Killer Performance
  tar_target(
    killer_perf,
    dead_by_daylight |>
      group_by(Killer) |> 
      summarise(kill_rate = mean(4 - `# Escaped Survivors`), killer_count = n(), .groups = 'drop') %>% 
      mutate(DLC_type = c('Original DLC', 'Original DLC', 'Franchise DLC', 'Franchise DLC', 'Original DLC', 'Original DLC', 'Franchise DLC', 'Original DLC', 'Franchise DLC', 'Franchise DLC', 'Original DLC', 'Base game', 'Base game', 'Original DLC', 'Franchise DLC', 'Franchise DLC', 'Base game', 'Original DLC', 'Franchise DLC', 'Original DLC', 'Franchise DLC', 'Original DLC', 'Base game', 'Original DLC', 'Original DLC', 'Base game'))
  ),
  
  # Pick Rate Plot
  tar_target(
    pick_rate_plot,
    ggplot(killer_perf, aes(x = killer_count, y = fct_infreq(Killer, killer_count))) +
      geom_bar(aes(fill = DLC_type), stat = "identity", position = "dodge") +
      geom_text(aes(label = killer_count), hjust = 1.2, nudge_x = -0.5, size = 2.7, colour = 'white') +
      scale_fill_manual(values = c("#9C2A23", "#a37d42", '#403b36'), name = 'Type of DLC', labels = c('Base game', 'Franchise DLC', 'Original DLC')) +
      labs(title = "Killer occurences", x = "Count", y = "Killer") +
      theme(panel.background = element_rect(fill='transparent'),
            plot.background = element_rect(fill='transparent', color=NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            legend.background = element_rect(fill='transparent'),
            text = element_text(color = 'white'),
            legend.text = element_text(color = 'white'),
            axis.text = element_text(color = 'white')) +
      theme(legend.position = c(0.8, 0.8),legend.direction = "vertical",
            legend.box.background = element_rect(fill = "transparent", color = NA))
  ),
  
  # Killer Performance Plot
  tar_target(
    killer_performance_plot,
    ggplot(killer_perf, aes(x = kill_rate, y = fct_infreq(Killer, kill_rate))) +
      geom_bar(aes(fill = DLC_type), stat = "identity", position = "dodge") +
      geom_text(aes(label = round(kill_rate, 2)), hjust = 0, nudge_x = -0.35, size = 2.7, colour = 'white') +
      scale_fill_manual(values = c('#9C2A23', "#a37d42", '#403b36')) +
      guides(fill='none') +
      labs(title = "Killer performances", x = "Average of killed survivors", y = '') +
      theme(panel.background = element_rect(fill='transparent'),
            plot.background = element_rect(fill='transparent', color=NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            text = element_text(color = 'white'),
            legend.text = element_text(color = 'white'),
            axis.text = element_text(color = 'white'))
  ),
  
  # Final Combined Plot (1st plot)
  tar_target(
    combined_plot,
    plot_grid(pick_rate_plot, killer_performance_plot, ncol = 2, align = "h") +
    theme_minimal() +
      theme(
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA))
  ),
  
  # Save the combined plot as a target
  tar_target(
    combined_plot_file,
    {
      ggsave(
        filename = "combined_plot.png",
        plot = combined_plot,
        bg = "transparent",
        width = 10, # Adjust dimensions as needed
        height = 6,
        dpi = 300
      )
      "combined_plot.png" # File path
    },
    format = "file" # Tells targets to treat this as a file
  ),
  
  # Reference the saved plot in the pipeline
  tar_target(
    name = input,
    combined_plot_file,
    format = "file"
  ),
  
  
  # Killer Distribution
  tar_target(
    kills_distribution,
    dead_by_daylight |> 
      group_by(Killer, `# Escaped Survivors`) |> 
      summarise(Matches = n()) |> 
      group_by(Killer) |> 
      mutate(Percentage = (Matches / sum(Matches)) * 100) |> 
      pivot_wider(names_from = `# Escaped Survivors`, values_from = c(Matches, Percentage)) %>% 
      set_names(c("Killer", "4K_Count", "3K_Count", "2K_Count", "1K_Count", "0K_Count", "4K_Percentage", "3K_Percentage", "2K_Percentage", "1K_Percentage", "0K_Percentage"))
  ),
  
  
  # Kill Distribution Long
  tar_target(
    kills_distribution_long,
    kills_distribution |> 
      pivot_longer(cols = '4K_Count':'0K_Percentage', 
                   names_to = c("Kills", ".value"), 
                   names_sep = "_")
  ),
  
  # Kill Distribution Percent
  tar_target(
    kills_distrib_perc,
    kills_distribution |>  dplyr::select(Killer, '4K_Percentage', '3K_Percentage', '2K_Percentage', '1K_Percentage', '0K_Percentage')
  ),
  
  # Likert Plot (2nd Plot)
  tar_target(
    likert_plot_file,
    {
      likert_plot <- HH::likert(
        Killer ~ .,
        kills_distrib_perc,
        main = "Distributions of the kills per killer",
        ylab = '',
        as.percent = TRUE,
        positive.order = TRUE,
        rightAxis = FALSE,
        ########### CHANGE FONT COLOUR AND LEGEND POSITION
        trellis.par.set(list(
          background = list(col = "transparent"),  # Set background to transparent
          superpose.text = list(col = "white"),    # Set the text color to white
          axis.text = list(col = "white"),         # Set axis text color to white
          axis.line = list(col = "white"),         # Set axis line color to white
          strip.background = list(col = "transparent"),  # Set strip background to transparent
          strip.border = list(col = "transparent"), # Set strip border to transparent
          layout.heights = list(top.padding = 0),  # Remove extra space at the top
          layout.widths = list(left.padding = 0)   # Remove extra space on the left
        )),
        auto.key = list(text = c("4 kills", "3 kills", "2 kills", "1 kill", "0 kill")),
        col = c("#5e1914", "#9C2A23", "darkgray", "#2E63A1", "#243b5e")
      )
      
      # Save the plot as a PNG file
      png(
        filename = "likert_plot.png",
        bg = "transparent",
        width = 10,
        height = 6,
        units = "in",
        res = 300
      )
      grid::grid.draw(grid::grid.grabExpr(print(likert_plot)))
      dev.off()
      
      # Return the file path
      "likert_plot.png"
    },
    format = "file"
  ),
  
  # Reference the saved plot in the pipeline
  tar_target(
    name = input_2,
    likert_plot_file,
    format = "file"
  ),
  
  
  # Correlation Data
  tar_target(
    cor_data,
    dead_by_daylight |>
      group_by(Killer, Map) |>
      summarise(Correlation = cor(`# Finished generators`, `# Escaped Survivors`, method = "spearman"), .groups = 'drop') |> 
      complete(Map, Killer, fill = list(Correlation = NA)) # we choose spearman's correlation factor, as it more suited for ordinal data
  ),
  
  # Heatmap (3rd plot)
  tar_target(
    cor_data_plot,
    ggplot(cor_data, aes(x = Map, y = Killer)) +
      geom_tile(aes(fill = Correlation)) +
      theme(axis.text.x=element_text(angle = 90, hjust = 0)) +
      scale_fill_gradient2(low = "#9C2A23", mid = "white", high = "#2E63A1", midpoint = 0, na.value = '#6D6D6D') +
      labs(x = "Map",
           y = "Killer",
           title = "Correlation between the escape rate and the repair rate\nper killer and per map") +
      guides(fill = guide_colorbar(title = "Correlation",
                                   barwidth = 1,
                                   barheight = 8,
                                   title.position = "top",
                                   title.hjust = 0.5)) +
      theme(panel.background = element_rect(fill='transparent'),
            plot.background = element_rect(fill='transparent', color=NA),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            legend.background = element_rect(fill='transparent'),
            text = element_text(color = 'white'),
            legend.text = element_text(color = 'white'),
            axis.text = element_text(color = 'white'))
  ),
  
  # Save the combined plot as a target
  tar_target(
    heatmap_file,
    {
      ggsave(
        filename = "heatmap.png",
        plot = cor_data_plot,
        bg = "transparent"
      )
      "heatmap.png" # File path
    },
    format = "file" # Tells targets to treat this as a file
  ),
  
  # Reference the saved plot in the pipeline
  tar_target(
    name = input_3,
    heatmap_file,
    format = "file"
  ),
  
  
  tar_quarto(
    death_is_not_an_escape,
    path = "Death_is_not_an_escape.qmd"
  )
  
)
