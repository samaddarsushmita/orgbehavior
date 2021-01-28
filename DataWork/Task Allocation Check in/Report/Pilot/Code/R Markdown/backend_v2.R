#------------------------------------------------------------------------------#
#                                                                              #
#                                     DIME                                     #
#                        Report for Time Use of WB Staff                       #                                     
#                                 Markdown                                      #                           
#                                                                              #
#------------------------------------------------------------------------------#
# PURPOSE:    Individualized Report for the WB Staff
# NOTES:      
# TO CHANGE CASES ====
#             1.  GO TO Importing Data Section and Change Number

# WRITTEN BY: Sushmita Samaddar
# 
rm(list = ls())
rm(list = ls(all.names = TRUE))

# PART 1: Select sections to run ----------------------------------------------
PACKAGES             <- 1

# PART 2: Load packages   -----------------------------------------------------
packages  <- c("readstata13", "foreign",
               "doBy", "broom", "dplyr",
               "stargazer", "htmltools",
               "ggplot2", "plotly", "ggrepel",
               "RColorBrewer", "RCurl", "XML",
               "sp", "rgdal", "rgeos",
               "ggmap", "leaflet",
               "htmlwidgets", "geosphere",
               "eeptools", "purrr", "ggforce",
               "formattable", "tidyr", 
               "manipulate", "data.table", 
               "tm", "SnowballC", "wordcloud", 
               "webshot", "stringr", "devtools",
               "ggrepel")

# If you selected the option to install packages, install them
if (PACKAGES) {
  
  # Install packages that are not yet installed
  sapply(packages, function(x) {
    if (!(x %in% installed.packages())) {
      install.packages(x, dependencies = TRUE) 
    }
  }
  )
}
# Load all packages -- this is equivalent to using library(package) for each 
# package listed before

invisible(sapply(packages, library, character.only = TRUE))

# PART 3: Set folder folder paths --------------------------------------------
#-------------#
# Root folder #
#-------------#

# Add your username and folder path here (for Windows computers)
# To find out what your username is, type Sys.getenv("USERNAME")
if (Sys.getenv("USERNAME") == "wb522556") {
  
  projectFolder  <- "C:/Users/wb522556/WBG/Vincenzo Di Maro - Agile/06 - Agile Productivity Radar/DataWork/Task Allocation Check in/Report"
  gitHub         <- "C:/Users/wb522556/Documents/GitHub/Agile_Productivity_Radar/DataWork/Task Allocation Check in/Report/Pilot/Code/R Markdown"
}

#--------------------#
# Project subfolders #
#--------------------#
pilotFolder       <- file.path(projectFolder,"Pilot")
Data              <- file.path(pilotFolder,"Datasets")
Intermediate      <- file.path(Data,"Intermediate")
outputFolder      <- file.path(pilotFolder, "Outputs")
outputRaw         <- file.path(outputFolder, "Raw")
outputFinal       <- file.path(outputFolder, "Final")

#CHANGE CASE - CHECK NON-RESPONDENTS#------------------
cases <- 12
for (case in 4:cases){
  
#--------------------#
# Importing Data #----------------------------------
#--------------------#

TUD <- read.dta13(file.path(Intermediate, "tud_v3.dta"),
                  convert.dates            = TRUE, 
                  convert.factors          = TRUE, 
                  missing.type             = TRUE, 
                  convert.underscore       = TRUE,
                  generate.factors         = TRUE,
                  nonint.factors           = TRUE)
TUD       <- TUD %>% mutate_if(is.numeric, ~round(., 2))
TUD %>% distinct()

TUD_unimp <- read.dta13(file.path(Intermediate, "tud_v3_unimp.dta"),
                        convert.dates            = TRUE, 
                        convert.factors          = TRUE, 
                        missing.type             = TRUE, 
                        convert.underscore       = TRUE,
                        generate.factors         = TRUE,
                        nonint.factors           = TRUE)
TUD_unimp       <- TUD_unimp %>% mutate_if(is.numeric, ~round(., 2))
TUD_unimp %>% distinct()

TUD_imp <- read.dta13(file.path(Intermediate, "tud_v3_imp.dta"), 
                      convert.dates            = TRUE, 
                      convert.factors          = TRUE, 
                      missing.type             = TRUE, 
                      convert.underscore       = TRUE,
                      generate.factors         = TRUE,
                      nonint.factors           = TRUE)
TUD_imp       <- TUD_imp %>% mutate_if(is.numeric, ~round(., 2))
TUD_imp %>% distinct()

type_unimp <- read.dta13(file.path(Intermediate, "tud_v4_type_unimp.dta"), 
                         convert.dates            = TRUE, 
                         convert.factors          = TRUE, 
                         missing.type             = TRUE, 
                         convert.underscore       = TRUE,
                         generate.factors         = TRUE,
                         nonint.factors           = TRUE)
type_unimp       <- type_unimp %>% mutate_if(is.numeric, ~round(., 2))
type_unimp %>% distinct()

type_imp <- read.dta13(file.path(Intermediate, "tud_v4_type_imp.dta"), 
                       convert.dates            = TRUE, 
                       convert.factors          = TRUE, 
                       missing.type             = TRUE, 
                       convert.underscore       = TRUE,
                       generate.factors         = TRUE,
                       nonint.factors           = TRUE)
type_imp       <- type_imp %>% mutate_if(is.numeric, ~round(., 2))
type_imp %>% distinct()

timetrend <- read.dta13(file.path(Intermediate, "timetrend.dta"), 
                        convert.dates            = TRUE, 
                        convert.factors          = TRUE, 
                        missing.type             = TRUE, 
                        convert.underscore       = TRUE,
                        generate.factors         = TRUE,
                        nonint.factors           = TRUE)
timetrend       <- timetrend %>% mutate_if(is.numeric, ~round(., 2))
timetrend %>% distinct()

df_admin <- read.dta13(file.path(Intermediate, "df_admin_activity.dta"), 
                       convert.dates            = TRUE, 
                       convert.factors          = TRUE, 
                       missing.type             = TRUE, 
                       convert.underscore       = TRUE,
                       generate.factors         = TRUE,
                       nonint.factors           = TRUE)
df_admin       <- df_admin %>% mutate_if(is.numeric, ~round(., 2))
df_admin %>% distinct()

df_proj <- read.dta13(file.path(Intermediate, "df_category_project.dta"), 
                      convert.dates            = TRUE, 
                      convert.factors          = TRUE, 
                      missing.type             = TRUE, 
                      convert.underscore       = TRUE,
                      generate.factors         = TRUE,
                      nonint.factors           = TRUE)
df_proj       <- df_proj %>% mutate_if(is.numeric, ~round(., 2))
df_proj %>% distinct()

df_imp <- read.dta13(file.path(Intermediate, "df_importance.dta"), 
                     convert.dates            = TRUE, 
                     convert.factors          = TRUE, 
                     missing.type             = TRUE, 
                     convert.underscore       = TRUE,
                     generate.factors         = TRUE,
                     nonint.factors           = TRUE)
df_imp       <- df_imp %>% mutate_if(is.numeric, ~round(., 2))
df_imp %>% distinct()

df_planned <- read.dta13(file.path(Intermediate, "df_planned.dta"), 
                         convert.dates            = TRUE, 
                         convert.factors          = TRUE, 
                         missing.type             = TRUE, 
                         convert.underscore       = TRUE,
                         generate.factors         = TRUE,
                         nonint.factors           = TRUE)
df_planned       <- df_planned %>% mutate_if(is.numeric, ~round(., 2))
df_planned %>% distinct()

df_withsomeone <- read.dta13(file.path(Intermediate, "df_withsomeone.dta"), 
                             convert.dates            = TRUE, 
                             convert.factors          = TRUE, 
                             missing.type             = TRUE, 
                             convert.underscore       = TRUE,
                             generate.factors         = TRUE,
                             nonint.factors           = TRUE)
df_withsomeone       <- df_withsomeone %>% mutate_if(is.numeric, ~round(., 2))
df_withsomeone %>% distinct()

tud_type <- read.dta13(file.path(Intermediate, paste0("tud_v3_type", case, "_trunc.dta")), 
                       convert.dates            = TRUE, 
                       convert.factors          = TRUE, 
                       missing.type             = TRUE, 
                       convert.underscore       = TRUE,
                       generate.factors         = TRUE,
                       nonint.factors           = TRUE)
tud_type       <- tud_type %>% mutate_if(is.numeric, ~round(., 2))
tud_type %>% distinct()

df_act <- read.dta13(file.path(Intermediate, "df_act.dta"), 
                     convert.dates            = TRUE, 
                     convert.factors          = TRUE, 
                     missing.type             = TRUE, 
                     convert.underscore       = TRUE,
                     generate.factors         = TRUE,
                     nonint.factors           = TRUE)
df_act      <- df_act %>% mutate_if(is.numeric, ~round(., 2))
df_act %>% distinct()


#GENERATING SUBSETS FOR DATA------

tud <- subset(TUD, caseid == case |
                caseid == 100)

nr_days <- as.numeric(unique(max(subset(TUD, caseid == case,
                                        select = c(nr.days)))))

tud_imp <- subset(TUD_imp, caseid == case |
                    caseid == 100)

tud_unimp <- subset(TUD_unimp, caseid == case |
                      caseid == 100)

type_unimp <- subset(type_unimp, caseid == case |
                       caseid == 100, 
                     select = c(caseid,
                                casenme,
                                type, 
                                type.cpr,
                                hh.actctype,
                                hh.actctypeday))
type_unimp %>% distinct()

type_imp <- subset(type_imp, caseid == case |
                     caseid == 100, 
                   select = c(caseid,
                              casenme,
                              type, 
                              type.cpr,
                              hh.actctype,
                              hh.actctypeday))
timetrend <- subset(timetrend, caseid == case)

df_admin <- subset(df_admin, caseid == case, 
                   select = c(instancecadmin.activity,
                              instanceadmin.activity,
                              freq.cinstanceadmin.activity, 
                              freq.instanceadmin.activity,                              
                              hh.actcadmin.activity,
                              hh.actadmin.activity,
                              avg.hhcadmin.activity, 		
                              avg.hhadmin.activity, 			
                              admin.activity.cpr,
                              admin.activity.pr,
                              admin.activity,
                              caseid,
                              casenme))

df_proj <- subset(df_proj, caseid == case, 
                  select = c(instanceccategory.project,
                             instancecategory.project,
                             freq.cinstancecategory.project, 
                             freq.instancecategory.project, 
                             hh.actccategory.project,
                             hh.actcategory.project,
                             avg.hhccategory.project, 		
                             avg.hhcategory.project, 		
                             category.project.cpr,
                             category.project.pr,
                             category.project,
                             caseid,
                             casenme))

df_imp <- subset(df_imp, caseid == case, 
                 select = c(instancecimportance,
                            instanceimportance,
                            freq.cinstanceimportance, 
                            freq.instanceimportance, 
                            hh.actcimportance,
                            hh.actimportance,
                            avg.hhcimportance, 	
                            avg.hhimportance, 
                            importance.cpr,
                            importance.pr,
                            importance,
                            caseid,
                            casenme))

df_planned <- subset(df_planned, caseid == case, 
                     select = c(instancecplanned,
                                instanceplanned,
                                freq.cinstanceplanned, 
                                freq.instanceplanned, 
                                hh.actcplanned,
                                hh.actplanned,
                                avg.hhcplanned, 
                                avg.hhplanned, 
                                planned.cpr,
                                planned.pr,
                                planned,
                                caseid,
                                casenme))

df_withsomeone <- subset(df_withsomeone, caseid == case, 
                         select = c(instancecwithsomeone,
                                    instancewithsomeone,
                                    freq.cinstancewithsomeone, 
                                    freq.instancewithsomeone, 
                                    hh.actcwithsomeone,
                                    hh.actwithsomeone,
                                    avg.hhcwithsomeone, 	
                                    avg.hhwithsomeone, 	
                                    withsomeone.cpr,
                                    withsomeone.pr,
                                    withsomeone,
                                    caseid,
                                    casenme))

df_act <- subset(df_act, caseid == case, 
                 select = c(caseid, 
                            activity.descr, 
                            withsomeone, 
                            category.project, 
                            admin.activity, 
                            importance, 
                            activity.duration))

#SAVING ELEMENTS FOR REPORT-----------

casename <- subset(tud, caseid == case,
                   select = c(casenme))
casename <-  as.character(casename %>% distinct())

startdate <- subset(tud, caseid == case,
                    select = c(start.date))
startdate <- format(startdate, "%m-%d-%Y")

startdate <-  as.character(startdate %>% distinct())

enddate <- subset(tud, caseid == case,
                  select = c(end.date))
enddate <- format(enddate, "%m-%d-%Y")

enddate <-  as.character(enddate %>% distinct())

nr_weeks <- subset(tud, caseid == case,
                   select = c(nr.weeks))
nr_weeks <-  as.numeric(nr_weeks %>% distinct())

#--------------------#
# PART 5: PAGE 2 #--------------------------------------------
#--------------------#
#--------------------#
# PROJECT CATEGORY #--------------------------------------------
#--------------------#
cat_proj <- subset(tud, is.na(category.project) == FALSE |
                     is.na(category.project.cpr) == FALSE,
                   select = c(category.project.cpr,
                              caseid,
                              category.project,
                              hh.actccategory.project,
                              totalctime,
                              casenme))
cat_proj <- setDT(cat_proj)
setkey(cat_proj, category.project)

#Bar Graph------
cat_proj_plot <- ggplot(cat_proj, aes(factor(category.project),
                                      category.project.cpr,
                                      fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=category.project.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge(width = 0.9))+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face="bold"),
        axis.text.y = element_text(size = 20, face="bold")) +
  labs(fill = "")
ylim(-1, 100)

cat_proj_plot

pdf(file.path(outputRaw, "cat_proj_plot.pdf"), width = 10) 
plot(cat_proj_plot)
dev.off()

#For Bar Graph Text-------
cat_proj_perc <- as.numeric(unique(max((subset(cat_proj,
                                               caseid != 100,
                                               select = c(category.project.cpr))))))
cat_proj_nme <- cat_proj %>%
  filter(caseid != 100 & category.project.cpr == cat_proj_perc) %>%
  select(category.project)
cat_proj_nme <- unique(cat_proj_nme) %>%
  unlist %>%
  paste(collapse = ", ")

cat_proj_chh <-  as.numeric(unique(subset(cat_proj, 
                                          category.project.cpr == cat_proj_perc &
                                            caseid         !=  100,
                                          select = c(hh.actccategory.project)))) 
cat_proj_chh <- cat_proj_chh/nr_weeks
cat_proj_chh <-  round(cat_proj_chh)
cat_proj_perc <- round(cat_proj_perc)

#--------------------#
# MEETINGS #--------------------------------------------
#--------------------#
withsomeone <- subset(tud, is.na(withsomeone) == FALSE |
                        is.na(withsomeone.cpr) == FALSE,
                      select = c(withsomeone.cpr,
                                 caseid,
                                 withsomeone,
                                 hh.actcwithsomeone,
                                 totalctime,
                                 casenme))
withsomeone <- setDT(withsomeone)

setkey(withsomeone, withsomeone)

#Bar Graph------
withsomeone_plot <- ggplot(withsomeone, aes(factor(withsomeone),
                                            withsomeone.cpr,
                                            fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=withsomeone.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge (width = 0.9))+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face="bold"),
        axis.text.y = element_text(size = 20, face="bold")) +
  labs(fill = "")
ylim(-1, 100)

withsomeone_plot

pdf(file.path(outputRaw, "withsomeone_plot.pdf"), width = 8) 
plot(withsomeone_plot)
dev.off()

#For Bar Graph Text-------
withsomeone_perc <- as.numeric(unique(max((subset(withsomeone,
                                                  caseid != 100,
                                                  select = c(withsomeone.cpr)))))) 
withsomeone_nme <- withsomeone %>%
  filter(caseid != 100 & withsomeone.cpr == withsomeone_perc) %>%
  select(withsomeone)
withsomeone_nme <- unique(withsomeone_nme) %>%
  unlist %>%
  paste(collapse = ", ")

withsomeone_chh <-  as.numeric(unique(subset(withsomeone, 
                                             withsomeone.cpr == withsomeone_perc &
                                               caseid         !=  100,
                                             select = c(hh.actcwithsomeone))))

withsomeone_chh <- withsomeone_chh/nr_weeks
withsomeone_chh <-  round(withsomeone_chh)
withsomeone_perc <-  round(withsomeone_perc)

#--------------------#
# COMBINED #--------------------------------------------
#--------------------#
combined <- subset(tud, is.na(combined.categories) == FALSE &
                     is.na(combined.categories.cpr) == FALSE &
                     combined.categories.cpr >= 5,
                   select = c(combined.categories.cpr,
                              caseid,
                              combined.categories,
                              hh.actccombined.categories,
                              totalctime,
                              casenme))
combined <- setDT(combined)
setkey(combined, combined.categories)

#Bar Graph------
combined_plot <- ggplot(combined, aes(factor(combined.categories),
                                      combined.categories.cpr,
                                      fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=combined.categories.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge(width = 0.9))+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face="bold"),
        axis.text.y = element_text(size = 20, face="bold")) +
  labs(fill = "")
ylim(-1, 100)

combined_plot <- combined_plot + 
  aes(stringr::str_wrap(combined.categories, width = 1, indent = 0, exdent = 0), 
      combined.categories.cpr) + 
  xlab("") +
  ylab("Proportion (in %)")

combined_plot

pdf(file.path(outputRaw, "combined_plot.pdf"), width = 12) 
plot(combined_plot)
dev.off()

#For Bar Graph Text-------
combined_perc <- as.numeric(unique(max((subset(combined,
                                               caseid != 100,
                                               select = c(combined.categories.cpr))))))
combined_nme <- combined %>%
  filter(caseid != 100 & combined.categories.cpr == combined_perc) %>%
  select(combined.categories)
combined_nme <- unique(combined_nme) %>%
  unlist %>%
  paste(collapse = ", ")

combined_chh <-  as.numeric(unique(subset(combined, 
                                          combined.categories.cpr == combined_perc &
                                            caseid         !=  100,
                                          select = c(hh.actccombined.categories)))) 
combined_chh <- combined_chh/nr_weeks
combined_chh <-  round(combined_chh)
combined_perc <- round(combined_perc)

#--------------------#
# ADMIN ACTIVITY #--------------------------------------------
#--------------------#

admin_act <- subset(tud, is.na(admin.activity) == FALSE &
                      is.na(admin.activity.cpr) == FALSE,
                    select = c(admin.activity.cpr,
                               caseid,
                               admin.activity,
                               hh.actcadmin.activity,
                               totalctime,
                               casenme))
admin_act <- setDT(admin_act)

#Bar Graph-----
admin_act_plot <- ggplot(admin_act, aes(factor(admin.activity),
                                        admin.activity.cpr,
                                        fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=admin.activity.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge (width = 0.9))+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face="bold"),
        axis.text.y = element_text(size = 20, face="bold")) +
  labs(fill = "")
ylim(-1, 100)

admin_act_plot

pdf(file.path(outputRaw, "admin_act_plot.pdf"), width = 10) 
plot(admin_act_plot)
dev.off()

#For Bar Graph Text------
admin_act_perc <- as.numeric(unique(max((subset(admin_act,
                                                caseid != 100,
                                                select = c(admin.activity.cpr))))))
admin_act_nme <- admin_act %>%
  filter(caseid != 100 & admin.activity.cpr == admin_act_perc) %>%
  select(admin.activity)
admin_act_nme <- unique(admin_act_nme) %>%
  unlist %>%
  paste(collapse = ", ")

admin_act_chh <-  as.numeric(unique(subset(admin_act, 
                                           admin.activity.cpr == admin_act_perc &
                                             caseid         !=  100,
                                           select = c(hh.actcadmin.activity))))
admin_act_chh <- admin_act_chh/nr_weeks
admin_act_chh <-  round(admin_act_chh)
admin_act_perc <- round(admin_act_perc)
#--------------------#
# FOR PLANNED #--------------------------------------------
#--------------------#
planned_act <- subset(tud, is.na(planned) == FALSE &
                        is.na(planned.cpr) == FALSE,
                      select = c(planned.cpr,
                                 caseid,
                                 planned,
                                 hh.actcplanned, 
                                 totalctime,
                                 casenme))
planned_act <- setDT(planned_act)

#Bar Graph--------
planned_act_plot <- ggplot(planned_act, aes(factor(planned),
                                            planned.cpr,
                                            fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=planned.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge (width = 0.9))+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face="bold"),
        axis.text.y = element_text(size = 20, face="bold")) +
  labs(fill = "")
ylim(-1, 100)

planned_act_plot

pdf(file.path(outputRaw, "planned_act_plot.pdf"), width = 10) 
plot(planned_act_plot)
dev.off()

#For Bar Graph Text-------
planned_act_perc <- as.numeric(unique(max((subset(planned_act,
                                                  caseid != 100,
                                                  select = c(planned.cpr))))))

planned_act_nme <- planned_act %>%
  filter(caseid != 100 & planned.cpr == planned_act_perc) %>%
  select(planned)
planned_act_nme <- unique(planned_act_nme) %>%
  unlist %>%
  paste(collapse = ", ")

planned_act_chh <-  as.numeric(unique(subset(planned_act, 
                                             planned.cpr == planned_act_perc &
                                               caseid         !=  100,
                                             select = c(hh.actcplanned))))
planned_act_chh <- planned_act_chh/nr_weeks
planned_act_chh <- round(planned_act_chh)
planned_act_perc <-  round(planned_act_perc)

#--------------------#
# IMPORTANCE #--------------------------------------------
#--------------------#

#Bar Graph------

imp_act <- subset(tud, is.na(importance) == FALSE &
                    is.na(importance.cpr) == FALSE,
                  select = c(importance.cpr,
                             caseid,
                             importance,
                             hh.actcimportance, 
                             totalctime,
                             casenme))
imp_act <- setDT(imp_act)

imp_act_plot <- ggplot(imp_act, aes(factor(importance),
                                    importance.cpr,
                                    fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=importance.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge (width = 0.9),)+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face="bold"),
        axis.text.y = element_text(size = 20, face="bold")) +
  labs(fill = "")
ylim(-1, 100)

imp_act_plot <- imp_act_plot + 
  aes(stringr::str_wrap(importance, 5), 
      importance.cpr) + 
  xlab("") +
  ylab("Proportion (in %)")

imp_act_plot

pdf(file.path(outputRaw, "imp_act_plot.pdf"), width = 12) 
plot(imp_act_plot)
dev.off()

#--------------------#
# FOR IMPORTANCE- SHORT #--------------------------------------------
#--------------------#
imp_act_s <- subset(tud, is.na(imp.act) == FALSE &
                      is.na(imp.act.cpr) == FALSE,
                    select = c(imp.act.cpr,
                               caseid,
                               imp.act,
                               hh.actcimp.act, 
                               totalctime,
                               casenme))
imp_act_s <- setDT(imp_act_s)

#Bar Graph-----

imp_act_s_plot <- ggplot(imp_act_s, aes(factor(imp.act),
                                        imp.act.cpr,
                                        fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=imp.act.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge (width = 0.9))+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face = "bold"),
        axis.text.y = element_text(size = 20, face = "bold")) +
  labs(fill = "")
ylim(-1, 100)

imp_act_s_plot

pdf(file.path(outputRaw, "imp_act_s_plot.pdf"), width = 8) 
plot(imp_act_s_plot)
dev.off()

#For Bar Graph Text-------
imp_act_s_perc <- as.numeric(unique(max((subset(imp_act_s,
                                                caseid != 100,
                                                select = c(imp.act.cpr))))))
imp_act_s_nme <- imp_act_s %>%
  filter(caseid != 100 & imp.act.cpr == imp_act_s_perc) %>%
  select(imp.act)
imp_act_s_nme <- unique(imp_act_s_nme) %>%
  unlist %>%
  paste(collapse = ", ")

imp_act_s_chh <-  as.numeric(unique(subset(imp_act_s, 
                                           imp.act.cpr == imp_act_s_perc &
                                             caseid         !=  100,
                                           select = c(hh.actcimp.act))))
imp_act_s_chh <- imp_act_s_chh/nr_weeks

imp_act_s_chh <-  round(imp_act_s_chh)
imp_act_s_perc <-  round(imp_act_s_perc)

if (imp_act_s_perc==100 & imp_act_s_nme == "Important") {
  imp_check <- 1 
} else {
  imp_check <- 0
}
if (imp_act_s_perc==100 & imp_act_s_nme == "Unimportant") {
  unimp_check <- 1 
} else {
  unimp_check <- 0
}

#--------------------#
# FOR TYPE OF ACTIVITY#--------------------------------------------
#--------------------#
type_act <- setDT(tud_type)

type_act <- subset(type_act,
                   type != "Meetings" &
                     type != "Independent work",
                   select = c(caseid,
                              type.cpr,
                              casenme,
                              nr.days,
                              nr.daysall,
                              type,
                              hh.actctype,
                              hh.actctypeday))
type_act       <- type_act %>% mutate_if(is.numeric, ~round(.))

#Bar Graph-----
type_act_plot <- ggplot(type_act, aes(factor(type),
                                      type.cpr,
                                      fill = casenme)) +
  geom_bar(position = position_dodge (width = 0.9),
           stat = "identity") +
  scale_fill_manual(values = c("steelblue1", "midnightblue")) +
  geom_text(aes(label=type.cpr),
            vjust=1.5, 
            color="white", 
            fontface="bold",
            size=8,
            position = position_dodge (width = 0.9))+
  ggtitle("") +
  xlab("") + ylab("Proportion (in %)") +
  theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
        axis.title.y = element_text(color="navy", size=20, face="bold"),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position="bottom",
        legend.text=element_text(size=20),
        axis.text.x = element_text(size = 20, face = "bold"),
        axis.text.y = element_text(size = 20, face = "bold")) +
  labs(fill = "")
ylim(-1, 100)

type_act_plot <- type_act_plot + 
  aes(stringr::str_wrap(type, width = 1, indent = 0, exdent = 0), 
      type.cpr) + 
  xlab("") +
  ylab("Proportion (in %)")

type_act_plot

pdf(file.path(outputRaw, "type_act_plot.pdf"), width = 12) 
plot(type_act_plot)
dev.off()


#For Bar Graph Text-------
type_act <- setDT(tud_type)

type_act <- subset(type_act,
                   type != "Meetings" &
                     type != "Independent work",
                   select = c(caseid,
                              type.cpr,
                              casenme,
                              nr.days,
                              nr.daysall,
                              type,
                              hh.actctype,
                              hh.actctypeday))
type_act_perc <- as.numeric(unique(max(subset(type_act, 
                                              caseid != 100,
                                              select = c(type.cpr)))))

type_act_chh <-  as.numeric(unique(subset(type_act,
                                          caseid         !=  100 &
                                            type.cpr == type_act_perc,
                                          select = c(hh.actctype))))

type_act_chh <- type_act_chh/nr_weeks  
type_act_nme <- type_act %>%
  filter(caseid != 100 & type.cpr == type_act_perc) %>%
  select(type)
type_act_nme <- unique(type_act_nme) %>%
  unlist %>%
  paste(collapse = ", ")

type_act_chh <- round(type_act_chh)
type_act_perc <- round(type_act_perc)

#--------------------#
# PART 5: PAGE 3 #--------------------------------------------

#### DUMMY PLOT###------
x <- data.frame("SN" = 1:2, "No.Data" = c(0,0), "No_Data" = c("",""))
x <- ggplot(x)+
  theme_void() 
plot(x)
#--------------------#
# UNIMPORTANT: FOR TYPE OF ACTIVITY#-----------------------------------------
#--------------------#
if (imp_check == 1) {
  pdf(file.path(outputRaw, "type1_plot.pdf")) 
  plot(x)
  dev.off()
  type_pie1_p <- 0
  type_pie1_n <- "Any Activity"
} else {
  type1 <- subset(type_unimp, is.na(type) == FALSE &
                    caseid != 100 &
                    type != "Meetings" &
                    type != "Independent work",
                  select = c(type.cpr,
                             caseid,
                             type,
                             hh.actctype,
                             hh.actctypeday,
                             casenme))
  
  type1 <- type1 %>% distinct()
  
  type1 <- setDT(type1)
  setkey(type1, type)
  
  type1       <- type1 %>% mutate_if(is.numeric, ~round(.))
  
  #Bar Graph-----
  type1_plot <- ggplot(type1, aes(factor(type),
                                  type.cpr,
                                  fill = casenme)) +
    geom_bar(position = position_dodge (width = -0.1),
             width = 0.6,
             stat = "identity") +
    coord_flip() +
    scale_fill_manual(values = c("blueviolet")) +
    geom_text(aes(label=type.cpr),
              hjust=1.5, 
              color="white", 
              fontface="bold",
              size=8,
              position = position_dodge (width = 0.9))+
    ggtitle("") +
    xlab("") + ylab("Proportion (in %)") +
    theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
          axis.title.y = element_text(color="navy", size=20, face="bold"),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black"),
          legend.position = "none",
          axis.text.x = element_text(size = 20, face = "bold"),
          axis.text.y = element_text(size = 20, face = "bold")) +
    labs(fill = "")
  ylim(-1, 100)
  
  type1_plot
  
  pdf(file.path(outputRaw, "type1_plot.pdf"), width = 11, height = 8) 
  
  plot(type1_plot)
  dev.off()
  
  #Pie Chart------
  type1 <- subset(type_unimp, is.na(type) == FALSE &
                    caseid != 100 &
                    type != "Meetings" &
                    type != "Independent work",
                  select = c(type.cpr,
                             caseid,
                             type,
                             hh.actctype,
                             hh.actctypeday,
                             casenme))
  
  type1 <- type1 %>% distinct()
  
  type1 <- setDT(type1)
  setkey(type1, type)
  type1 <- type1[order(-type.cpr),]
  type1 <- type1[!duplicated(type1$type), ]
  
  type1$cumsum <- cumsum(type1$type.cpr)
  
  type1_pie <- subset(type1, cumsum <= 99.99,
                      select = c(type.cpr,
                                 caseid,
                                 type,
                                 casenme,
                                 cumsum))
  
  type1cpr <- type1_pie$type.cpr
  typetcpr <- 100 - sum(type1cpr)
  
  type1_pie <- type1_pie %>% add_row(type.cpr = typetcpr, 
                                     caseid = case,
                                     type = "Other",
                                     casenme = casename,
                                     cumsum = "100")
  
  type1_pie <- type1_pie %>% 
    mutate(end = 2 * pi * cumsum(type.cpr)/sum(type.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  type_pie1 <- ggplot(type1_pie) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = type)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = type.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30))+
    scale_fill_brewer(palette = "BuPu", direction = -1) +
    guides(fill=guide_legend(nrow=5, byrow=TRUE)) +
    labs(fill = "")
  
  type_pie1
  
  pdf(file.path(outputRaw, "type_pie1.pdf")) 
  plot(type_pie1)
  dev.off()
  
  #Text for Pie Chart-----
  type1cprmax <- max(type1$type.cpr)
  
  type_pie1_p <- as.numeric(unique(subset(type1, 
                                          type.cpr == type1cprmax,
                                          select = c(type.cpr))))
  type_pie1_hh <- as.numeric(unique(subset(type1, 
                                           type.cpr == type1cprmax,
                                           select = c(hh.actctype))))
  type_pie1_hh <- type_pie1_hh/nr_weeks
  
  type_pie1_n <- type1 %>%
    filter(type.cpr == type1cprmax) %>%
    select(type) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  type_pie1_p <-  round(type_pie1_p)
  type_pie1_hh <-  round(type_pie1_hh)
}
#--------------------#
# UNIMPORTANT: FOR PROJECT CATEGORY #-----------------------------------------
#--------------------#
if (imp_check == 1) {
  pdf(file.path(outputRaw, "cat_proj_pie1.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  cat_proj1_p <- 0
  cat_proj1_n <- "Any"
} else {
  cat_proj1 <- subset(tud_unimp, is.na(category.project) == FALSE &
                        caseid != 100,
                      select = c(category.project.cpr,
                                 caseid,
                                 category.project,
                                 hh.actccategory.project,
                                 totalctime,
                                 casenme))
  
  cat_proj1 <- cat_proj1 %>% distinct()
  
  cat_proj1 <- setDT(cat_proj1)
  setkey(cat_proj1, category.project)
  
  #Pie Chart------
  cat_proj1 <- cat_proj1 %>% 
    mutate(end = 2 * pi * cumsum(category.project.cpr)/sum(category.project.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  cat_proj_pie1 <- ggplot(cat_proj1) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = category.project)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = category.project.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Analytical" = "steelblue1",
                                 "Lending"    = "gray90",
                                 "Other"      = "gray50")) +
    guides(fill=guide_legend(nrow=3, byrow=TRUE)) +
    labs(fill = "")
  
  cat_proj_pie1
  
  pdf(file.path(outputRaw, "cat_proj_pie1.pdf")) 
  plot(cat_proj_pie1)
  dev.off()
  
  #Text for Pie Chart-----
  cat_proj1cprmax <- max(cat_proj1$category.project.cpr)
  
  cat_proj1_p <- as.numeric(unique((subset(cat_proj1, 
                                           category.project.cpr == cat_proj1cprmax,
                                           select = c(category.project.cpr)))))
  
  cat_proj1_n <- cat_proj1 %>%
    filter(category.project.cpr == cat_proj1cprmax) %>%
    select(category.project) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  cat_proj1_p <- round(cat_proj1_p)
}
#--------------------#
# UNIMPORTANT: FOR MEETINGS #-----------------------------------------
#--------------------#
if (imp_check == 1) {
  pdf(file.path(outputRaw, "withsomeone_pie1.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  withsomeone1_p <- 0
  withsomeone1_n <- "Any Activity"
} else {
  withsomeone1 <- subset(tud_unimp, is.na(withsomeone) == FALSE &
                           caseid !=100,
                         select = c(withsomeone.cpr,
                                    caseid,
                                    withsomeone,
                                    hh.actcwithsomeone,
                                    totalctime,
                                    casenme))
  
  withsomeone1 <- withsomeone1 %>% distinct()
  
  withsomeone1 <- setDT(withsomeone1)
  setkey(withsomeone1, withsomeone)
  
  #Pie chart------
  withsomeone1 <- withsomeone1 %>% 
    mutate(end = 2 * pi * cumsum(withsomeone.cpr)/sum(withsomeone.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  withsomeone_pie1 <- ggplot(withsomeone1) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = withsomeone)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = withsomeone.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Meetings" = "steelblue1",
                                 "Independent work"    = "gray90")) +
    guides(fill=guide_legend(nrow=2 ,byrow=TRUE)) +
    labs(fill = "")
  
  withsomeone_pie1
  
  pdf(file.path(outputRaw, "withsomeone_pie1.pdf")) 
  plot(withsomeone_pie1)
  dev.off()
  
  #Text for pie Graph-----
  withsomeone1cprmax <- max(withsomeone1$withsomeone.cpr)
  
  withsomeone1_p <- as.numeric(unique((subset(withsomeone1, 
                                              withsomeone.cpr == withsomeone1cprmax,
                                              select = c(withsomeone.cpr)))))
  
  withsomeone1_n <- withsomeone1 %>%
    filter(withsomeone.cpr == withsomeone1cprmax) %>%
    select(withsomeone) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  withsomeone1_p <- round(withsomeone1_p)
}
#--------------------#
# UNIMPORTANT: ADMIN ACTIVITY #---------------------------------
#--------------------#
if (imp_check == 1) {
  pdf(file.path(outputRaw, "admin_act_pie1.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  admin_act1_p <- 0
  admin_act1_n <- "Any"
} else {
  admin_act1 <- subset(tud_unimp, is.na(admin.activity) == FALSE &
                         caseid !=100,
                       select = c(admin.activity.cpr,
                                  caseid,
                                  admin.activity,
                                  hh.actcadmin.activity,
                                  totalctime,
                                  casenme))
  
  admin_act1 <- admin_act1 %>% distinct()
  
  admin_act1 <- setDT(admin_act1)
  setkey(admin_act1, admin.activity)
  
  #Pie chart------
  admin_act1 <- admin_act1 %>% 
    mutate(end = 2 * pi * cumsum(admin.activity.cpr)/sum(admin.activity.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  admin_act_pie1 <- ggplot(admin_act1) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = admin.activity)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = admin.activity.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Administrative" = "steelblue1",
                                 "Technical"    = "gray90",
                                 "Other"   = "gray70")) +
    guides(fill=guide_legend(nrow=3, byrow=TRUE)) +
    labs(fill = "")
  
  admin_act_pie1
  
  pdf(file.path(outputRaw, "admin_act_pie1.pdf")) 
  plot(admin_act_pie1)
  dev.off()
  
  #Text for Pie Graph-----
  admin_act1cprmax <- max(admin_act1$admin.activity.cpr)
  
  admin_act1_p <- as.numeric(unique((subset(admin_act1, 
                                            admin.activity.cpr == admin_act1cprmax,
                                            select = c(admin.activity.cpr)))))
  
  admin_act1_n <- admin_act1 %>%
    filter(admin.activity.cpr == admin_act1cprmax) %>%
    select(admin.activity) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  admin_act1_p <- round(admin_act1_p)
}
#--------------------#
# UNIMPORTANT: PLANNED #----------------------------------------
#--------------------#
if (imp_check == 1) {
  pdf(file.path(outputRaw, "plan_act_pie1.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  plan_act1_p <- 0
  plan_act1_n <- "Any"
} else {
  plan_act1 <- subset(tud_unimp, is.na(planned) == FALSE &
                        caseid !=100,
                      select = c(planned.cpr,
                                 caseid,
                                 planned,
                                 hh.actcplanned,
                                 totalctime,
                                 casenme))
  
  plan_act1 <- plan_act1 %>% distinct()
  
  plan_act1 <- setDT(plan_act1)
  setkey(plan_act1, planned)
  
  #Pie chart------
  plan_act1 <- plan_act1 %>% 
    mutate(end = 2 * pi * cumsum(planned.cpr)/sum(planned.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  plan_act_pie1 <- ggplot(plan_act1) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = planned)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = planned.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Unplanned" = "steelblue1",
                                 "Planned"    = "gray90",
                                 "Other"   = "gray70")) +
    guides(fill=guide_legend(nrow=3, byrow=TRUE)) +
    labs(fill = "")
  
  plan_act_pie1
  
  pdf(file.path(outputRaw, "plan_act_pie1.pdf")) 
  plot(plan_act_pie1)
  dev.off()
  
  
  #Text for Bar Graph-----
  plan1cprmax <- max(plan_act1$planned.cpr)
  
  plan_act1_p <- as.numeric(unique((subset(plan_act1, 
                                           planned.cpr == plan1cprmax,
                                           select = c(planned.cpr)))))
  
  plan_act1_n <- plan_act1 %>%
    filter(planned.cpr == plan1cprmax) %>%
    select(planned) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  plan_act1_p <- round(plan_act1_p)
}
#--------------------#
# IMPORTANT: FOR TYPE OF ACTIVITY#-----------------------------------------
#--------------------#
if (unimp_check == 1) {
  pdf(file.path(outputRaw, "type2_plot.pdf")) 
  plot(x)
  dev.off()
  type_pie2_p <- 0
  type_pie2_n <- "Any Activity"
} else {
  type2 <- subset(type_imp, is.na(type) == FALSE &
                    caseid != 100 &
                    type != "Meetings" &
                    type != "Independent work" &
                    type != "Other" &
                    type.cpr >= 10,
                  select = c(type.cpr,
                             caseid,
                             type,
                             hh.actctype,
                             hh.actctypeday,
                             casenme))
  
  type2 <- type2 %>% distinct()
  
  type2 <- setDT(type2)
  type2 <- type2 %>% mutate_if(is.numeric, ~round(.))
  
  #Bar Graph-----
  type2_plot <- ggplot(type2, aes(factor(type),
                                  type.cpr,
                                  fill = casenme)) +
    geom_bar(position = position_dodge (width = -0.1),
             width = 0.6,
             stat = "identity") +
    coord_flip() +
    scale_fill_manual(values = c("plum")) +
    geom_text(aes(label=type.cpr),
              hjust=1.5, 
              color="white", 
              fontface="bold",
              size=8,
              position = position_dodge (width = 0.9))+
    ggtitle("") +
    xlab("") + ylab("Proportion (in %)") +
    theme(axis.title.x = element_text(color="navy", size=20, face="bold"),
          axis.title.y = element_text(color="navy", size=20, face="bold"),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black"),
          legend.position = "none",
          axis.text.x = element_text(size = 20, face = "bold"),
          axis.text.y = element_text(size = 20, face = "bold")) +
    labs(fill = "")
  ylim(-1, 100)
  
  type2_plot
  
  pdf(file.path(outputRaw, "type2_plot.pdf"), width = 11, height = 8) 
  
  plot(type2_plot)
  dev.off()
  
  #Pie Chart------
  type2 <- subset(type_imp, is.na(type) == FALSE &
                    caseid != 100 &
                    type != "Meetings" &
                    type != "Independent work",
                  select = c(type.cpr,
                             caseid,
                             type,
                             hh.actctype,
                             hh.actctypeday,
                             casenme))
  
  type2 <- type2 %>% distinct()
  
  type2 <- setDT(type2)
  type2 <- type2[order(-type.cpr),]
  
  type2 <- type2[!duplicated(type2$type), ]
  
  type2$cumsum <- cumsum(type2$type.cpr)
  
  type2_pie <- subset(type2, cumsum <= 99.99,
                      select = c(type.cpr,
                                 caseid,
                                 type,
                                 casenme,
                                 cumsum))
  
  type2cpr <- type2_pie$type.cpr
  typetcpr <- 100 - sum(type2cpr)
  
  type2_pie <- type2_pie %>% add_row(type.cpr = typetcpr, 
                                     caseid = case,
                                     type = "Other",
                                     casenme = casename,
                                     cumsum = "100")
  
  type2_pie <- type2_pie %>% 
    mutate(end = 2 * pi * cumsum(type.cpr)/sum(type.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  type_pie2 <- ggplot(type2_pie) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = type)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = type.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_brewer(palette = "PuBu", direction = -1) +
    guides(fill=guide_legend(nrow=5, byrow=TRUE)) +
    labs(fill = "")
  
  type_pie2
  
  pdf(file.path(outputRaw, "type_pie2.pdf")) 
  plot(type_pie2)
  dev.off()
  
  #Text for pie chart-----
  type2cprmax <- max(type2$type.cpr)
  
  type_pie2_p <- as.numeric(unique((subset(type2, 
                                           type.cpr == type2cprmax,
                                           select = c(type.cpr)))))
  
  type_pie2_hh <- as.numeric(unique((subset(type2, 
                                            type.cpr == type2cprmax,
                                            select = c(hh.actctype)))))
  type_pie2_hh <- type_pie2_hh/nr_weeks
  
  type_pie2_n <- type2 %>%
    filter(type.cpr == type2cprmax) %>%
    select(type) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  type_pie2_p <- round(type_pie2_p)
  type_pie2_hh <- round(type_pie2_hh)
}
#--------------------#
# IMPORTANT: FOR PROJECT CATEGORY #-----------------------------------------
#--------------------#
if (unimp_check == 1) {
  pdf(file.path(outputRaw, "cat_proj_pie2.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  cat_proj2_p <- 0
  cat_proj2_n <- "Any"
} else {
  cat_proj2 <- subset(tud_imp, is.na(category.project) == FALSE &
                        caseid != 100 &
                        category.project != "Haven't started work today",
                      select = c(category.project.cpr,
                                 caseid,
                                 category.project,
                                 hh.actccategory.project,
                                 totalctime,
                                 casenme))
  
  cat_proj2 <- cat_proj2 %>% distinct()
  
  cat_proj2 <- setDT(cat_proj2)
  setkey(cat_proj2, category.project)
  
  #Pie Chart------
  cat_proj2 <- cat_proj2 %>% 
    mutate(end = 2 * pi * cumsum(category.project.cpr)/sum(category.project.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  cat_proj_pie2 <- ggplot(cat_proj2) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = category.project)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = category.project.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Analytical" = "midnightblue",
                                 "Lending"    = "gray90",
                                 "Other"      = "gray50")) +
    guides(fill=guide_legend(nrow=3,byrow=TRUE)) +
    labs(fill = "")
  
  cat_proj_pie2
  
  pdf(file.path(outputRaw, "cat_proj_pie2.pdf")) 
  plot(cat_proj_pie2)
  dev.off()
  
  #Text for Pie Chart-----
  cat_proj2cprmax <- max(cat_proj2$category.project.cpr)
  
  cat_proj2_p <- as.numeric(unique((subset(cat_proj2, 
                                           category.project.cpr == cat_proj2cprmax,
                                           select = c(category.project.cpr))))) 
  
  cat_proj2_n <- cat_proj2 %>%
    filter(category.project.cpr == cat_proj2cprmax) %>%
    select(category.project) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  cat_proj2_p <- round(cat_proj2_p)
}
#--------------------#
# IMPORTANT: FOR MEETINGS #-----------------------------------------
#--------------------#
if (unimp_check == 1) {
  pdf(file.path(outputRaw, "withsomeone_pie2.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  withsomeone2_p <- 0
  withsomeone2_n <- "Any Activity"
} else {
  withsomeone2 <- subset(tud_imp, is.na(withsomeone) == FALSE &
                           caseid !=100,
                         select = c(withsomeone.cpr,
                                    caseid,
                                    withsomeone,
                                    hh.actcwithsomeone,
                                    totalctime,
                                    casenme))
  
  withsomeone2 <- withsomeone2 %>% distinct()
  
  withsomeone2 <- setDT(withsomeone2)
  setkey(withsomeone2, withsomeone)
  
  #Pie chart------
  withsomeone2 <- withsomeone2 %>% 
    mutate(end = 2 * pi * cumsum(withsomeone.cpr)/sum(withsomeone.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  withsomeone_pie2 <- ggplot(withsomeone2) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = withsomeone)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = withsomeone.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Meetings" = "gray90",
                                 "Independent work"    = "midnightblue")) +
    guides(fill=guide_legend(nrow=2,byrow=TRUE)) +
    labs(fill = "")
  
  withsomeone_pie2
  
  pdf(file.path(outputRaw, "withsomeone_pie2.pdf")) 
  plot(withsomeone_pie2)
  dev.off()
  
  #Text for Bar Graph-----
  withsomeone2cprmax <- max(withsomeone2$withsomeone.cpr)
  
  withsomeone2_p <- as.numeric(unique((subset(withsomeone2, 
                                              withsomeone.cpr == withsomeone2cprmax,
                                              select = c(withsomeone.cpr)))))
  
  withsomeone2_n <- withsomeone2 %>%
    filter(withsomeone.cpr == withsomeone2cprmax) %>%
    select(withsomeone) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  withsomeone2_p <- round(withsomeone2_p)
}
#--------------------#
# IMPORTANT: ADMIN ACTIVITY #------------------------------------------
#--------------------#
if (unimp_check == 1) {
  pdf(file.path(outputRaw, "admin_act_pie2.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  admin_act2_p <- 0
  admin_act2_n <- "Any"
} else {
  admin_act2 <- subset(tud_imp, is.na(admin.activity) == FALSE &
                         caseid !=100,
                       select = c(admin.activity.cpr,
                                  caseid,
                                  admin.activity,
                                  hh.actcadmin.activity,
                                  totalctime,
                                  casenme))
  
  admin_act2 <- admin_act2 %>% distinct()
  
  admin_act2 <- setDT(admin_act2)
  setkey(admin_act2, admin.activity)
  
  #Pie chart------
  admin_act2 <- admin_act2 %>% 
    mutate(end = 2 * pi * cumsum(admin.activity.cpr)/sum(admin.activity.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  admin_act_pie2 <- ggplot(admin_act2) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = admin.activity)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = admin.activity.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Technical" = "midnightblue",
                                 "Administrative"    = "gray90",
                                 "Other"   = "gray70")) +
    guides(fill=guide_legend(nrow=3,byrow=TRUE)) +
    labs(fill = "")
  
  admin_act_pie2
  
  pdf(file.path(outputRaw, "admin_act_pie2.pdf")) 
  plot(admin_act_pie2)
  dev.off()
  
  #Text for Bar Graph-----
  admin_act2cprmax <- max(admin_act2$admin.activity.cpr)
  
  admin_act2_p <- as.numeric(unique((subset(admin_act2, 
                                            admin.activity.cpr == admin_act2cprmax,
                                            select = c(admin.activity.cpr)))))
  
  admin_act2_n <- admin_act2 %>%
    filter(admin.activity.cpr == admin_act2cprmax) %>%
    select(admin.activity) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  admin_act2_p <- round(admin_act2_p)
}
#--------------------#
# IMPORTANT: PLANNED #----------------------------------------
#--------------------#
if (unimp_check == 1) {
  pdf(file.path(outputRaw, "plan_act_pie2.pdf"), width=8, height=8) 
  plot(x)
  dev.off()
  plan_act2_p <- 0
  plan_act2_n <- "Any"
} else {
  plan_act2 <- subset(tud_imp, is.na(planned) == FALSE &
                        caseid !=100,
                      select = c(planned.cpr,
                                 caseid,
                                 planned,
                                 hh.actcplanned,
                                 totalctime,
                                 casenme))
  
  plan_act2 <- plan_act2 %>% distinct()
  
  plan_act2 <- setDT(plan_act2)
  setkey(plan_act2, planned)
  
  #Pie chart------
  plan_act2 <- plan_act2 %>% 
    mutate(end = 2 * pi * cumsum(planned.cpr)/sum(planned.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  plan_act_pie2 <- ggplot(plan_act2) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = planned)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = planned.cpr,
                  hjust = hjust, vjust = vjust),
              size = 11) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=30)) +
    scale_fill_manual(values = c("Planned" = "midnightblue",
                                 "Unplanned"    = "gray90",
                                 "Other"   = "gray70")) +
    guides(fill=guide_legend(nrow=3,byrow=TRUE)) +
    labs(fill = "")
  
  plan_act_pie2
  
  pdf(file.path(outputRaw, "plan_act_pie2.pdf"))
  plot(plan_act_pie2)
  dev.off()
  
  #Text for Bar Graph-----
  plan_act2cprmax <- max(plan_act2$planned.cpr)
  
  plan_act2_p <- as.numeric(unique((subset(plan_act2, 
                                           planned.cpr == plan_act2cprmax,
                                           select = c(planned.cpr))))) 
  
  plan_act2_n <- plan_act2 %>%
    filter(planned.cpr == plan_act2cprmax) %>%
    select(planned) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  plan_act2_p <- round(plan_act2_p)
}
#--------------------#
# LINE GRAPH - TIME TREND #--------------------------------------------
#--------------#
if (nr_weeks <= 2) {
  pdf(file.path(outputRaw, "timetrend_plot.pdf")) 
  plot(x)
  dev.off()
} else {
  timetrend <- setDT(timetrend)
  
  #Line Graph--------
  timetrend_plot <- ggplot(timetrend, aes(x=workweek, 
                                          y=cpr.week, 
                                          group=category)) +
    geom_line(aes(color=category),
              size=2.5) +
    scale_color_brewer(palette="Dark2") +
    geom_point(aes(shape=category)) +
    geom_text_repel(aes(label=cpr.week),
                    size=8) +
    ggtitle("") +
    xlab("") + ylab("Percent time spent in a week") +
    theme(axis.title.x = element_text(color="navy", size=26, face="bold"),
          axis.title.y = element_text(color="navy", size=26, face="bold"),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black"),
          legend.position="right",
          legend.text=element_text(size=30),
          legend.title=element_blank(),
          legend.key=element_rect(fill='transparent',
                                  colour='transparent'),
          legend.key.size = unit(30, "mm"),
          axis.text.x = element_text(size = 26, face="bold"),
          axis.text.y = element_text(size = 26, face="bold")) +
    labs(fill = "")
  ylim(-1, 100)
  
  timetrend_plot
  
  pdf(file.path(outputRaw, "timetrend_plot.pdf"), width = 22, height = 6.5) 
  plot(timetrend_plot)
  dev.off()
}

#--------------------#
# PART 6: PAGE 4 #--------------------------------------------
#--------------#
df_admin <- subset(df_admin, is.na(admin.activity) == FALSE, 
                   select = c(admin.activity,
                              instancecadmin.activity,
                              instanceadmin.activity,
                              freq.cinstanceadmin.activity, 
                              freq.instanceadmin.activity,                              
                              hh.actcadmin.activity,
                              hh.actadmin.activity,
                              avg.hhcadmin.activity, 		
                              avg.hhadmin.activity, 			
                              admin.activity.cpr,
                              admin.activity.pr))

df_proj <- subset(df_proj, is.na(category.project) == FALSE, 
                  select = c(category.project,
                             instanceccategory.project,
                             instancecategory.project,
                             freq.cinstancecategory.project, 
                             freq.instancecategory.project, 
                             hh.actccategory.project,
                             hh.actcategory.project,
                             avg.hhccategory.project, 		
                             avg.hhcategory.project, 		
                             category.project.cpr,
                             category.project.pr))

df_imp <- subset(df_imp, is.na(importance) == FALSE, 
                 select = c(importance,
                            instancecimportance,
                            instanceimportance,
                            freq.cinstanceimportance, 
                            freq.instanceimportance, 
                            hh.actcimportance,
                            hh.actimportance,
                            avg.hhcimportance, 	
                            avg.hhimportance, 
                            importance.cpr,
                            importance.pr))

df_planned <- subset(df_planned, is.na(planned) == FALSE, 
                     select = c(planned,
                                instancecplanned,
                                instanceplanned,
                                freq.cinstanceplanned, 
                                freq.instanceplanned, 
                                hh.actcplanned,
                                hh.actplanned,
                                avg.hhcplanned, 
                                avg.hhplanned, 
                                planned.cpr,
                                planned.pr))

df_withsomeone <- subset(df_withsomeone, is.na(withsomeone) == FALSE, 
                         select = c(withsomeone,
                                    instancecwithsomeone,
                                    instancewithsomeone,
                                    freq.cinstancewithsomeone, 
                                    freq.instancewithsomeone, 
                                    hh.actcwithsomeone,
                                    hh.actwithsomeone,
                                    avg.hhcwithsomeone, 	
                                    avg.hhwithsomeone, 	
                                    withsomeone.cpr,
                                    withsomeone.pr))

df_act <- subset(df_act, is.na(activity.duration) == FALSE, 
                 select = c(activity.descr, 
                            withsomeone, 
                            category.project, 
                            admin.activity, 
                            importance, 
                            activity.duration))

#--------------------#
# PART 6: PAGE 1 #--------------------------------------------
#--------------#

#WORD CLOUD

excludeWords <- c("a", "the", "that", "an", "at", "by", "for", "from", "of", "off", "on", "out", "through", "with", "project", "talking", "meeting", "work", "tomorrow", "today", "yesterday")
activity <- tud$activity.descr
activity <- Corpus(VectorSource(activity))
dtm <- DocumentTermMatrix(activity)
# Convert the text to lower case
activity <- tm_map(activity, content_transformer(tolower))
# Remove numbers
activity <- tm_map(activity, removeNumbers)
# Remove stopwords for the language 
activity <- tm_map(activity, removeWords, stopwords("english"))
# Remove punctuations
activity <- tm_map(activity, removePunctuation)
# Eliminate extra white spaces
activity <- tm_map(activity, stripWhitespace)
# Remove your own stopwords
if(!is.null(excludeWords)) 
  activity <- tm_map(activity, removeWords, excludeWords) 

tdm <- TermDocumentMatrix(activity)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
# Plot the word cloud
set.seed(1234)
wordcloud(d$word,d$freq, min.freq=1, max.words=25,
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"),
          use.r.layout=FALSE)

invisible(list(tdm=tdm, freqTable = d))


pdf(file.path(outputRaw, "wordcloud.pdf"))
wordcloud(d$word,d$freq, min.freq=1, max.words=25,
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"),
          use.r.layout=TRUE)
dev.off()

freqmax <- max(d$freq)

freqmax_word <- unique((subset(d, 
                               freq == freqmax,
                               select = c(word))))

freqmax_word_n <- freqmax_word %>%
  filter(freqmax == freqmax) %>%
  select(word) %>%
  unlist %>%
  paste(collapse = ", ") 


avg_act_dur <- round(mean(unlist(subset(tud, caseid == case &
                                          is.na(activity.duration) == FALSE,
                                        select = c(activity.duration)))))
current_date <- Sys.Date()

#--------------------#
# PART 7: FOR LONG-TIME USERS #--------------------------------------------
#--------------#


save.image("~/GitHub/Agile_Productivity_Radar/DataWork/Task Allocation Check in/Report/Pilot/Code/R Markdown/backend_v2.RData")

rmarkdown::render("~/GitHub/Agile_Productivity_Radar/DataWork/Task Allocation Check in/Report/Pilot/Code/R Markdown/Report_v2.Rmd",
                  output_file =  paste("report_", case, '_', Sys.Date(), ".pdf", sep=''), 
                  output_dir = 'C:/Users/wb522556/WBG/Vincenzo Di Maro - Agile/06 - Agile Productivity Radar/DataWork/Task Allocation Check in/Report/Pilot/Outputs/Final')
}
