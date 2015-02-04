require_relative './lib/google_spreadsheet'
require_relative './lib/upload_s3'

require 'json'

OUTPUT_CSV = ''

#Initializing new object for S3 class which implicitly create new s3 bucket and send credentails
#Please remove this part if you don't wanna upload files to S3
#s3_object = UploadS3.new(ACCESS_KEY_ID,SECRET_ACCESS_KEY,BUCKET)

#Reading params.json file to read all input pararmeters
file = File.read ('./params.json')
params = JSON.parse(file)

client_id = params['client_id']
client_secret = params['client_secret']
refresh_token = params['refresh_token']

token = Spreadsheet.new(client_id,client_secret,refresh_token)

#Will download Spreadsheets from Google Drive 
files = token.export_csv()
puts files

#Move the uploaded files to Trash
files.each do |key,file_id|
	token.move_to_trash(file_id)
end