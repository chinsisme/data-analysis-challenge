# Assignment - Big Data

## Question 1
Loaded aadhar_data.csv into the following MySQL table.
```
CREATE TABLE aadhar_data 
(
  date varchar(255),
  registrar varchar(255),
  private_agency text,
  state varchar(255),
  district varchar(255),
  sub_district varchar(255),
  pincode varchar(255),
  gender varchar(20),
  age int,
  aadhar_generated int,
  rejected int,
  mobile_number int,
  email_id int
);

```
Loaded the CSV into the table.
```
LOAD DATA INFILE '/var/lib/mysql-files/aadhar_data.csv' INTO TABLE aadhar_data 
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
```
For the queries associated with this question, please refer 'PS_1.sql'

## Question 2
Requirements
```
- python3
- pandas
```
The script 'decode_and_import.py' reads the csv file 'visit_details.csv' and writes the appropriate results into the following csv files - 
```
python3 decode_and_import.py
```

```
df_email_duplicates.csv
df_mobno_duplicates.csv
df_visid_duplicates_email.csv
df_visid_duplicates_mobno.csv
df_email_duplicates_mobno.csv
df_mobno_duplicates_email.csv
```