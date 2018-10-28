import pandas as pd
# from sqlalchemy import create_engine
import base64


# def sqlalchemy_connect():
#     address = '127.0.0.1'
#     username = 'root'
#     password = '12345'
#     database = 'crisp'
#     return create_engine("mysql+pymysql://{}:{}@{}/{}".format(username, password, address, database))


df_csv = pd.read_csv('visit_details.csv')
df_csv['email'] = df_csv['email'].apply(
    lambda x: bytes(base64.b64decode(x)).decode('utf-8'))
df_csv['mobno'] = df_csv['mobno'].apply(
    lambda x: bytes(base64.b64decode(x)).decode('utf-8'))
# print(df_csv.head())
# df_csv.to_sql(con=sqlalchemy_connect(), name='visit_details',
#               if_exists='append', index=False)

""" 
When there are multiple visids by the same email
"""
df_email_duplicates = df_csv[['email', 'visid']].drop_duplicates().groupby(
    'email').apply(lambda x: ', '.join(x.visid)).reset_index().rename(columns={0: 'duplicate_visid'})
df_email_duplicates = df_email_duplicates[df_email_duplicates.duplicate_visid.str.count(
    ',') > 0]
print(df_email_duplicates.head())

"""
When there are multiple visids by the same mobno
"""
df_mobno_duplicates = df_csv[['mobno', 'visid']].drop_duplicates().groupby('mobno').apply(
    lambda x: ', '.join(x.visid)).reset_index().rename(columns={0: 'duplicate_visid'})
df_mobno_duplicates = df_mobno_duplicates[df_mobno_duplicates.duplicate_visid.str.count(
    ',') > 0]
print(df_mobno_duplicates.head())

"""
When there are multiple emails by the same visid
"""
df_visid_duplicates_email = df_csv[['visid', 'email']].drop_duplicates().groupby(
    'visid').apply(lambda x: ', '.join(x.email)).reset_index().rename(columns={0: 'duplicate_email'})
df_visid_duplicates_email = df_visid_duplicates_email[df_visid_duplicates_email.duplicate_email.str.count(
    ',') > 0]
print(df_visid_duplicates_email.head())

"""
When there are multiple mobnos by the same visid
"""
df_visid_duplicates_mobno = df_csv[['visid', 'mobno']].drop_duplicates().groupby(
    'visid').apply(lambda x: ', '.join(x.mobno)).reset_index().rename(columns={0: 'duplicate_mobno'})
df_visid_duplicates_mobno = df_visid_duplicates_mobno[df_visid_duplicates_mobno.duplicate_mobno.str.count(
    ',') > 0]
print(df_visid_duplicates_mobno.head())

"""
When there are multiple mobnos by the same email
"""
df_email_duplicates_mobno = df_csv[['email', 'mobno']].drop_duplicates().groupby(
    'email').apply(lambda x: ', '.join(x.mobno)).reset_index().rename(columns={0: 'duplicate_mobno'})
df_email_duplicates_mobno = df_email_duplicates_mobno[df_email_duplicates_mobno.duplicate_mobno.str.count(
    ',') > 0]
print(df_email_duplicates_mobno.head())

"""
When there are multiple emails by the same mobno
"""
df_mobno_duplicates_email = df_csv[['mobno', 'email']].drop_duplicates().groupby(
    'mobno').apply(lambda x: ', '.join(x.email)).reset_index().rename(columns={0: 'duplicate_email'})
df_mobno_duplicates_email = df_mobno_duplicates_email[df_mobno_duplicates_email.duplicate_email.str.count(
    ',') > 0]
print(df_mobno_duplicates_email.head())


"""
Writing to CSV files.
"""
df_email_duplicates.to_csv('email_duplicates.csv',
                           encoding='utf-8', index=False)
df_mobno_duplicates.to_csv('mobno_duplicates.csv',
                           encoding='utf-8', index=False)
df_visid_duplicates_email.to_csv(
    'visid_duplicates_email.csv', encoding='utf-8', index=False)
df_visid_duplicates_mobno.to_csv(
    'visid_duplicates_mobno.csv', encoding='utf-8', index=False)
df_email_duplicates_mobno.to_csv(
    'email_duplicates_mobno.csv', encoding='utf-8', index=False)
df_mobno_duplicates_email.to_csv(
    'mobno_duplicates_email.csv', encoding='utf-8', index=False)
