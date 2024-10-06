[![License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/nragland37/Student-Time-Analysis-Tool/blob/main/LICENSE)

<h1 align="center">
  Student Time Analysis
</h1>

<p align="center">
  <a href="https://nragland37.shinyapps.io/timeanalysis/" target="_blank">
    <img src="assets/shiny-demo.gif" alt="Student Time Analysis Application"> 
  </a>
</p>

<p align="center">
  <a href="https://nragland37.shinyapps.io/timeanalysis/" target="_blank"><b>Live Application</b></a> 
</p>

This application visualizes student availability during breaks between classes using interactive heatmaps. It helps identify periods when students are free, enabling institutions to optimize event timing and boost student involvement. The tool features a variety of filtering options to target specific groups, such as departments or degree programs, allowing for tailored event planning for different groups of students.  

## Features

- **Interactive Heatmap Visualization**: Displays student availability dynamically across various times and days.
- **Customizable Filters**: Filter data by semester term, day of the week, class level, major, concentration, department, and more.
- **Flexible Time Increments**: Adjust the maximum gap and time increment settings to suit specific analysis needs.
- **Color Palette**: Utilizes the 'viridis' color palette for clear, accessible data representation.

## Data Cleaning and Preparation

- **Filtering Online and Invalid Classes**: Excludes entries with invalid times or day formats to focus on in-person classes.
- **Time Conversion**: Transforms integer times (e.g., 0900) into time objects for precise calculations.
- **Standardizing Days**: Expands and renames day codes (MTWRF) into readable formats (Mon, Tues).
- **Calculating and Filtering Gaps**:Computes class gaps and filters out negative or zero values to analyze only meaningful gaps.
- **Term-Based Segmentation**: Segments data by academic terms while accounting for full-term classes.
- **Time Interval Alignment**: Maps student availability gaps to every second of the day, creating highly detailed intervals for precise visualization of free time patterns.

## File Structure

- `global.R`: Contains global variables and functions that are shared across the UI and server components.
- `server.R`: Defines the server-side logic of the application, including data processing and reactive expressions.
- `ui.R`: Describes the user interface of the application, including layout, input controls, and visual output elements.

## Getting Started

### Prerequisites

1. **Download and Install R**: [Here](https://cran.r-project.org/)
2. **Required Packages**:
```R
install.packages(c("tidyverse", "hms", "lubridate", "viridis", "shiny", "plotly"))
```
3. **Data File**: Create and properly format the student_data.csv

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nragland37/student-time-analysis.git
   cd student-time-analysis
   ```
2. **Launch the application**:
   ```R
   runApp()
   ```
   Alternatively, run directly from the command line:
   ```bash
   Rscript -e 'shiny::runApp()'
   ```

> [!IMPORTANT]  
>  To protect privacy, the original CSV file is not included. Create `student_data.csv` and place it in the same directory as `global.R` with the following format:
> ```
> id, sess, yr, cl, major1_majortext, major1_conctext, crs_dept, days, beg_tm, end_tm, beg_date, end_date
> 123456, FA, 2023, SO, Business Administration, Finance, BUSN, --M-W-F-, 0900, 0950, 2023-01-16, 2023-05-12
> 234567, SP, 2023, JR, Computer Science, Cybersecurity, COSC, --T-R--, 1000, 1120, 2023-01-16, 2023-05-12
> 345678, SU, 2023, SR, Psychology, None assigned, PSYC, --M-W---, 1300, 1420, 2023-06-01, 2023-07-15
> ```
