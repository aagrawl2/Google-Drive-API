# Google Spreadsheet API Ruby Code
A simple Spreadshhet API client for Ruby which downloads spreadsheets from Google Drive and can push them to S3

####Notes
1) Oauth2 credentials (client id, client secret, refresh token) are needed before running the script. 
2) Steps for creating Oauth credentials are :
https://confluence.intgdc.com/display/PS/Oauth+2+Authentication+Steps

3) Scopes needed for current ruby script are :
      a) https://spreadsheets.google.com/feeds 
      b)https://www.googleapis.com/auth/drive.file 
      c)https://www.googleapis.com/auth/drive.readonly
If you have not generated refresh token take reference : https://github.com/aagrawl2/Ruby/blob/master/generate_refresh_token.rb

4) Amazon S3 credentials are required if backing up to S3 else remove that piece of code

####Steps
1) Initialize S3 bucket

2) Create new Spreadsheet class object 
  
      a) Create Google_Oaut2 class object that generates fresh access token
      b) Automatic Token refreshing is handled as it expires in 3600 sec 
      
3) Get a list of folders from Google Drive  

4) Scan through all/custom folders to get list of all files. In I explicitly mentioned "Adwords" folder to get all files related to this folder.

5) Download all files locally

6) Backup all downloaded files to S3


