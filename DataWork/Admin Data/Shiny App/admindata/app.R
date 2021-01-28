#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# LIST OF REQUIRED PACKAGES -----------------------------------------------

required_packages <- c(
    "AMR",
    "data.table",
    "DT",
    "ggridges",
    "lubridate",
    "plotly",
    "qicharts2",
    "rintrojs",
    "shiny",
    "shinyBS",
    "shinycssloaders",
    "shinydashboard",
    "shinyjs",
    "shinyWidgets",
    "survival",
    "survminer",
    "tidyverse",
    "viridis",
    "zoo"
)

# install missing packages

new.packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(new.packages)) {
    install.packages(new.packages)
}

# load all packages
lapply(required_packages, require, character.only = TRUE)

# Defining fluid design function
fluid_design <- function(id, a, w, x, y, z) {
    fluidRow(
        div(
            id = id, 
            column(
                width = 12,
                uiOutput(a)
                ),
            column(
                width = 6,
                uiOutput(w),
                uiOutput(y)
            ),
            column(
                width = 6,
                uiOutput(x),
                uiOutput(z)
            )
        )
    )
}

# IMPORTING HELP FILES
steps <- read_csv2("help.csv")

# Define UI-------
ui <- dashboardPage(
    skin = "black",
    title = "World Bank Diagnostics",
    
    # HEADER ------------------------------------------------------------------
    
    # HEADER ON TOP-LEFT--------------
    dashboardHeader(
        title = span(img(src = "dime_logo.png", height = 35), "World Bank Diagnostics"),
        titleWidth = 300,
    
    # HELP DROPDOWN MENU--------------
    dropdownMenu(
        type = "notifications", 
        headerText = strong("HELP"), 
        icon = icon("question"), 
        badgeStatus = NULL,
        notificationItem(
            text = (steps$text[1]),
            icon = icon("spinner")
        ),
        notificationItem(
            text = steps$text[2],
            icon = icon("address-card")
        ),
        notificationItem(
            text = steps$text[3],
            icon = icon("calendar")
        ),
        notificationItem(
            text = steps$text[4],
            icon = icon("user-md")
        ),
        notificationItem(
            text = steps$text[5],
            icon = icon("ambulance")
        ),
        notificationItem(
            text = steps$text[6],
            icon = icon("flask")
        ),
        notificationItem(
            text = strong(steps$text[7]),
            icon = icon("exclamation")
        )
    ),
    
    # ABOUT DIME ON TOP-RIGHT
    tags$li(
        a(
            strong("ABOUT DIME"),
            height = 40,
            href = "https://www.worldbank.org/en/research/dime",
            title = "",
            target = "_blank"
        ),
        class = "dropdown"
    )
),
    
    # SIDEBAR -----------------------------------------------------------------
    
    dashboardSidebar(
        width = 300,
                 sidebarMenu(
                     div(class = "inlay", style = "height:15px;width:100%;background-color: #ecf0f5;"),
                         radioButtons(
                             inputId = "timeperiodInput",
                             label = "TIME PERIOD",
                             choices = c("All Years", "Past 20 Years", "Past 15 Years", "Past 10 Years", "Past 5 Years"),
                             selected = "All Years",
                             inline = TRUE
                         ),
                         checkboxGroupInput(
                             inputId = "regionsInput",
                             label = "REGIONS",
                             choices = c("All", "Africa (AFR)", "East Asia and Pacific (EAP)", "Europe and Central Asia (ECA)", 
                                         "Latin America and Caribbean (LAC)", "Middle East and North Africa (MENA)", "South Asia (SAR)"),
                             selected = "All",
                             inline = TRUE
                         ),
                        checkboxGroupInput(
                            inputId = "practicegroupInput",
                            label = "PRACTICE GROUP",
                            choices = c("All", "Equitable Growth, Finance and Institutions (GGE)", "Human Development (GGH)", 
                                        "Infrastructure (GGI)", "Sustainable Development (GGS)"),
                            selected = "All",
                            inline = TRUE
                        ),
                        checkboxGroupInput(
                            inputId = "projectstatusInput",
                            label = "PROJECT STATUS",
                            choices = c("All", "Closed", "Active"),
                            selected = "All",
                            inline = TRUE
                        ),
                        checkboxGroupInput(
                            inputId = "projectstatusInput",
                            label = "PROJECT CATEGORY",
                            choices = c("All", "Lending", "Analytical"),
                            selected = "All",
                            inline = TRUE
                        ),
                    menuItem(
                         "YEAR",
                         tabName = "year",
                         icon = icon("calendar"),
                         checkboxGroupInput(
                             inputId = "yearInput",
                             label = "YEAR",
                             choices = c("All", "2000", "2001", "2002", "2003", "2004", "2005", "2006",
                                         "2007","2008", "2009", "2010", "2011", "2012", "2013", "2014",
                                         "2015","2016", "2018", "2019"),
                             selected = "All Years",
                             inline = TRUE
                         )
                     ),
                    menuItem(
                        "PRACTICE",
                        tabName = "practice",
                        icon = icon("chart-line"),
                        checkboxGroupInput(
                            inputId = "practiceInput",
                            label = "PRACTICE",
                            choices = c("All", "Finance, Competitiveness & Innovation", "Governance", "Macroeconomics, Trade & Investment", 
                                        "Poverty & Equity", "Education", "Gender", "Health, Nutrition & Population", "Social Protection & Jobs",
                                        "Agriculture", "Climate Change", "Environment & Natural Resources", "Social, Urban, Rural & Resilience",
                                        "Water", "Energy & Extractives", "Infrastructure, PPPs & Guarantees", "Transport & Digital Development"),
                            selected = "All",
                            inline = TRUE
                        )
                    ),
                    menuItem(
                        "Select Y Variable",
                        tabName = "yvariable",
                        icon = icon("chart-line"),
                        checkboxGroupInput(
                            inputId = "yvariableInput",
                            label = "Select Y Variable",
                            choices = c("All", "Finance, Competitiveness & Innovation", "Governance", "Macroeconomics, Trade & Investment", 
                                        "Poverty & Equity", "Education", "Gender", "Health, Nutrition & Population", "Social Protection & Jobs",
                                        "Agriculture", "Climate Change", "Environment & Natural Resources", "Social, Urban, Rural & Resilience",
                                        "Water", "Energy & Extractives", "Infrastructure, PPPs & Guarantees", "Transport & Digital Development"),
                            selected = "All",
                            inline = TRUE
                        )
                    ),
                    menuItem(
                        "Select X Variables - Multiple Choice",
                        tabName = "xvariable",
                        icon = icon("chart-line"),
                        checkboxGroupInput(
                            inputId = "xvariableInput",
                            label = "Select X Variable - Multiple Choice",
                            choices = c("All", "Finance, Competitiveness & Innovation", "Governance", "Macroeconomics, Trade & Investment", 
                                        "Poverty & Equity", "Education", "Gender", "Health, Nutrition & Population", "Social Protection & Jobs",
                                        "Agriculture", "Climate Change", "Environment & Natural Resources", "Social, Urban, Rural & Resilience",
                                        "Water", "Energy & Extractives", "Infrastructure, PPPs & Guarantees", "Transport & Digital Development"),
                            selected = "All",
                            inline = TRUE
                        )
                    )
                  )
                 ),

    # BODY --------------------------------------------------------------------
    
        dashboardBody(
            tags$head(tags$style(HTML("
.btn-success {
    font-size: 18px;
    font-family: inherit;
    padding: 5px 12px;
    height: 55px;
    min-width: 15.85%;
    margin: 0px 10px 14px 20px;
    text-align: left;
    color: white;
    background: #25318a;
    text-indent: 4px;
    vertical-align: middle;
    border-radius: 0px;
    border-color: transparent;
    box-shadow: 0 2px 5px 0 rgba(0,0,0,0.18), 0 1px 5px 0 rgba(0,0,0,0.15);
    text-transform: uppercase;
    -webkit-transition: all 0.25s cubic-bezier(0.02, 0.01, 0.47, 1);
    transition: all 0.25s cubic-bezier(0.02, 0.01, 0.47, 1);
    -webkit-transform: translate3d(0, 0, 0);
    transform: translate3d(0, 0, 0);
}
.btn-success:hover {
    background-color:#42d7f5;
    font-size: 18px;
    font-family: inherit;
    padding: 5px 12px;
    height: 55px;
    min-width: 15.85%;
    margin: 0px 10px 14px 20px;
    text-align: left;
    color: black;
    text-indent: 4px;
    vertical-align: middle;
    border-radius: 0px;
    border-color: transparent;
    box-shadow: 0 5px 11px 0 rgba(0,0,0,0.18), 0 4px 15px 0 rgba(0,0,0,0.15);
    -webkit-transition: box-shadow 0.4s ease-out;
    transition: box-shadow 0.4s ease-out;
}
.btn-warning, .btn-warning:hover {
    font-size: 18px;
    font-family: inherit;
    padding: 5px 12px;
    height: 55px;
    min-width: 15.85%;
    margin: 0px 10px 14px 20px;
    text-align: left;
    color: white;
    background: #42d7f5;
    text-indent: 4px;
    vertical-align: middle;
    border-radius: 0px;
    border-color: transparent;
    box-shadow: 0 2px 5px 0 rgba(0,0,0,0.18), 0 1px 5px 0 rgba(0,0,0,0.15);
    text-transform: uppercase;
    -webkit-transition: all 0.25s cubic-bezier(0.02, 0.01, 0.47, 1);
    transition: all 0.25s cubic-bezier(0.02, 0.01, 0.47, 1);
    -webkit-transform: translate3d(0, 0, 0);
    transform: translate3d(0, 0, 0);
}
.fa {
    margin-right: 10px;
}
.fa.fa-gear.opt {
    margin-right: 0px;
}
.fa.fa-search-plus.opt {
    margin-right: 0px
}
#intro {
    margin-bottom: 0;
    align-items: center;
    display: block;
    margin: 0 auto;
    background: #25318a;
    color: white;
    min-width: 25%;
    border-color: white
}
#sidebar_button {
    height: 55px;
}
section.sidebar .shiny-bound-input.action-button, section.sidebar .shiny-bound-input.action-link {
    margin: auto;
    display: block;
}
.btn-danger {
    background-color: #25318a;
    border-color: #25318a;
    height: 55px;
    width: 300px;
    border-radius: 0;
    position: relative;
    font-size: 18px;
}
.btn-primary {
    background-color: #25318a;
    border-color: #25318a;
    color: white;
    height: 55px;
    width: 300px;
    border-radius: 0;
    position: relative;
    font-size: 18px;
}
.btn-primary:hover {
    background-color: #427bf5;
    border-color: #427bf5;
    color: white;
    border-color: #427bf5;

}
.fa.fa-user, .fa.fa-thumbs-o-up, .fa.fa-flask.flask-box, .fa.fa-spinner.spinner-box {
    color: white;
    font-size: 20;
    margin-right: 10px;
    font-size: 30px;
    vertical-align: middle;
}

.skin-black .treeview-menu > li > a {
    color: white;
    white-space: pre-line;
}
.skin-black .treeview-menu > li:hover > a {
    color: white;
    white-space: pre-line;
    background-color:white;;
}


 .info-box {
     min-height:55px;
     float:center;
     box-shadow:5px 5px 5px lightgrey;
     border-bottom: 0px;
 }
}
 .info-box-icon.bg-black {
     height:55px; 
}
.bg-black {
    background-color: white !important;
    height: 55px;
    line-height:55px;

}
.text-success {
    color: #25318a;
    font-size: large;

}
 .skin-black .main-header .navbar {
     background-color:#25318a 
}
 .skin-black .main-header .navbar .nav > li > a {
     color:#ffffff 
}
 .skin-black .main-header .navbar .nav > li > a:hover {
     background:#42d7f5;
     color:black
}
 .skin-black .main-header .navbar .sidebar-toggle {
     color:#ffffff 
}
 .skin-black .main-header .navbar .sidebar-toggle:hover {
     color: black;
     background:#42d7f5 
}
 .skin-black .main-header .navbar .navbar-custom-menu .navbar-nav > li > a, .skin-black .main-header .navbar .navbar-right > li > a {
     border-left:1px solid white;
     border-right-width:0 
}
 .modal-dialog{
     max-width:1000px;
     border-radius: 5px;
     border: 2px solid white; 
}
 .modal-body{
     max-height:700px;
     align-content:center;
     border: 2px solid white;
     border-radius: 5px;
}
 .modal-sm {
     max-width:1200px; 
     align-content:center;
     border-radius: 5px;
     border: 2px solid white;
}
 .sidebar {
     height:90vh;
     overflow-y:auto 
}
 .skin-black .main-header > .logo {
     background-color:#25318a;
     color:#ffffff;
     border-bottom:0 solid transparent;
     border-right:1px solid white;
}
 .skin-black .main-header > .logo:hover {
     background-color:#42d7f5;
     color: black
}
 .nav-tabs-custom > .nav-tabs > li.active {
     border-top-color:#42d7f5 
}
 .nav-tabs-custom {
     box-shadow:5px 5px 5px lightgrey 
}
 .skin-black .left-side, .skin-black .main-sidebar, .skin-black .wrapper {
     background-color:#25318a;
}
 .skin-black .sidebar-menu > li.active > a, .skin-black .sidebar-menu > li:hover > a {
     color:black;
     background:#42d7f5;
     border-left-color: #42d7f5;
}
 .skin-black .sidebar-menu > li > .treeview-menu {
     margin:0 1px; 
     background:white;
     box-shadow:inset 0px 0px 7px #000000;
     padding-bottom:2px 
}
 .skin-black .sidebar a {
     color: white
}
.navbar-nav > .messages-menu > .dropdown-menu, .navbar-nav > .notifications-menu > .dropdown-menu, .navbar-nav > .tasks-menu > .dropdown-menu {
    width: 400px;
    padding: 0;
    margin: 10px;
    top: 100%;
    background-color: lightgray;
    color: black
    box-shadow: 10px 10px 10px darkgrey;
}
.navbar-nav > .messages-menu > .dropdown-menu > li.header, .navbar-nav > .notifications-menu > .dropdown-menu > li.header, .navbar-nav > .tasks-menu > .dropdown-menu > li.header {
    border-top-left-radius: 0px;
    border-top-right-radius: 0px;
    border-bottom-right-radius: 0;
    border-bottom-left-radius: 0;
    background-color: #25318a;
    padding: 7px 10px;
    border-bottom: 1px solid #25318a;
    color: black;
    font-size: 14px;
}
.navbar-nav > .messages-menu > .dropdown-menu > li .menu, .navbar-nav > .notifications-menu > .dropdown-menu > li .menu, .navbar-nav > .tasks-menu > .dropdown-menu > li .menu {
    max-height: 1200px;
    margin: 0;
    padding: 0;
    list-style: none;
    overflow-x: hidden;
}
.navbar-nav > .notifications-menu > .dropdown-menu > li .menu > li > a {
    color: black;
    overflow: hidden;
    white-space: normal;
}
 #coxreg {
     overflow-y: auto;
     max-height: 200px;
     background-color: lightgrey;
     box-shadow: inset 0px -5px 5px darkgrey 
}
 #coxreg_aic {
     background-color: lightgrey 
}
 #logreg {
     overflow-y: auto;
     max-height: 200px;
     background-color: lightgrey;
     box-shadow: inset 0px -5px 5px darkgrey 
}
 #logreg_aic {
     background-color: lightgrey 
}
.shiny-output-error { 
    visibility: hidden; 
}
.shiny-output-error:before { 
    visibility: hidden; 
}
 "))),
        # MAIN BODY ---------------------------------------------------------------
        
        fluidRow(
            column(
                width = 12,
                introBox(
                    bsButton("timeliness", 
                             label = "TIMELINESS", 
                             icon = icon("clock"), 
                             style = "success"),
                    bsButton("costliness", 
                             label = "COSTLINESS", 
                             icon = icon("funnel-dollar"), 
                             style = "success"),
                    bsButton("quality", 
                             label = "QUALITY", 
                             icon = icon("award"), 
                             style = "success"),
                    bsButton("effectiveness", 
                             label = "EFFECTIVENESS", 
                             icon = icon("thumbs-o-up"), 
                             style = "success"),
                    bsButton("correlations", 
                             label = "EXPLORE CORRELATIONS", 
                             icon = icon("chart-line"), 
                             style = "success"))
            ),
        fluid_design("timeliness_panel", "select", "box1", "box2", "box3", "box4"),
        fluid_design("costliness_panel", "select", "box5", "box6", "box7", "box8"),
        fluid_design("quality_panel", "select", "box9", "box10", "box11", "box12"),
        fluid_design("effectiveness_panel", "select", "box13", "box14", "box15", "box16"),
        fluid_design("correlations_panel", "select", "box17", "box18", "box19", "box20"),
    )
))
# SERVER CODE
server <- function(input, output, session) {
    
    # use action buttons as tab selectors
    update_all <- function(x) {
        updateSelectInput(session, "tab",
                          choices = c("", "TIMELINESS", "COSTLINESS", "QUALITY", "EFFECTIVENESS", "CORRELATIONS"),
                          label = "",
                          selected = x
        )
    }
    observeEvent(input$timeliness, {
        update_all("TIMELINESS")
    })
    observeEvent(input$costliness, {
        update_all("COSTLINESS")
    })
    observeEvent(input$quality, {
        update_all("QUALITY")
    })
    observeEvent(input$effectiveness, {
        update_all("EFFECTIVENESS")
    })
    observeEvent(input$correlations, {
        update_all("CORRELATIONS")
    })       
    # hide the underlying selectInput in sidebar for better design
    observeEvent("", {
        hide("tab")
   })
    
    # DYNAMIC RENDER RULES ----------------------------------------------------
    
    observeEvent("", {
        show("timeliness_panel")
        hide("costliness_panel")
        hide("quality_panel")
        hide("effectiveness_panel")
        hide("correlations_panel")
    }, once = TRUE)
    
    observeEvent(input$timeliness, {
        show("timeliness_panel")
        hide("costliness_panel")
        hide("quality_panel")
        hide("effectiveness_panel")
        hide("correlations_panel")
    })
    observeEvent(input$costliness, {
        hide("timeliness_panel")
        show("costliness_panel")
        hide("quality_panel")
        hide("effectiveness_panel")
        hide("correlations_panel")
    })
    observeEvent(input$quality, {
        hide("timeliness_panel")
        hide("costliness_panel")
        show("quality_panel")
        hide("effectiveness_panel")
        hide("correlations_panel")
    })
    observeEvent(input$effectiveness, {
        hide("timeliness_panel")
        hide("costliness_panel")
        hide("quality_panel")
        show("effectiveness_panel")
        hide("correlations_panel")
    })
    observeEvent(input$correlations, {
        hide("timeliness_panel")
        hide("costliness_panel")
        hide("quality_panel")
        hid("effectiveness_panel")
        show("correlations_panel")
    })
    
    # show active button with color  
    observeEvent(input$tab, {
        x <- input$tab
        updateButton(session, "timeliness", style = {
            if (x == "TIMELINESS") {
                paste("warning")
            } else {
                paste("success")
            }
        })
        updateButton(session, "costliness", style = {
            if (x == "COSTLINESS") {
                paste("warning")
            } else {
                paste("success")
            }
        })
        updateButton(session, "quality", style = {
            if (x == "QUALITY") {
                paste("warning")
            } else {
                paste("success")
            }
        })
        updateButton(session, "effectiveness", style = {
            if (x == "EFFECTIVENESS") {
                paste("warning")
            } else {
                paste("success")
            }
        })
        updateButton(session, "correlations", style = {
            if (x == "CORRELATIONS") {
                paste("warning")
            } else {
                paste("success")
            }
        })
    })
    
    # SELECTION TEXT-------------------

    output$select1 <- renderUI({
        div(
            style = "position: relative",
            tabBox(
                id = "select",
                width = NULL,
                height = 400,
                tabPanel(
                    title = "Subspecialties - table",
                    htmlOutput("selection"),
                )
                )
            )
    })
    output$selection <- 
    renderText({
        HTML(
            paste("Your Selections:", 
                  strong(
                      unique(
                          paste(input$year) %>% 
                              length()
                      )
                  )
            )
        )
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
