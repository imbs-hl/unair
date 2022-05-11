## Make sure your current directory is 03-dist_alternative_case
source("init.R", chdir = TRUE)

## =======================================
## Parameters setting
## =======================================
##
effect <- seq(0, 2, by = 0.3)
n_effect_repl <- 20
pnoise <- 1000
num.trees <- 15000
mtry <- floor(sqrt(pnoise))
seed <- 123 + 1:length(data_files)
n_bench <- 100
param_settings <- data.frame(data_file = rep(data_files, each = n_bench),
                             seed = 123 + 1:length(rep(data_files, each = n_bench)),
                             data_name = rep(data_names, each = n_bench),
                             stringsAsFactors = FALSE)


run_power_reg <- batchtools::loadRegistry(file = file.path(
  registry_dir,
  "power"))
power_res <- batchtools::reduceResultsList(reg = run_power_reg,
                                           ids = 1:nrow(param_settings))
power_res_DT <- rbindlist(power_res)

names(power_res_DT)[2:3] <- c("AIR", "UNAIR")

power_res_DT[, `:=`(`AIR` = mean(janitza < 0.05), 
                    `UNAIR` = mean(ujanitza < 0.05)), by = c("effect", "data")]
power_res_DT <- unique(power_res_DT, by = c("effect", "data"))
power_air_molten <- data.table::melt(data = power_res_DT,
                                     measure.vars = c("AIR", "UNAIR"),
                                     variable.name = "Measure", value.name = "Power")
levels(power_air_molten$Measure) <- c("AIR", "UNAIR")

## %%%%%%%%%%%%%%%%%%%%%%%%
## Plot results
## %%%%%%%%%%%%%%%%%%%%%%%%
tikz(file = file.path(img_dir, '03power/power.tex'),
     standAlone = TRUE,
     width = 5, height = 4.5,
     packages=c(options()$tikzLatexPackages, "\\usepackage{amsfonts}",
                "\\usepackage[T1]{fontenc}", "\\usepackage{times}"))
power_air_plot <- ggplot(data = power_air_molten,
                         aes(x = effect,
                             y = Power,
                             group = Measure, colour = Measure)) +
  geom_point() +
  geom_line(aes(colour = Measure), linetype = "dashed") +
  geom_hline(aes(yintercept = 0.05, colour = "0.05"), linetype="dashed", size = 1) +
  xlab("Effect") +
  guides(fill=guide_legend(nrow=2,byrow=TRUE)) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1),
        legend.position = "bottom",
        text = element_text(size = 15),
        axis.title.x = element_text(margin = margin(t = 20,
                                                    r = 20,
                                                    b = 0,
                                                    l = 0))) +
  facet_wrap( ~ data)
print(power_air_plot)
dev.off()

setEPS()
postscript(file = file.path(img_dir, '03power/power.eps'),
           width = 5, height = 4.5)
print(power_air_plot)
dev.off()
