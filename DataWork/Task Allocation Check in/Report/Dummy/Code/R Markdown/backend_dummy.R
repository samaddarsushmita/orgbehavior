#------------------------------------------------------------------------------#
#                                                                              #
#                                     DIME                                     #
#                        Report for Time Use of WB Staff                       #                                     
#                                 Markdown                                      #                           
#                                                                              #
#------------------------------------------------------------------------------#
# PURPOSE:    Individualized Report for the WB Staff
# NOTES:      
# TO CHANGE CASES 
#             1.  GO TO Importing Data Section and Change Number

# WRITTEN BY: Sushmita Samaddar
# 
rm(list = ls(all.names = TRUE))

#CHANGE CASE#------------------
cases <- 2

for (case in 1:cases){
  
# PART 1: Select sections to run ----------------------------------------------
PACKAGES             <- 1

# PART 2: Load packages   -----------------------------------------------------
packages  <- c("readstata13", "foreign",
               "doBy", "broom", "dplyr",
               "stargazer",
               "ggplot2", "plotly", "ggrepel",
               "RColorBrewer", "RCurl", "XML",
               "sp", "rgdal", "rgeos",
               "ggmap", "leaflet",
               "htmlwidgets", "geosphere",
               "eeptools", "purrr", "ggforce",
               "formattable", "tidyr", 
               "manipulate", "data.table", 
               "tm", "SnowballC", "wordcloud", 
               "webshot", "stringr")

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
}

#--------------------#
# Project subfolders #
#--------------------#
dummyFolder       <- file.path(projectFolder,"Dummy")
Data              <- file.path(dummyFolder,"Datasets")
Intermediate      <- file.path(Data,"Intermediate")
outputFolder      <- file.path(dummyFolder, "Outputs")
outputRaw         <- file.path(outputFolder, "Raw")
outputFinal       <- file.path(outputFolder, "Final")

TUD <- read.dta13(file.path(Intermediate, "tud_dummy_v3.dta"),
                  convert.dates            = TRUE, 
                  convert.factors          = TRUE, 
                  missing.type             = TRUE, 
                  convert.underscore       = TRUE,
                  generate.factors         = TRUE,
                  nonint.factors           = TRUE)
TUD       <- TUD %>% mutate_if(is.numeric, ~round(., 2))

TUD_unimp <- read.dta13(file.path(Intermediate, "tud_dummy_v3_unimp.dta"),
                        convert.dates            = TRUE, 
                        convert.factors          = TRUE, 
                        missing.type             = TRUE, 
                        convert.underscore       = TRUE,
                        generate.factors         = TRUE,
                        nonint.factors           = TRUE)

TUD_unimp       <- TUD_unimp %>% mutate_if(is.numeric, ~round(., 2))

TUD_imp <- read.dta13(file.path(Intermediate, "tud_dummy_v3_imp.dta"), 
                      convert.dates            = TRUE, 
                      convert.factors          = TRUE, 
                      missing.type             = TRUE, 
                      convert.underscore       = TRUE,
                      generate.factors         = TRUE,
                      nonint.factors           = TRUE)

TUD_imp       <- TUD_imp %>% mutate_if(is.numeric, ~round(., 2))

type_unimp <- read.dta13(file.path(Intermediate, "tud_dummy_v4_type_unimp.dta"), 
                         convert.dates            = TRUE, 
                         convert.factors          = TRUE, 
                         missing.type             = TRUE, 
                         convert.underscore       = TRUE,
                         generate.factors         = TRUE,
                         nonint.factors           = TRUE)

type_unimp       <- type_unimp %>% mutate_if(is.numeric, ~round(., 2))

type_imp <- read.dta13(file.path(Intermediate, "tud_dummy_v4_type_imp.dta"), 
                       convert.dates            = TRUE, 
                       convert.factors          = TRUE, 
                       missing.type             = TRUE, 
                       convert.underscore       = TRUE,
                       generate.factors         = TRUE,
                       nonint.factors           = TRUE)

type_imp       <- type_imp %>% mutate_if(is.numeric, ~round(., 2))

df_admin <- read.dta13(file.path(Intermediate, "df_dummy_admin_activity.dta"), 
                       convert.dates            = TRUE, 
                       convert.factors          = TRUE, 
                       missing.type             = TRUE, 
                       convert.underscore       = TRUE,
                       generate.factors         = TRUE,
                       nonint.factors           = TRUE)

df_admin       <- df_admin %>% mutate_if(is.numeric, ~round(., 2))

df_proj <- read.dta13(file.path(Intermediate, "df_dummy_category_project.dta"), 
                      convert.dates            = TRUE, 
                      convert.factors          = TRUE, 
                      missing.type             = TRUE, 
                      convert.underscore       = TRUE,
                      generate.factors         = TRUE,
                      nonint.factors           = TRUE)

df_proj       <- df_proj %>% mutate_if(is.numeric, ~round(., 2))

df_imp <- read.dta13(file.path(Intermediate, "df_dummy_importance.dta"), 
                     convert.dates            = TRUE, 
                     convert.factors          = TRUE, 
                     missing.type             = TRUE, 
                     convert.underscore       = TRUE,
                     generate.factors         = TRUE,
                     nonint.factors           = TRUE)

df_imp       <- df_imp %>% mutate_if(is.numeric, ~round(., 2))

df_planned <- read.dta13(file.path(Intermediate, "df_dummy_planned.dta"), 
                         convert.dates            = TRUE, 
                         convert.factors          = TRUE, 
                         missing.type             = TRUE, 
                         convert.underscore       = TRUE,
                         generate.factors         = TRUE,
                         nonint.factors           = TRUE)

df_planned       <- df_planned %>% mutate_if(is.numeric, ~round(., 2))

df_withsomeone <- read.dta13(file.path(Intermediate, "df_dummy_withsomeone.dta"), 
                             convert.dates            = TRUE, 
                             convert.factors          = TRUE, 
                             missing.type             = TRUE, 
                             convert.underscore       = TRUE,
                             generate.factors         = TRUE,
                             nonint.factors           = TRUE)

df_withsomeone       <- df_withsomeone %>% mutate_if(is.numeric, ~round(., 2))

  tud_type <- read.dta13(file.path(Intermediate, paste0("tud_dummy_v3_type", case, "_trunc.dta")), 
                         convert.dates            = TRUE, 
                         convert.factors          = TRUE, 
                         missing.type             = TRUE, 
                         convert.underscore       = TRUE,
                         generate.factors         = TRUE,
                         nonint.factors           = TRUE)
  
  tud_type       <- tud_type %>% mutate_if(is.numeric, ~round(., 2))
  
  #--------------------#
  # Importing Data #----------------------------------
  #--------------------#
  
  tud <- subset(TUD, caseid == case |
                  caseid == 100)
  
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
  
  type_imp <- subset(type_imp, caseid == case |
                       caseid == 100, 
                     select = c(caseid,
                                casenme,
                                type, 
                                type.cpr,
                                hh.actctype,
                                hh.actctypeday))
  
  df_admin <- subset(df_admin, caseid == case, 
                     select = c(instancecadmin.activity,
                                freq.cinstanceadmin.activity, 
                                hh.actcadmin.activity,
                                avg.hhcadmin.activity, 					
                                admin.activity.cpr,
                                admin.activity,
                                caseid,
                                casenme))
  
  df_proj <- subset(df_proj, caseid == case, 
                    select = c(instanceccategory.project,
                               freq.cinstancecategory.project, 
                               hh.actccategory.project,
                               avg.hhccategory.project, 					
                               category.project.cpr,
                               category.project,
                               caseid,
                               casenme))
  
  df_imp <- subset(df_imp, caseid == case, 
                   select = c(instancecimportance,
                              freq.cinstanceimportance, 
                              hh.actcimportance,
                              avg.hhcimportance, 					
                              importance.cpr,
                              importance,
                              caseid,
                              casenme))
  
  df_planned <- subset(df_planned, caseid == case, 
                       select = c(instancecplanned,
                                  freq.cinstanceplanned, 
                                  hh.actcplanned,
                                  avg.hhcplanned, 					
                                  planned.cpr,
                                  planned,
                                  caseid,
                                  casenme))
  
  df_withsomeone <- subset(df_withsomeone, caseid == case, 
                           select = c(instancecwithsomeone,
                                      freq.cinstancewithsomeone, 
                                      hh.actcwithsomeone,
                                      avg.hhcwithsomeone, 					
                                      withsomeone.cpr,
                                      withsomeone,
                                      caseid,
                                      casenme))
  
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
  
  #--------------------#
  # PART 5: PAGE 2 #--------------------------------------------
  #--------------------#
  
  #ROUNDING ALL NUMERIC VARIABLES
  
  #--------------------#
  # PROJECT CATEGORY #--------------------------------------------
  #--------------------#
  cat_proj <- subset(tud, is.na(category.project) == FALSE |
                       is.na(category.project.cpr) == FALSE,
                     select = c(category.project.cpr,
                                caseid,
                                category.project,
                                hh.actccategory.project,
                                totalctime.category.project,
                                casenme))
  cat_proj <- setDT(cat_proj)
  setkey(cat_proj, category.project)
  
  #Bar Graph------
  cat_proj_plot <- ggplot(cat_proj, aes(factor(category.project),
                                        category.project.cpr,
                                        fill = casenme)) +
    geom_bar(position = position_dodge (width = 0.5),
             stat = "identity") +
    geom_text(aes(label=category.project.cpr),
              vjust=-0.3, 
              color="black", 
              size=6,
              position = position_dodge(0.9))+
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
  
  jpeg(file.path(outputRaw, "cat_proj_plot.jpg"), 
       height = 7,
       width = 12, 
       units = "in",
       res = 300) 
  plot(cat_proj_plot)
  dev.off()
  
  #For Bar Graph Text-------
  analytical_perc <- max((subset(cat_proj, 
                                 category.project == "Analytical" &
                                   caseid != 100,
                                 select = c(category.project.cpr))))
  
  analytical_chh <-  max(subset(cat_proj, 
                                category.project == "Analytical" &
                                  caseid         !=  100,
                                select = c(hh.actccategory.project)))
  analytical_thh <-  max(subset(cat_proj, 
                                category.project == "Analytical" &
                                  caseid         ==  100,
                                select = c(hh.actccategory.project)))
  #--------------------#
  # MEETINGS #--------------------------------------------
  #--------------------#
  withsomeone <- subset(tud, is.na(withsomeone) == FALSE |
                          is.na(withsomeone.cpr) == FALSE,
                        select = c(withsomeone.cpr,
                                   caseid,
                                   withsomeone,
                                   hh.actcwithsomeone,
                                   totalctime.withsomeone,
                                   casenme))
  withsomeone <- setDT(withsomeone)
  
  setkey(withsomeone, withsomeone)
  
  #Bar Graph------
  withsomeone_plot <- ggplot(withsomeone, aes(factor(withsomeone),
                                              withsomeone.cpr,
                                              fill = casenme)) +
    geom_bar(position = position_dodge (width = 0.5),
             stat = "identity") +
    geom_text(aes(label=withsomeone.cpr),
              vjust=-0.3, 
              color="black", 
              size=6,
              position = position_dodge(0.9))+
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
  
  jpeg(file.path(outputRaw, "withsomeone_plot.jpg"),
       height = 7,
       width = 12, 
       units = "in",
       res = 300) 
  plot(withsomeone_plot)
  dev.off()
  
  #For Bar Graph Text-------
  meeting_perc <- max(subset(withsomeone, 
                             withsomeone == "Meeting" &
                               caseid         !=  100,
                             select = c(withsomeone.cpr))) 
  
  meeting_chh <-  max(subset(withsomeone, 
                             withsomeone == "Meeting" &
                               caseid         !=  100,
                             select = c(hh.actcwithsomeone)))
  meeting_thh <-  max(subset(withsomeone, 
                             withsomeone == "Meeting" &
                               caseid         ==  100,
                             select = c(hh.actcwithsomeone)))
  #--------------------#
  # ADMIN ACTIVITY #--------------------------------------------
  #--------------------#
  
  admin_act <- subset(tud, is.na(admin.activity) == FALSE &
                        is.na(admin.activity.cpr) == FALSE,
                      select = c(admin.activity.cpr,
                                 caseid,
                                 admin.activity,
                                 hh.actcadmin.activity,
                                 totalctime.admin.activity,
                                 casenme))
  admin_act <- setDT(admin_act)
  
  #Bar Graph-----
  admin_act_plot <- ggplot(admin_act, aes(factor(admin.activity),
                                          admin.activity.cpr,
                                          fill = casenme)) +
    geom_bar(position = position_dodge (width = 0.5),
             stat = "identity") +
    geom_text(aes(label=admin.activity.cpr),
              vjust=-0.3, 
              color="black", 
              size=6,
              position = position_dodge(0.9))+
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
  
  jpeg(file.path(outputRaw, "admin_act_plot.jpg"),
       height = 7,
       width = 12, 
       units = "in",
       res = 300) 
  plot(admin_act_plot)
  dev.off()
  
  #For Bar Graph Text------
  admin_perc <- max(subset(admin_act, 
                           admin.activity == "Administrative" &
                             caseid         !=  100,
                           select = c(admin.activity.cpr))) 
  
  admin_chh <-  max(subset(admin_act, 
                           admin.activity == "Administrative" &
                             caseid         !=  100,
                           select = c(hh.actcadmin.activity)))
  
  admin_thh <-  max(subset(admin_act, 
                           admin.activity == "Administrative" &
                             caseid         ==  100,
                           select = c(hh.actcadmin.activity)))
  #--------------------#
  # FOR PLANNED #--------------------------------------------
  #--------------------#
  planned_act <- subset(tud, is.na(planned) == FALSE &
                          is.na(planned.cpr) == FALSE,
                        select = c(planned.cpr,
                                   caseid,
                                   planned,
                                   hh.actcplanned, 
                                   totalctime.planned,
                                   casenme))
  planned_act <- setDT(planned_act)
  
  #Bar Graph--------
  planned_act_plot <- ggplot(planned_act, aes(factor(planned),
                                              planned.cpr,
                                              fill = casenme)) +
    geom_bar(position = position_dodge (width = 0.5),
             stat = "identity") +
    geom_text(aes(label=planned.cpr),
              vjust=-0.3, 
              color="black", 
              size=6,
              position = position_dodge(0.9))+
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
  
  jpeg(file.path(outputRaw, "planned_act_plot.jpg"),
       height = 7,
       width = 10, 
       units = "in",
       res = 300) 
  plot(planned_act_plot)
  dev.off()
  
  #For Bar Graph Text-------
  planned_perc <- max(subset(planned_act, 
                             planned == "Planned" &
                               caseid         !=  100,
                             select = c(planned.cpr))) 
  
  planned_chh <-  max(subset(planned_act, 
                             planned == "Planned" &
                               caseid         !=  100,
                             select = c(hh.actcplanned)))
  planned_thh <-  max(subset(planned_act, 
                             planned == "Planned" &
                               caseid         ==  100,
                             select = c(hh.actcplanned)))
  
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
                               totalctime.importance,
                               casenme))
  imp_act <- setDT(imp_act)
  
  imp_act_plot <- ggplot(imp_act, aes(factor(importance),
                                      importance.cpr,
                                      fill = casenme)) +
    geom_bar(position = position_dodge (width = 0.5),
             stat = "identity") +
    geom_text(aes(label=importance.cpr),
              vjust=-0.3, 
              color="black", 
              size=6,
              position = position_dodge(0.9))+
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
  
  jpeg(file.path(outputRaw, "imp_act_plot.jpg"),
       height = 7,
       width = 10, 
       units = "in",
       res = 300) 
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
                                 totalctime.imp.act, 
                                 casenme))
  imp_act_s <- setDT(imp_act_s)
  
  #Bar Graph-----
  
  imp_act_s_plot <- ggplot(imp_act_s, aes(factor(imp.act),
                                          imp.act.cpr,
                                          fill = casenme)) +
    geom_bar(position = position_dodge (width = 0.5),
             stat = "identity") +
    geom_text(aes(label=imp.act.cpr),
              vjust=-0.3, 
              color="black", 
              size=6,
              position = position_dodge(0.9))+
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
  
  jpeg(file.path(outputRaw, "imp_act_s_plot.jpg"),
       height = 6,
       width = 10, 
       units = "in",
       res = 300) 
  
  plot(imp_act_s_plot)
  dev.off()
  
  #For Bar Graph Text-------
  imp_act_perc <- max(subset(imp_act_s, 
                             imp.act == "Important" &
                               caseid         !=  100,
                             select = c(imp.act.cpr))) 
  
  imp_act_chh <-  max(subset(imp_act_s, 
                             imp.act == "Important" &
                               caseid         !=  100,
                             select = c(hh.actcimp.act)))
  imp_act_thh <-  max(subset(imp_act_s, 
                             imp.act == "Important" &
                               caseid         ==  100,
                             select = c(hh.actcimp.act)))
  
  #--------------------#
  # FOR TYPE OF ACTIVITY#--------------------------------------------
  #--------------------#
  type_act <- setDT(tud_type)
  
  #Bar Graph-----
  type_act_plot <- ggplot(type_act, aes(factor(type),
                                        hh.actctypeday,
                                        fill = casenme)) +
    geom_bar(position = position_dodge (width = 0.5),
             stat = "identity") +
    geom_text(aes(label=hh.actctypeday),
              vjust=-0.3, 
              color="black", 
              size=6,
              position = position_dodge(0.9))+
    ggtitle("") +
    xlab("") + ylab("Avg hours spent in a day") +
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
        hh.actctypeday) + 
    xlab("") +
    ylab("Average number of hours spent in a day")
  
  type_act_plot
  
  jpeg(file.path(outputRaw, "type_act_plot.jpg"),
       height = 6,
       width = 10, 
       units = "in",
       res = 300) 
  
  plot(type_act_plot)
  dev.off()
  
  
  #For Bar Graph Text-------
  
  type_act_p <- subset(type_act, caseid !=  100,
                       select = c(type.cpr)) 
  
  type_act_chh <-  max(type_act_chh <- subset(type_act,
                                              caseid         !=  100,
                                              select = c(hh.actctypeday)))
  
  type_act_perc <- as.numeric(unique(subset(type_act, 
                                            caseid != 100 &
                                              hh.actctypeday == type_act_chh,
                                            select = c(type.cpr))))
  
  type_act_nme <- type_act %>%
    filter(caseid != 100 & type.cpr == type_act_perc) %>%
    select(type) %>%
    unlist %>%
    paste(collapse = ", ") 
  
  #--------------------#
  # PART 5: PAGE 3 #--------------------------------------------
  
  
  #--------------------#
  # UNIMPORTANT: FOR TYPE OF ACTIVITY#-----------------------------------------
  #--------------------#
  
  type1 <- subset(type_unimp, is.na(type) == FALSE &
                    caseid != 100,
                  select = c(type.cpr,
                             caseid,
                             type,
                             hh.actctype,
                             hh.actctypeday,
                             casenme))
  
  type1 <- type1 %>% distinct()
  
  type1 <- setDT(type1)
  setkey(type1, type)
  
  #Pie Chart------
  type1 <- type1[order(-type.cpr),]
  type1$cumsum <- cumsum(type1$type.cpr)
  
  type1 <- subset(type1, cumsum <= 99.99,
                  select = c(type.cpr,
                             caseid,
                             type,
                             casenme,
                             cumsum))
  
  type1cpr <- type1$type.cpr
  typetcpr <- 100 - sum(type1cpr)
  
  type1 <- type1 %>% add_row(type.cpr = typetcpr, 
                             caseid = case,
                             type = "Other",
                             casenme = casename,
                             cumsum = "100")
  
  type1 <- type1 %>% 
    mutate(end = 2 * pi * cumsum(type.cpr)/sum(type.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  type_pie1 <- ggplot(type1) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = type)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = type.cpr,
                  hjust = hjust, vjust = vjust),
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20))+
    labs(fill = "")
  
  type_pie1
  
  jpeg(file.path(outputRaw, "type_pie1.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(type_pie1)
  dev.off()
  
  
  #Text for Pie Chart-----
  type1cprmax <- max(type1$type.cpr)
  
  type_pie1_p <- as.numeric(subset(type1, 
                                   type.cpr == type1cprmax,
                                   select = c(type.cpr))) 
  
  type_pie1_n <- as.character(subset(type1, 
                                     type.cpr == type1cprmax,
                                     select = c(type))) 
  
  #--------------------#
  # UNIMPORTANT: FOR PROJECT CATEGORY #-----------------------------------------
  #--------------------#
  
  cat_proj1 <- subset(tud_unimp, is.na(category.project) == FALSE &
                        caseid != 100,
                      select = c(category.project.cpr,
                                 caseid,
                                 category.project,
                                 hh.actccategory.project,
                                 totalctime.category.project,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Analytical" = "darkseagreen1",
                                 "Lending"    = "gray90",
                                 "Other"      = "gray50")) +
    labs(fill = "")
  
  cat_proj_pie1
  
  jpeg(file.path(outputRaw, "cat_proj_pie1.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(cat_proj_pie1)
  dev.off()
  
  #Text for Pie Chart-----
  cat_proj1_p <- as.numeric(subset(cat_proj1, 
                                   category.project == "Analytical",
                                   select = c(category.project.cpr))) 
  
  #--------------------#
  # UNIMPORTANT: FOR MEETINGS #-----------------------------------------
  #--------------------#
  
  withsomeone1 <- subset(tud_unimp, is.na(withsomeone) == FALSE &
                           caseid !=100,
                         select = c(withsomeone.cpr,
                                    caseid,
                                    withsomeone,
                                    hh.actcwithsomeone,
                                    totalctime.withsomeone,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Meeting" = "darkseagreen1",
                                 "Independent"    = "gray90")) +
    labs(fill = "")
  
  withsomeone_pie1
  
  jpeg(file.path(outputRaw, "withsomeone_pie1.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(withsomeone_pie1)
  dev.off()
  
  #Text for Bar Graph-----
  withsomeone1_p <- as.numeric(subset(withsomeone1, 
                                      withsomeone == "Meeting",
                                      select = c(withsomeone.cpr))) 
  
  #--------------------#
  # UNIMPORTANT: ADMIN ACTIVITY #---------------------------------
  #--------------------#
  
  admin_act1 <- subset(tud_unimp, is.na(admin.activity) == FALSE &
                         caseid !=100,
                       select = c(admin.activity.cpr,
                                  caseid,
                                  admin.activity,
                                  hh.actcadmin.activity,
                                  totalctime.admin.activity,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Administrative" = "darkseagreen1",
                                 "Project Related"    = "gray90",
                                 "Other"   = "gray70")) +
    labs(fill = "")
  
  admin_act_pie1
  
  jpeg(file.path(outputRaw, "admin_act_pie1.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(admin_act_pie1)
  dev.off()
  
  #Text for Bar Graph-----
  admin_act1_p <- as.numeric(subset(admin_act1, 
                                    admin.activity == "Administrative",
                                    select = c(admin.activity.cpr))) 
  
  #--------------------#
  # UNIMPORTANT: PLANNED #----------------------------------------
  #--------------------#
  
  plan_act1 <- subset(tud_unimp, is.na(planned) == FALSE &
                        caseid !=100,
                      select = c(planned.cpr,
                                 caseid,
                                 planned,
                                 hh.actcplanned,
                                 totalctime.planned,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Unplanned" = "darkseagreen1",
                                 "Planned"    = "gray90",
                                 "Other"   = "gray70")) +
    labs(fill = "")
  
  plan_act_pie1
  
  jpeg(file.path(outputRaw, "plan_act_pie1.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(plan_act_pie1)
  dev.off()
  
  
  #Text for Bar Graph-----
  plan_act1_p <- as.numeric(subset(plan_act1, 
                                   planned == "Unplanned",
                                   select = c(planned.cpr)))
  
  #--------------------#
  # IMPORTANT: FOR TYPE OF ACTIVITY#-----------------------------------------
  #--------------------#
  
  type2 <- subset(type_imp, is.na(type) == FALSE &
                    caseid != 100,
                  select = c(type.cpr,
                             caseid,
                             type,
                             hh.actctype,
                             hh.actctypeday,
                             casenme))
  
  type2 <- type2 %>% distinct()
  
  type2 <- setDT(type2)
  setkey(type2, type)
  
  #Pie Chart------
  type2 <- type2[order(-type.cpr),]
  type2$cumsum <- cumsum(type2$type.cpr)
  
  type2 <- subset(type2, cumsum <= 99.99,
                  select = c(type.cpr,
                             caseid,
                             type,
                             casenme,
                             cumsum))
  
  type2cpr <- type2$type.cpr
  typetcpr <- 100 - sum(type2cpr)
  
  type2 <- type2 %>% add_row(type.cpr = typetcpr, 
                             caseid = case,
                             type = "Other",
                             casenme = casename,
                             cumsum = "100")
  
  type2 <- type2 %>% 
    mutate(end = 2 * pi * cumsum(type.cpr)/sum(type.cpr),
           start = lag(end, default = 0),
           middle = 0.5 * (start + end),
           hjust = ifelse(middle > pi, 1, 0),
           vjust = ifelse(middle < pi/2 | middle > 3 * pi/2, 0, 1))
  
  type_pie2 <- ggplot(type2) +
    geom_arc_bar(aes(x0 = 0, y0 = 0, r0 = 0, r = 1,
                     start = start, end = end, fill = type)) +
    geom_text(aes(x = 1.05 * sin(middle), y = 1.05 * cos(middle), label = type.cpr,
                  hjust = hjust, vjust = vjust),
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    labs(fill = "")
  
  type_pie2
  
  jpeg(file.path(outputRaw, "type_pie2.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(type_pie2)
  dev.off()
  
  #Text for Bar Graph-----
  type2cprmax <- max(type2$type.cpr)
  
  type_pie2_p <- as.numeric(subset(type2, 
                                   type.cpr == type2cprmax,
                                   select = c(type.cpr))) 
  
  type_pie2_n <- as.character(subset(type2, 
                                     type.cpr == type2cprmax,
                                     select = c(type))) 
  
  #--------------------#
  # IMPORTANT: FOR PROJECT CATEGORY #-----------------------------------------
  #--------------------#
  
  cat_proj2 <- subset(tud_imp, is.na(category.project) == FALSE &
                        caseid != 100 &
                        category.project != "Haven't started work today",
                      select = c(category.project.cpr,
                                 caseid,
                                 category.project,
                                 hh.actccategory.project,
                                 totalctime.category.project,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Analytical" = "darkseagreen1",
                                 "Lending"    = "gray90",
                                 "Other"      = "gray50")) +
    labs(fill = "")
  
  cat_proj_pie2
  
  jpeg(file.path(outputRaw, "cat_proj_pie2.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(cat_proj_pie2)
  dev.off()
  
  #Text for Pie Chart-----
  cat_proj2_p <- as.numeric(subset(cat_proj2, 
                                   category.project == "Analytical",
                                   select = c(category.project.cpr))) 
  
  #--------------------#
  # IMPORTANT: FOR MEETINGS #-----------------------------------------
  #--------------------#
  
  withsomeone2 <- subset(tud_imp, is.na(withsomeone) == FALSE &
                           caseid !=100,
                         select = c(withsomeone.cpr,
                                    caseid,
                                    withsomeone,
                                    hh.actcwithsomeone,
                                    totalctime.withsomeone,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Meeting" = "gray90",
                                 "Independent"    = "darkseagreen1")) +
    labs(fill = "")
  
  withsomeone_pie2
  
  jpeg(file.path(outputRaw, "withsomeone_pie2.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(withsomeone_pie2)
  dev.off()
  
  #Text for Bar Graph-----
  withsomeone2_p <- as.numeric(subset(withsomeone2, 
                                      withsomeone == "Independent",
                                      select = c(withsomeone.cpr))) 
  
  #--------------------#
  # IMPORTANT: ADMIN ACTIVITY #------------------------------------------
  #--------------------#
  
  admin_act2 <- subset(tud_imp, is.na(admin.activity) == FALSE &
                         caseid !=100,
                       select = c(admin.activity.cpr,
                                  caseid,
                                  admin.activity,
                                  hh.actcadmin.activity,
                                  totalctime.admin.activity,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Project Related" = "darkseagreen1",
                                 "Administrative"    = "gray90",
                                 "Other"   = "gray70")) +
    labs(fill = "")
  
  admin_act_pie2
  
  jpeg(file.path(outputRaw, "admin_act_pie2.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(admin_act_pie2)
  dev.off()
  
  #Text for Bar Graph-----
  admin_act2_p <- as.numeric(subset(admin_act2, 
                                    admin.activity == "Project Related",
                                    select = c(admin.activity.cpr))) 
  #--------------------#
  # IMPORTANT: PLANNED #----------------------------------------
  #--------------------#
  
  plan_act2 <- subset(tud_imp, is.na(planned) == FALSE &
                        caseid !=100,
                      select = c(planned.cpr,
                                 caseid,
                                 planned,
                                 hh.actcplanned,
                                 totalctime.planned,
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
              size = 6) +
    coord_fixed() +
    scale_x_continuous(limits = c(-1.5, 1.4),  # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    scale_y_continuous(limits = c(-1, 1),      # Adjust so labels are not cut off
                       name = "", breaks = NULL, labels = NULL) +
    theme_void() + 
    theme(legend.position="bottom",
          legend.text=element_text(size=20)) +
    scale_fill_manual(values = c("Planned" = "darkseagreen1",
                                 "Unplanned"    = "gray90",
                                 "Other"   = "gray70")) +
    labs(fill = "")
  
  plan_act_pie2
  
  jpeg(file.path(outputRaw, "plan_act_pie2.jpg"),
       height = 7,
       width = 7, 
       units = "in",
       res = 300) 
  plot(plan_act_pie2)
  dev.off()
  
  #Text for Bar Graph-----
  plan_act2_p <- as.numeric(subset(plan_act2, 
                                   planned == "Planned",
                                   select = c(planned.cpr))) 
  
  #--------------------#
  # PART 6: PAGE 4 #--------------------------------------------
  #--------------#
  df_admin <- subset(df_admin, is.na(admin.activity) == FALSE, 
                     select = c(admin.activity,
                                instancecadmin.activity,
                                freq.cinstanceadmin.activity, 
                                hh.actcadmin.activity,
                                avg.hhcadmin.activity, 					
                                admin.activity.cpr))
  
  df_proj <- subset(df_proj, is.na(category.project) == FALSE, 
                    select = c(category.project,
                               instanceccategory.project,
                               freq.cinstancecategory.project, 
                               hh.actccategory.project,
                               avg.hhccategory.project, 					
                               category.project.cpr))
  
  df_imp <- subset(df_imp, is.na(importance) == FALSE, 
                   select = c(importance,
                              instancecimportance,
                              freq.cinstanceimportance, 
                              hh.actcimportance,
                              avg.hhcimportance, 					
                              importance.cpr))
  
  df_planned <- subset(df_planned, is.na(planned) == FALSE, 
                       select = c(planned,
                                  instancecplanned,
                                  freq.cinstanceplanned, 
                                  hh.actcplanned,
                                  avg.hhcplanned, 					
                                  planned.cpr))
  
  df_withsomeone <- subset(df_withsomeone, is.na(withsomeone) == FALSE, 
                           select = c(withsomeone,
                                      instancecwithsomeone,
                                      freq.cinstancewithsomeone, 
                                      hh.actcwithsomeone,
                                      avg.hhcwithsomeone, 					
                                      withsomeone.cpr))
  
  #--------------------#
  # TABLES: FOR ADMIN #-----------------------------------------
  #--------------------#
  customGreen0 = "#DeF7E9"
  
  customGreen = "#71CA97"
  
  customRed = "#ff7f7f"
  
  df_admin <- formattable(df_admin)
  
  names(df_admin)[names(df_admin) == "admin.activity"] <- "Category"
  names(df_admin)[names(df_admin) == "instancecadmin.activity"] <- "Instances"
  names(df_admin)[names(df_admin) == "freq.cinstanceadmin.activity"] <- "Frequency (%)"
  names(df_admin)[names(df_admin) == "hh.actcadmin.activity"] <- "Total Time Spent (Hours)"
  names(df_admin)[names(df_admin) == "avg.hhcadmin.activity"] <- "Average Time Spent (Hours)"
  names(df_admin)[names(df_admin) == "admin.activity.cpr"] <- "As a Proportion of Time Recorded (%)"
  df_admin
  
  df_admin <- formattable(df_admin, 
                          align =c("l","c","c","c","c", "c", "c", "c", "r"), 
                          list(`Indicator Name` = formatter(
                            "span", style = ~ style(color = "grey",font.weight = "bold")) 
                          ))
  
  df_admin <- formattable(df_admin, align =c("l","c","c","c","c", "c", "c", "c", "r"), list(
    `Category` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")), 
    `Instances`= color_tile(customGreen0, customGreen),
    `Frequency (%)`= color_tile(customGreen0, customGreen),
    `Total Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `Average Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `As a Proportion of Time Recorded (%)`= color_tile(customGreen0, customGreen)
  ))
  
  df_admin
  
  
  #--------------------#
  # TABLES: FOR IMPORTANCE #-----------------------------------------
  #--------------------#
  customGreen0 = "#DeF7E9"
  
  customGreen = "#71CA97"
  
  customRed = "#ff7f7f"
  
  df_imp <- formattable(df_imp)
  
  names(df_imp)[names(df_imp) == "importance"] <- "Category"
  names(df_imp)[names(df_imp) == "instancecimportance"] <- "Instances"
  names(df_imp)[names(df_imp) == "freq.cinstanceimportance"] <- "Frequency (%)"
  names(df_imp)[names(df_imp) == "hh.actcimportance"] <- "Total Time Spent (Hours)"
  names(df_imp)[names(df_imp) == "avg.hhcimportance"] <- "Average Time Spent (Hours)"
  names(df_imp)[names(df_imp) == "importance.cpr"] <- "As a Proportion of Time Recorded (%)"
  df_imp
  
  df_imp <- formattable(df_imp, 
                        align =c("l","c","c","c","c", "c", "c", "c", "r"), 
                        list(`Indicator Name` = formatter(
                          "span", style = ~ style(color = "grey",font.weight = "bold")) 
                        ))
  
  df_imp <- formattable(df_imp, align =c("l","c","c","c","c", "c", "c", "c", "r"), list(
    `Category` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")), 
    `Instances`= color_tile(customGreen0, customGreen),
    `Frequency (%)`= color_tile(customGreen0, customGreen),
    `Total Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `Average Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `As a Proportion of Time Recorded (%)`= color_tile(customGreen0, customGreen)
  ))
  df_imp
  
  #--------------------#
  # TABLES: FOR MEETING #-----------------------------------------
  #--------------------#
  customGreen0 = "#DeF7E9"
  
  customGreen = "#71CA97"
  
  customRed = "#ff7f7f"
  
  df_withsomeone <- formattable(df_withsomeone)
  
  names(df_withsomeone)[names(df_withsomeone) == "withsomeone"] <- "Category"
  names(df_withsomeone)[names(df_withsomeone) == "instancecwithsomeone"] <- "Instances"
  names(df_withsomeone)[names(df_withsomeone) == "freq.cinstancewithsomeone"] <- "Frequency (%)"
  names(df_withsomeone)[names(df_withsomeone) == "hh.actcwithsomeone"] <- "Total Time Spent (Hours)"
  names(df_withsomeone)[names(df_withsomeone) == "avg.hhcwithsomeone"] <- "Average Time Spent (Hours)"
  names(df_withsomeone)[names(df_withsomeone) == "withsomeone.cpr"] <- "As a Proportion of Time Recorded (%)"
  df_withsomeone
  
  df_withsomeone <- formattable(df_withsomeone, 
                                align =c("l","c","c","c","c", "c", "c", "c", "r"), 
                                list(`Indicator Name` = formatter(
                                  "span", style = ~ style(color = "grey",font.weight = "bold")) 
                                ))
  
  df_withsomeone <- formattable(df_withsomeone, align =c("l","c","c","c","c", "c", "c", "c", "r"), list(
    `Category` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")), 
    `Instances`= color_tile(customGreen0, customGreen),
    `Frequency (%)`= color_tile(customGreen0, customGreen),
    `Total Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `Average Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `As a Proportion of Time Recorded (%)`= color_tile(customGreen0, customGreen)
  ))
  
  df_withsomeone
  
  #--------------------#
  # TABLES: FOR PLANNED #-----------------------------------------
  #--------------------#
  customGreen0 = "#DeF7E9"
  
  customGreen = "#71CA97"
  
  customRed = "#ff7f7f"
  
  df_planned <- formattable(df_planned)
  
  names(df_planned)[names(df_planned) == "planned"] <- "Category"
  names(df_planned)[names(df_planned) == "instancecplanned"] <- "Instances"
  names(df_planned)[names(df_planned) == "freq.cinstanceplanned"] <- "Frequency (%)"
  names(df_planned)[names(df_planned) == "hh.actcplanned"] <- "Total Time Spent (Hours)"
  names(df_planned)[names(df_planned) == "avg.hhcplanned"] <- "Average Time Spent (Hours)"
  names(df_planned)[names(df_planned) == "planned.cpr"] <- "As a Proportion of Time Recorded (%)"
  df_planned
  
  df_planned <- formattable(df_planned, 
                            align =c("l","c","c","c","c", "c", "c", "c", "r"), 
                            list(`Indicator Name` = formatter(
                              "span", style = ~ style(color = "grey",font.weight = "bold")) 
                            ))
  
  df_planned <- formattable(df_planned, align =c("l","c","c","c","c", "c", "c", "c", "r"), list(
    `Category` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")), 
    `Instances`= color_tile(customGreen0, customGreen),
    `Frequency (%)`= color_tile(customGreen0, customGreen),
    `Total Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `Average Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `As a Proportion of Time Recorded (%)`= color_tile(customGreen0, customGreen)
  ))
  
  df_planned
  
  #--------------------#
  # TABLES: FOR PROJECT CATEGORY #-----------------------------------------
  #--------------------#
  customGreen0 = "#DeF7E9"
  
  customGreen = "#71CA97"
  
  customRed = "#ff7f7f"
  
  df_proj <- formattable(df_proj)
  
  names(df_proj)[names(df_proj) == "category.project"] <- "Category"
  names(df_proj)[names(df_proj) == "instanceccategory.project"] <- "Instances"
  names(df_proj)[names(df_proj) == "freq.cinstancecategory.project"] <- "Frequency (%)"
  names(df_proj)[names(df_proj) == "hh.actccategory.project"] <- "Total Time Spent (Hours)"
  names(df_proj)[names(df_proj) == "avg.hhccategory.project"] <- "Average Time Spent (Hours)"
  names(df_proj)[names(df_proj) == "category.project.cpr"] <- "As a Proportion of Time Recorded (%)"
  df_proj
  
  df_proj <- formattable(df_proj, 
                         align =c("l","c","c","c","c", "c", "c", "c", "r"), 
                         list(`Indicator Name` = formatter(
                           "span", style = ~ style(color = "grey",font.weight = "bold")) 
                         ))
  
  df_proj <- formattable(df_proj, align =c("l","c","c","c","c", "c", "c", "c", "r"), list(
    `Category` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")), 
    `Instances`= color_tile(customGreen0, customGreen),
    `Frequency (%)`= color_tile(customGreen0, customGreen),
    `Total Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `Average Time Spent (Hours)`= color_tile(customGreen0, customGreen),
    `As a Proportion of Time Recorded (%)`= color_tile(customGreen0, customGreen)
  ))
  
  df_proj
  
  #--------------------#
  # PART 6: PAGE 1 #--------------------------------------------
  #--------------#
  
  #WORD CLOUD
  
  excludeWords <- c("a", "the", "that", "an", "at", "by", "for", "from", "of", "off", "on", "out", "through", "with")
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
  wordcloud(d$word,d$freq, min.freq=1, max.words=300,
            random.order=FALSE, rot.per=0.35, 
            use.r.layout=FALSE)
  
  invisible(list(tdm=tdm, freqTable = d))
  
  
  jpeg(file.path(outputRaw, "wordcloud.jpg")) 
  wordcloud <-    wordcloud(activity,
                            min.freq = 1,  max.words = 300)
  dev.off()
  
  avg_act_dur <- round(mean(unlist(subset(tud, caseid == case,
                                          select = c(activity.duration)))))
  
  save.image("~/GitHub/Agile_Productivity_Radar/DataWork/Task Allocation Check in/Report/Dummy/Code/R Markdown/backend.RData")
  
  rmarkdown::render("~/GitHub/Agile_Productivity_Radar/DataWork/Task Allocation Check in/Report/Dummy/Code/R Markdown/Report_dummy.Rmd",
                    output_file =  paste("report_", case, '_', Sys.Date(), ".pdf", sep=''), 
                    output_dir = 'C:/Users/wb522556/WBG/Vincenzo Di Maro - Agile/06 - Agile Productivity Radar/DataWork/Task Allocation Check in/Report/Dummy/Outputs/Final')
}
