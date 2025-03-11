# ✅ PROJECT-11

In this project, a comprehensive report was developed to monitor and track User Acceptance Testing (UAT) activities applied to a forecasting and demand-planning application within an industrial context. The company implemented a web-based Shiny (R) application aimed at centralizing and simplifying access to information regarding product consumption and shipment forecasts. The methodology adopted prioritized clarity and practicality, using interactive visuals to highlight key indicators and testing stages. Complementarily, a Power BI dashboard enabled real-time tracking of the UAT process, providing complete visibility from initiation through to the conclusion of tests. Thus, the report not only facilitated monitoring activities but also played a crucial role in identifying, categorizing, and addressing defects reported by users, ensuring continuous improvement before the application's final deployment.

**Keywords**: UAT, Business Analytics, Data Visualization, Data Analysis, R, Shinny, PowerBI, PowerQuery, DAX.

# ✅ PROCESS

The project began with approximately ten users responsible for conducting the acceptance tests on the Shiny application. Each user was provided with individual files to systematically document identified defects. To optimize data management and centralize feedback, an R script was developed to consolidate and organize the information gathered from all users. This script performed two fundamental tasks: firstly, aggregating all individual defect reports, and secondly, automatically classifying these defects into two distinct categories by leveraging a ChatGPT 4.5 API integration. 

The first category was segmented into four key areas: **Calculation Error**, **Visualization Issue**, **Format Modification** and **Mapping Alignment**. The second category condensed the reported issue into a concise description limited to four words, facilitating rapid identification. For example, a detailed issue initially described as *"Validating whether the waterfall chart accurately represents the volume. The chart should reflect the correct values based on backend data, and calculations must align with the defined aggregation rules. Currently, only some of the numbers match correctly"* would be categorized primarily as **Visualization Issue** and summarized as **"Waterfall Chart Volume Calculation Discrepancy."**

In addition to defect categorization, the R script also aggregated information about user progress through their respective test cases, verifying that all planned functionalities were thoroughly tested. This analysis allowed clear visibility into user engagement and the overall quality of the validation process.As outputs from this process, the script generated two primary data files: one containing the detailed categorization of defects and another tracking the users' progress through their assigned test activities. These files served as critical inputs for the final Power BI report, which leveraged DAX measures and interactive visualizations to efficiently and intuitively track the entire UAT process.

# ✅ CONCLUSION

Ultimately, the report delivered was structured into two main sections. The first provided a consolidated view of defects identified throughout the UAT process, clearly highlighting the total number of defects found (202), classified into open (64), in-progress (40), and resolved (98) categories. Interactive charts presented defect categorization percentages, revealing that most issues related to calculation errors (59%), followed by mapping alignment (26%), visualization issues (10%), and format modifications (4%). This section also analyzed defect criticality—47% rated as high—and clearly identified the most active users reporting defects, facilitating prioritization and corrective actions.

![Screen Recording 2025-03-11 at 20 41 22](https://github.com/user-attachments/assets/c7d38678-52d2-4cb0-999c-1d46990707b0)

The second page provided detailed insights into user progress with their testing activities, organized into specific categories (Functionality, Drivers, and Export tests). DAX-based metrics were employed to calculate real-time completion percentages, indicating an overall test completion rate of approximately 64%, with notable completion rates in Export tests (67.86%) and Drivers tests (65.45%). Furthermore, this visualization made it easy to identify the users excelling in their testing activities, effectively assessing test efficacy and ensuring comprehensive application validation before final implementation.

![Screen Recording 2025-03-11 at 20 42 18](https://github.com/user-attachments/assets/aab179a6-6725-43a9-a6ee-3b2306765166)

In conclusion, the resulting report delivered an efficient and intuitive platform for monitoring the entire UAT process. It significantly contributed to rapidly identifying issues and provided essential information to support developers in prioritizing and resolving defects. Consequently, the project not only enhanced the quality of the developed application but also substantially improved communication and collaboration between technical teams and end-users.

**Dashboard**: https://app.powerbi.com/reportEmbed?reportId=07bbc222-fc54-4901-ab41-64948f2260d0&autoAuth=true&ctid=d69a7783-e937-4232-ba85-2098408382c8
