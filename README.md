# Brett Maddry Project Portfolio

## About
I’m a data-driven professional with experiences spanning demand forecasting and business analytics. Over the past six years, I’ve managed forecasts and financial plans for high-volume product categories at Crate & Barrel and Abercrombie & Fitch, overseeing portfolios exceeding $150 million annually.

Currently, I'm pursuing my Masters of Business Analytics at UW-Madison to further expand and grow into the machine learning, predictive analytics, and data visualization space. In my career outside of data, I'm also passionate about leading and mentoring others, along with building collaborative cross-functional relationships.

This portfolio was built to highlight my technical skills and includes projects inside of Machine Learning, Generalized Linear Models, Pyomo Optimization, SQL, Tableau and AWS. My personal interest in sports analytics is reflected in a handful of projects, and I'm currently designing a model to generate odds for NHL regaular season games. Feel free to come back soon if you're interested!

## Table of Contents

* About

* Portfolio Projects
  * Python
      * Credit Card Fraud Classification
      * Housing Prices Prediction
      * Scheduling Optimization
  * SQL
      * EV Charging Analytics
      * Rideshare Data Modeling
  * Tableau
  * AWS
* Education
* Contact

## Portfolio Projects
In this section the projects will be briefly described, and the technology used to complete each task will be noted.

### Credit Card Fraud Classification
**Code:**

**Description:** Machine Learning models is used in this project to accurately predict cases of credit card fraud. The training dataset has roughly 285,000 transactions, and just 0.17% of these transactions are fraudulent. When building the models, a logistic regression GLM is first used to provide a baseline, before switching to Random Forests and XGBoost. F1, Precision and Recall are both used as evaluation criteria, as the True Positive Rate and False Positive Rate are both important in this dataset.

**Skills:** Random Forests, XGBoost, Data Cleaning, Feature Engineering, Class Imbalance Handling, Grid Search

**Technology:** Python, Pandas, Numpy, Seaborn, Scikit-Learn

### Housing Prices Prediction
**Code:**

**Description:** This project uses Generalized Linear Models (GLMs) to predict the selling price for homes listed for sale in Ames, Iowa. There are 80 initial features, so this dataset requires extensive data cleaning and strong feature engineering. To generate predictions, OLS with cross validation is used as the baseline model before proceeding to Lasso with cross validation, with RMSE as the evaluation criteria.

**Skills:** GLM Modeling, Data Cleaning, Feature Engeineering, Scaling, Cross Validation, Model Comparison

**Technology:** Python, Pandas, Numpy, Seaborn, Scikit-Learn

### Scheduling Optimization
**Code:**

**Description:** This project focuses on finding the solution for a Mixed Integer Linear Programming (MILP) problem using Pyomo and CBC solver, to optimize scheduling for athletic events. This was inspired by the challenge of high school teams in Northern Wisconsin, having to travel over 100 miles for interconference play. This approach is also highly transferable for logistics and supply chain fleet optimization problems.

**Skills:** MILP, Constraint Programmming, Optimization

**Technology:** Python, Pyomo, Pandas, CBC Solver
