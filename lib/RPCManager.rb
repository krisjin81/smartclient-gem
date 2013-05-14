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
    @request = request
    @model = model
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
    # retrieve the requests with data   
    req = DSRequest.new(@request, @model)  
    # set the response variable
    res = req.execute
  
    # safeguard, if was null, create an empty response with failed status
    if res.nil?
      res = DSResponse.new
      res.status=-1
    end                
    return res      
  end
end