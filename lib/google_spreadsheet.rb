require_relative './Google_Oauth.rb'

require 'rubygems'
require 'rest_client'
require 'json'
require 'csv'
require 'pp'

class Spreadsheet

	def initialize (client_id,client_secret,refresh_token)
		#Generate new access token from Google_Oauth library
		@new_token     = Google_Oauth.new(client_id,client_secret,refresh_token)
		#Store the fresh access token as an instance variable
		@access_token = @new_token.get_access_token
		#Create an instance variable that is a timer. It checks before each API call that it has exceeded 1hr , if it is then generate a new access token and reset the timer 
		@start_time = Time.now
	end

	# This function is used to generate new access token and reset the timer
	def refresh_access_token()

		if(Time.now - @start_time) <=3000
			puts "Access Token still not expired"
		else
			puts "Access Token Expired .......Creating a new one"
			@access_token = @new_token.get_access_token
			@start_time   = Time.now 
		end
	end
	
	
	def get_list_folders()
		
		refresh_access_token()
		request_url = "https://www.googleapis.com/drive/v2/files?q=mimeType='application/vnd.google-apps.folder'&access_token=#{@access_token}"

		response = RestClient.get request_url
		response_body = JSON.parse(response.body)
		folders = Hash.new

		response_body['items'].each do |item|
			folders[item['title']] = item['id']
		end

		return folders
	end


	def get_list_files()

		folders = get_list_folders()
		#Give the folder you want to use otherwise we'll have to loop through
		folder_id = folders['Adwords']
		refresh_access_token()

		request_url = "https://www.googleapis.com/drive/v2/files/#{folder_id}/children?access_token=#{@access_token}"
		response = RestClient.get request_url
		response_body = JSON.parse(response.body)
		files = Array.new
		response_body['items'].each do |item|
			files.push(item['id'])
		end	
		return files
	end

	def file_titles()
		
		list = get_list_files()

		files = Hash.new
		
		list.each do |item|
			refresh_access_token()
			request_url = "https://www.googleapis.com/drive/v2/files/#{item}?access_token=#{@access_token}"
			response = RestClient.get request_url
			response_body = JSON.parse(response.body)
			files[response_body['title']] = item
		end
		return files
	end


	def export_csv()
	
		files = file_titles()
		puts "#{files.length} files will be exported to S3"
		puts "#{files.keys}"
		
		files.each do |key,file_id|
			refresh_access_token()
			request_url = "https://docs.google.com/spreadsheets/export?id=#{file_id}&exportFormat=csv&access_token=#{@access_token}"
			response = RestClient.get request_url

			#Write it to a file
			output_csv = key + ".csv"
			open(output_csv,'wb') do |file|
				file.write(response.body)
			end	
		end
		return files
	end	

	def move_to_trash(file_id)

		refresh_access_token()
		request_url = "https://www.googleapis.com/drive/v2/files/#{file_id}/trash?access_token=#{@access_token}"
		response = RestClient.post request_url, {:content_type => 'application/x-www-form-urlencoded'}
	end
	
end