Gem::Specification.new do |s|
	s.name 			  = "smartclient"
	s.version 	  = "0.0.4"
	s.date			  = "2013-05-14"
	s.summary 		= "It supports the request and response class for the smartclient"
	s.description	= "This gem will work for the smartclient. 
	                 After you install this gem, you should define the filter method in the models.
	                 To do this you need to copy the filter method of the filter.rb of the gem/smartclient directory to the model class."
	s.authors		  = ["Kris Jin"]
	s.email			  = "kris.jin81@gmail.com"
	s.files			  = ["lib/RPCManager.rb", "lib/DSRequest.rb", "lib/DSResponse.rb", "lib/DataSource.rb", "lib/filter.rb"]
	s.homepage	  = "http://smartclient.com/"
end