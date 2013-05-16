=begin
  <summary>
    Any action of the user with the DataSource will only call the RPCManager and will delegate all responsibility to it. 
    The RPCManager will parse the payload and setup the DSRequest request and will call for the request's execute() method
     which will return the DSResponse object. The RPCManager will then convert this DSResponse into a suitable response 
     and return it to the front-end.  
   </summary>
=end
require 'DSRequest'
require 'DSResponse'

class RPCManager
  @request = nil  
  @model = nil
  @temp_request = nil
=begin
  <summary>
    Process the request with the model.
  </summary>  
  
  <params>
    request: posted request parameters
    model: the object that is mapped to the table
  </params>
=end
  def initialize(request=nil, model=nil)    
    @model = model		 
	# if is not wrapped in a transaction then we'll wrap it to make unified handling of the request	
	if !check_transaction(request)		
		req_hash = HashWithIndifferentAccess.new
		req_hash[:transaction] = HashWithIndifferentAccess.new
		req_hash[:transaction][:transactionNum] = -1 				
		req_list = Array.new
		req_list << request
		req_hash[:transaction][:operations] = req_list
		@request = req_hash
	else
		@request = request
	end	 
  end  
=begin
	<summary>
		Returns true if the request has transaction support
    </summary>
    <returns></returns>
=end
	def check_transaction(request)
		if request.include?(:transaction)# and request.include?(:operations) and request.include?(:transactionNum) 
			return true
		else
			return false
		end
	end
=begin
  <summary>
      Transforms a object object into a Json. Will setup the serializer with the        
      appropriate converters, attributes,etc.
  </summary>
      <param name="dsresponse">the object object to be transformed to json</param>
      <returns>the created json object</returns>
=end
  def processRequest
	response = processTransaction   	
	@result = { :response => response } 
    return @result 	
  end
=begin
	<summary>
		Process the transaction request for which this RPCManager was created for
    </summary>
    <returns></returns>
=end
	def processTransaction		
		# retrieve the requests with data in form
		transaction_request = @request[:transaction] 		
		# store transaction num, we'll use it later to see if there was a transaction or not
		transaction_num = transaction_request[:transactionNum]
		# fetch the operations
		operations = transaction_request[:operations]
		
		queueFailed = false
		# response list
		res_list = Array.new			
		# transaction progress
		@model.transaction do 									
			begin				
				operations.each do |op|								
					
					req = DSRequest.new(op, @model) 					
					# execute the request and get the response
					res = req.execute							 
					if res == nil
						res = DSResponse.new
						res.status = -1
					end
					
					# if request execution failed, mark the flag variable
					if res.status == -1
						queueFailed = true
					end
						
					# store the response for later
					res_list << res	 
				end			
			rescue ActiveRecord::RecordInvalid
				# if it occurs exception
				raise ActiveRecord::Rollback
			end
		end
		
		# if we have only one object, send directly the DSResponse
		if transaction_num  == -1
			response = DSResponse.new
			response.data = res_list[0].data
			response.startRow = res_list[0].startRow
			response.endRow = res_list[0].endRow
			response.totalRow = res_list[0].totalRow
			response.status = res_list[0].status
			
			return response
		end
		
		# iterate over the responses and create a instance of an anonymous class which mimics the required json
		responses = Array.new
		
		res_list.each do | response |
			
			res = DSResponse.new
			res.data = response.data			
			res.startRow = response.startRow
			res.endRow = response.endRow
			res.totalRow = response.totalRow
			res.status = response.status
			
			responses << res
		end 
		return responses
	end
end