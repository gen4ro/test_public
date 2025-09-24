# settings.R
#
# Description: Shared settings for the analysis. 
# 
# History
# 2024-09-12		First release, by GAS (genshiro.sunagawa@riken.jp).
#
# This work is licensed under a Creative Commons Attribution 4.0 International License.

# output flags
output_figure <- TRUE
output_report <- TRUE

# stan settings
parallel_chains <- 4

# groups





# # visualization setup
# #####################################

# # groups
# strains <- c("STM2", "B6J", "MYS")

# # mogemoge <- factor(mogemoge, levels = strains)


# strain_colors <- c("#0571b0", "#404040", "#ca0020")
# names(strain_colors) <- strains

# torpor_groups <- c("Torpor", "No torpor", "Death")
# torpor_group_colors <- c("#1f78b4", "#b2df8a", "#a6cee3")
# names(torpor_group_colors) <- torpor_groups

# normal_torpor_colors <- c("Normal"="#33a02c", "Torpor"="#1f78b4")

# temperatures <- c("31", "34", "37")
# temperature_colors<-c("31"="#2c7bb6", "34"="#fdae61", "37"="#d7191c")

# temperatures2 <- c("37", "31")
# temperature_colors2<-c("37"="#d7191c", "31"="#2c7bb6")


# # these font and line size setting are for Cell
# et_SSS<-element_text(size = 4, family = "Arial", color = "black",
#     margin = margin(t = 0.4, b = 0.4))
# et_SS<-element_text(size = 5, family = "Arial", color = "black",
#     margin = margin(t = 0.4, b = 0.4))
# et_S<-element_text(size = 6, family = "Arial", color = "black")
# et_M<-element_text(size = 7, family = "Arial", color = "black")
# et_L<-element_text(size = 8, family = "Arial", color = "black")
# el_00<-element_line(size = 0.05)
# el_0<-element_line(size = 0.1)
# el_1<-element_line(size = 0.2)
# er_1<-element_rect(size = 0.2, fill = NA)
# tl<-unit(.2, "mm")
# ls<-0.2

# theme_base<-theme_bw()+theme(
#     text = et_M,
#     axis.ticks = el_1, 
#     axis.line = el_1,
#     panel.background = element_blank(),
#     panel.grid.major = el_0,
#     panel.grid.minor = el_00,
#     panel.border = er_1,
#     axis.title = et_M,
#     axis.text.y = et_S,
#     axis.text.x = et_S,
#     legend.title = et_M,
#     legend.text = et_S,
#     axis.ticks.length = tl,
#     plot.title = et_M,
#     plot.subtitle = et_S,
#     strip.text = et_S,
#     strip.background = element_blank(),
#     legend.key = element_blank(),
#     legend.background = element_rect(size = 0.1, colour = "black"))


# #http://colorbrewer2.org/?type=diverging&scheme=RdYlBu&n=5