# Brett Maddry Project Portfolio

## About
I’m a data-driven professional with experiences spanning demand forecasting and business analytics. Over the past six years, I’ve managed forecasts and financial plans for high-volume product categories at Crate & Barrel and Abercrombie & Fitch, overseeing portfolios exceeding $150 million annually.

Currently, I'm pursuing my Masters of Business Analytics at UW-Madison to further expand and grow my technical skills inside SQL, data visualization and machine learning. In my career outside of data, I'm passionate about leading and mentoring others, along with building collaborative cross-functional relationships.

This portfolio was built to highlight my technical skills and includes projects inside of Machine Learning, Generalized Linear Models, SQL, Tableau and AWS. My personal interest in sports analytics is reflected in a handful of projects, and I'm currently designing a model that generate odds for NHL regular season games. Feel free to come back soon if you're interested!

## Table of Contents

* [About](#about)

* [Portfolio Projects](#portfolio-projects)
  * Python
      * [Credit Card Fraud Classification](#credit-card-fraud-classification)
      * [Housing Prices Prediction](#housing-prices-prediction)
      * [Scheduling Optimization](#scheduling-optimization)
  * SQL
      * [EV Charging Analytics](#ev-charging-analytics)
      * [Rideshare Data Modeling](#rideshare-data-modeling)
  * [Tableau](#tableau)
  * [AWS](#aws)
* [Education](#education)
* [Contact](#contact)

## Portfolio Projects
In this section the portfolio projects will be briefly described, and the technology used to complete the project will be noted.

### Credit Card Fraud Classification
**Code:** [`ML Credit Card Fraud Classification.ipynb`](https://github.com/bmaddry/Data_Analytics_Portfolio/blob/main/Python/ML_Credit_Fraud_Prediction.ipynb)

**Description:** Machine Learning models are used in this project to accurately predict cases of credit card fraud. The training dataset has roughly 285,000 transactions, and just 0.17% of these transactions are fraudulent. When building the models, a logistic regression GLM is first used to provide a baseline, before switching to Random Forests and XGBoost. F1, Precision and Recall are both used as evaluation criteria, as the True Positive Rate and False Positive Rate are both important in this dataset.

**Skills:** Random Forests, XGBoost, Data Cleaning, Feature Engineering, Class Imbalance Handling, Grid Search

**Technology:** Python, Pandas, Numpy, Seaborn, Scikit-Learn


### Housing Prices Prediction
**Code:** [`GLM Housing Prices Prediction.ipynb`](https://github.com/bmaddry/Data_Analytics_Portfolio/blob/main/Python/GLM_Housing_Prices_Prediction.ipynb)

**Description:** This project uses Generalized Linear Models (GLMs) to predict the selling price for homes listed for sale in Ames, Iowa. There are 80 initial features, so this dataset requires extensive data cleaning and strong feature engineering. To generate predictions, OLS with cross validation is used as the baseline model before proceeding to Lasso with cross validation, with RMSE as the evaluation criteria.

**Skills:** GLM Regression, Data Cleaning, Feature Engeineering, Data Scaling, Cross Validation

**Technology:** Python, Pandas, Numpy, Seaborn, Scikit-Learn


### Scheduling Optimization
**Code:** [`Pyomo Scheduling Optimization.ipynb`](https://github.com/bmaddry/Data_Analytics_Portfolio/blob/main/Python/Pyomo_Scheduling_Optimzation.ipynb)

**Description:** This project focuses on finding the solution for a Mixed Integer Linear Programming (MILP) problem using Pyomo and CBC solver, to optimize scheduling for athletic events. This was inspired by the challenge of high school teams in Northern Wisconsin, having to travel over 100 miles for interconference play. This approach is also highly transferable for logistics and supply chain fleet optimization problems.

**Skills:** MILP, Constraint Programmming, Data Modeling, Scenario Analysis, Optimization

**Technology:** Python, Pyomo, CBC Solver, Google Colab


### EV Charging Analytics
**Code:** [`EV Charging Analytics.sql`](https://github.com/bmaddry/Data_Analytics_Portfolio/blob/main/SQL/EV_Charging_Analytics.sql)

**Description:** This SQL script involves loading and cleaning data from AWS S3, while performing role based access control and resource monitoring. Queries explore the problem of cars idling at electric vehicle (EV) charging stations, and use Snowflake AI to explore customer sentiment analysis regarding the issue.

**Skills:** Data Cleaning, ETL, Data Governance, Snowflake AI, Text Analytics, Window Functions, CTEs

**Technology:** SQL, Snowflake, AWS S3


### Rideshare Data Modeling
**Code:** [`Rideshare Data Modeling.sql`](https://github.com/bmaddry/Data_Analytics_Portfolio/blob/main/SQL/Rideshare_Data_Modeling.sql)

**Description:** The goal of this project is to build a consolidated view of KPIs for a rideshare service. In addition to loading and cleaning data from AWS S3, semi-structured JSON data is also handled. Functions used to explore the data and create the view include CTEs, window functions, joins, CASE logic and date/time functions.

**Skills:** Data Cleaning, ETL, Semi-Structured Data Handling, CTEs, Window Functions, Joins, Views

**Technology:** SQL, Snowflake, AWS S3


### Tableau
**Link:** [`Tableau Public Dashboards`](https://public.tableau.com/app/profile/brett.maddry/vizzes)

**Description:** Two dashboards in the above link were created using Tableau Public -- one analyzes the global health trends following the COVID outbreak in 2020, and another explores statistics regarding College Football fight songs. Both are created to give the user an interactive experience, and contain calculated fields.

**Skills:** Data Visualization, Exploratory Data Analysis, Calcultated Fields, Interactive Dashboard Design

**Technology:** Tableau, SQL, Excel, CSV


### AWS
**Link:** [`AWS Cloud Data Architecture Presentation`](https://go.screenpal.com/watch/cT6e0VnDKVR)

**Description:** This project contains a video presentation of an end-to-end AWS cloud architecture for financial analytics, automated for future use. Includes steps such as loading the data with S3, using Glue to perform ETL, creating a data warehouse with Redshift for scalability, and performing machine learning with SageMaker.

**Skills:** Cloud Data Architecture, ETL, Data Warehousing, Data Lake Management, Machine Learning

**Technology:** AWS S3, AWS Glue, AWS Redshift, AWS SageMaker, SQL

## Education
**University of Wisconsin-Madison:** Master of Science - MS, Business Analytics, Expected May 2026

**University of Wisconsin-Madison:** Bachelor of Arts - BA, Economics and International Studies, 2015-2019

## Contact
* LinkedIn: [@brettmaddry](https://www.linkedin.com/in/brett-maddry/)
* Email: [bamaddry@gmail.com](mailto:bamaddry@gmail.com)
