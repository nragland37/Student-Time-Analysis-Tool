<h1 align="center">
  Student Time Analysis
</h1>

<p align="center">
  Application for visualizing student availability to optimize university involvement
</p>

<p align="center">
  Built with <a href="https://www.r-project.org/" target="_blank">R</a> and hosted on <a href="https://www.shinyapps.io/" target="_blank">ShinyApps.io</a>
</p>

![Demo](/assets/shiny-demo.gif)

This application visualizes student availability during breaks between classes using interactive heatmaps. It focuses on identifying periods when students are free, allowing institutions to optimize hosting events and getting students more involved. The tool features a variety of filtering options to target specific groups, such as departments or degree programs, allowing for tailored event planning. 

For instance, by adjusting the filters, one can identify optimal times for events like an art expo, ensuring attendance from art students who have classes with breaks in between. This approach effectively focuses on students present on campus during key times, rather than those without class schedules.

## Features

- **Interactive Heatmap Visualization**: Displays student availability dynamically across various times and days.
- **Customizable Filters**: Filter data by semester term, day of the week, class level, major, concentration, department, and more.
- **Flexible Time Increments**: Adjust the maximum gap and time increment settings to suit specific analysis needs.
- **Color Palette**: Utilizes the 'viridis' color palette for clear, accessible data representation.

## Data Cleaning and Preparation

Sophisticated data cleaning techniques ensure reliable analyses:

- **Filtering Online and Invalid Classes**: Excludes entries with invalid times or day formats to focus on in-person classes.
- **Time Conversion**: Transforms integer times (e.g., 0900) into time objects for precise calculations.
- **Standardizing Days**: Expands and renames day codes (MTWRF) into readable formats (Mon, Tues).
- **Calculating and Filtering Gaps**:Computes class gaps and filters out negative or zero values to analyze only meaningful gaps.
- **Term-Based Segmentation**: Segments data by academic terms while accounting for full-term classes.
- **Time Interval Alignment**: Maps student availability gaps to every second of the day, creating highly detailed intervals for precise visualization of free time patterns.

## File Structure

- `global.R`e: Contains global variables and functions that are shared across the UI and server components.
- `server.R`: Defines the server-side logic of the application, including data processing and reactive expressions.
- `ui.R`: Describes the user interface of the application, including layout, input controls, and visual output elements.

## Getting Started

### Prerequisites

- **R Installation**: Confirm that R is installed on your system. [Download R here](https://cran.r-project.org/).
- **Required Packages**: Install the necessary R packages:
  ```R
  install.packages(c("tidyverse", "hms", "lubridate", "viridis", "shiny", "plotly"))
  ```
- **Data File**: No real student data provided. For testing, create your own `student_data.csv` file.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nragland37/student-time-analysis.git
   ```
2. **Navigate to the project directory**:
   ```bash
   cd student-time-analysis
   ```

3. **Launch the application**:
   ```R
   runApp()
   ```
   Alternatively, run directly from the command line:
   ```bash
   Rscript -e 'shiny::runApp()'
   ```

## Data Information

The original student_data.csv file is not included to protect privacy. To run the application locally, create a CSV file with the following structure and sample data:

```
id, sess, yr, cl, major1_majortext, major1_conctext, crs_dept, days, beg_tm, end_tm, beg_date, end_date
123456, FA, 2023, SO, Business Administration, Finance, BUSN, --M-W-F-, 0900, 0950, 2023-01-16, 2023-05-12
234567, SP, 2023, JR, Computer Science, Cybersecurity, COSC, --T-R--, 1000, 1120, 2023-01-16, 2023-05-12
345678, SU, 2023, SR, Psychology, None assigned, PSYC, --M-W---, 1300, 1420, 2023-06-01, 2023-07-15
```

Note: Ensure that `student_data.csv` follows this format and is placed in the same directory as `global.R`
