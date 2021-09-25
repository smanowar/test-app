# Final Project: First Segment Project Deliverable

## Selected Topic: Stack Overflow Response Analysis

## Overview
As students who use stack overflow as a learning tool, we want data on the best times to be online and post our questions to get an approved answer quickly and keep our momentum as we learn. The purpose of this project is to determine the relationships between the features on Stack Overflow such as time of day, tags, question creation date in order to help users make the most of their studying time.

A preliminary blueprint of our presentation can be found <a href="https://docs.google.com/presentation/d/1rrRu6WyUEe1kYoVjOLN8hPOV4L5hi6HCDDpRM9sUu00/edit?usp=sharing
">here</a>.


## Data Sources
Our team is using the Stack Overflow Big Data dataset from Google Cloud Platform (GCP, formerly BigQuery). For the first segment, the GCP dataset served as the database. Due to the size of the sample data, a local database was not created at this stage. Sample data was pulled from GCP, and stored and manipulated within Pandas DataFrames. 

The Stack Overflow GCP dataset has several tables that store information about posts, users, badges, tags and other attributes. For this segment of the project, the team queried two tables to extract sample data necessary to test the Machine Learning model. These tables were the “post_questions” and “post_answers” tables. More tables will be queried for future segments of the project.

## Questions we hope to answer

- What are factors that lead to short times to approved answers?
- What is the mean time between question and approved answer?
- What is the median time between question and approved answer?
- What are the top ten times of day where the most questions are posed?
- What are the top ten times of day where the most approved answers are provided?
- What times of each day see response rates of less than an hour?
- What is the mean time between question and approved answer by tag?
- What is the median time between question and approved answer by tag?
- What is the correlation between tag popularity and time to an approved answer?
- What is the correlation between the number of tags and time to an approved answer? 
- Do the number of tags impact the number of approved responses?
- What is the correlation between the badged questions and time to an approved answer?

## Dashboard
A preliminary blueprint of our dashboard can be found <a href="https://docs.google.com/presentation/d/1rCYJeEAd7eyj60SLpaeW_T6C5_dfF-BDhmtVPSgCzog/edit#slide=id.gf110fddfbe_0_0">here</a>.

## Database
As mentioned above, the GCP Stack Overflow dataset serves as the database for the first segment of this project. By querying the “post_questions” and “post_answers” tables from GCP, we extracted a sample of data to perform Exploratory Data Analysis and cleaned and transformed it to provide the sample data needed to feed the Machine Learning model. 

### Exploratory Data Analysis

To create our sample database for further analysis and machine learning model, we queried from the Stack Overflow Data dataset obtained from BigQuery (Google Cloud Platform). 

As we are interested in a subset of this large data with 20 columns of data, we performed several queries and then cleaned the data to create a **post_questions** Pandas DataFrame that will provide insight on Stack Overflow questions:
Reduced scope of our data so that **question_creation_date** had data after January 1, 2021
Filtered data so we’re only dealing with questions that had an accepted answer (identified with a not null value under **accepted_answer_id**) 

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/post_questions.png>
  </p>

We performed similar steps to create a cleaned **post_answers** Pandas DataFrame that will provide insight on Stack Overflow answer statistics:
Reduced scope of our data so that **answer_creation_date** had data after ~May 1, 2021~ **January 1, 2021**

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/post_answers.png>
  </p>
 
### Database Component
  
We imported both DataFrames into our PostgreSQL database called **stackoverflow** as separate tables. We performed an inner join between the two tables to create a **duration** table using SQL. 

After creating the **duration** table, we read it directly into Jupyter Notebook as a DataFrame to perform several cleaning steps and transformations:
* Extracted the weekday from the question_creation_date and added a new column: 
  * question_day 
* Extracted the hour from the question_creation_date and added a new column:
  * question_hour 
* Subtracted answer_creation_date from question_creation_date (to calculate the duration between when a user gave an accepted answer to a question) and added a new column: 
  *  accepted_answer_duration 

After these transformations, we imported the DataFrame back into the database to replace the original **duration** table. The new **duration** table was merged with the **posts_questions** table to create a *ml_input* table which we would use for the machine learning model. 

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/database_tables.png>
  </p>

Please note that all queries are in the uploaded queries.sql file.

The following figure shows the ERD for the tables used in this segment of the project:

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/QuickDBD-export%20(1).png>
  </p>


## Machine Learning Component
### Supervised Machine Learning - Random Forest Classifier and EasyEnsemble Classifier

The question we originally intended to answer with the machine learning component of our project was:
<p align="center">
  <i><b>"What are factors that lead to short times to approved answers?"</b></i> 
</p>

However, after running the a linear regression model, the accuracy of the model was close to 0%. 

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/linear_regression_accuracy.PNG>
  </p>
  
We therefore decided to reframe our question such that it can be analyzed using a classification model, reframing the question as:
  <p align="center">
  <i><b>"When a user posts a question, will they get an accepted answer within 24 hours?"</b></i> 
</p>
  
To explore this we decided to use a Random Forest Classifer and an Easy Ensemble Classifer and compared our results. 
The notebook used for this analysis can be found in: *Code/ML_week2_RandomForest-EE.ipynb*

### *Data Preprocessing and Feature Selection*

In order to maximize accuracy in the model, our data needed to be normalized and outliers accounted for. Due to the size of our data set, we resolved this by binning a number of columns to allow the data to better fit the machine learning model.

The tags column was parsed to count the number of tags versus having data in string format. 

Lastly, columns that were not relevant to the question were dropped and NANs were also dropped. The final set of our features are as follows:

- **q_title_char_count**: number of characters in the title of the question
- **q_title_word_count**: number of words in the title of the question	
- **q_body_word_count**: number of words in the body of the question
- **q_tags_count**: number of tags associated with the question
- **q_hour**: hour of the day the question was posted
- **q_score_tier**: score of the question
- **q_view_count**: how many views the question has
- **q_day**: day of the week the quesion was posted

Our reasoning for the selected columns are as follows:

- the body and character count were considered key for the model because intuitivley the length of a question would allow for a more detailed question. This clarity and specification would inturn help produce an accepted answer. They also ranked as the top features on the feature importance.

- Date Time columns were used to analyze how time of day affects the likelihood of getting an accepted answer. The number of users using Stack Overflow fluctuates based on the date and time of day. Therefore, the time and date a question is posted can affect the visibility of the question and can result in an answer being posted sooner. 

- Another variable that can affect the visibility of a question is the tags that are included in a question. For this reason, the “tags” column was also chosen as a feature. For simplicity, the specific tags associated with the question were converted to the number of tags associated with the question. 


### *Random Forest Classifier*

We intially chose to use a Random Forest Classifier for many reasons including:
- model is flexible to both classification and regression problems
- works well with both categorical and continuous values
- allows us to analyze the inputs using feature_importance to make decisions on feature selection to improve accuracy

The *accepted_answer_duration* column was originally classified into 3 categories: **response in less than an hour, less than a day, greater than a day**. This yeilded an accuracy of 57%

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/RF_3_categories_accuracy.PNG>
  </p>

To further increase accuracy the *accepted_answer_duration* was further consolidated into two categories: **less than 24 hours, and greater than 24 hours**. 

The results from the model are as follows:

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/RF_icr_accuracy_expanded_data.PNG>
  </p>
<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/RF_cm.PNG>
  </p>

The model yeilded the following results:
- accuracy: 61%
- precision (less than 24 hours): 91%
- precision (greater than 24 hours): 20%

In attemps to increase accuracy we compared the results to an EasyEnsemble Classifer

### *EasyEnsemble Classifer*
The results from the model are as follows:

<p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/EE_icr_accuracy_expanded_data.PNG>
  </p>
  <p align ="center">
  <img src=https://github.com/smanowar/final-project/blob/main/Images/EE_cm.PNG>
  </p>

The model yeilded:
- accuracy: 63%
- precision (less than 24 hours): 92%
- precision (greater than 24 hours): 21%


### Summary of Findings
Based on the results above we can see that the accuracy of both models differs by two percentage points - Random Forest at 61% and EasyEnsemble at 63%. The precision of both models also differ by a percentage points.

However, the run times for both models differed greaty. The Random Forest Classifier ran in about a minute, while the EasyEnsemble Classifier took about 30 minutes to run. For only yeilding a percentage point difference in accuracy it seems that Random Forest may be the most efficient choice.

Given more time, the next steps we would take would be to:
- increase data set size to see if accuracy improves further
- instead of the number of tags use the tags as categorical data
- take a look at data from the questions with no accepted answers and see how that may impact the results of our model

## **Communications protocols** 

- Each team member will have their own branch to this repository, named after their first names for clarity

    - **Saudia (*smanowar*) branch**: https://github.com/smanowar/final-project/tree/saudia

    - **Esther (*emc1518*) branch**: https://github.com/smanowar/final-project/tree/esther

    - **Suweatha (*ssanmug*) branch** : https://github.com/smanowar/final-project/tree/suweatha

    - **Nisha (*nishavenkatesh11*) branch**: https://github.com/smanowar/final-project/tree/nisha

- Each commit on a branch must include the following information in the comments:

  - Description of the update
  - Identify which component of the project it contributes to
  - Is the update complete or partial

