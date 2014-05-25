module TracksHelper
	def google_maps_api_key
		"AIzaSyA9m3Ix3AmZHlnvQCQAIUo4yyFjD7c9eLw"
	end

	def google_api_url
		"http://maps.googleapis.com/maps/api/js"
	end

	def google_api_access
		"#{google_api_url}?key=#{google_maps_api_key}&libraries=geometry,places&sensor=false"
	end

	def google_maps_api
		content_tag(:script,:type => "text/javascript",:src => google_api_access) do
		end
	end

	def location_to_js(location)
		content_tag(:script, :type => "text/javascript") do
			"var js_location = "+location.to_s;
		end
	end
end
