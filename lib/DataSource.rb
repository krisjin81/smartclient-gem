=begin
  <summary>
    This helper classes process the request after recieve from the DSRequest.
    The CRUD methods(add, remove, update, fetch) were supported.      
  </summary>  
=end
class DataSource
  attr_accessor :data_source
  @data_source = nil
  @model = nil   
  def initialize(path, model)        
    #@data_source = self.get_data(path)
    @model = model
  end
=begin
  <summary> get the DataSource contents from the path and parse to JSON format </summary>  
=end  
  def get_data(path)
    ds_content = File.read(path)
    #remove the isc tag and the end tag
    ds_content['isc.RestDataSource.create('] = ''
    ds_content[');'] = ''
    #remove tab, newline tag \n \r \t etc
    result = ds_content.gsub('/\r|\n|\t|>>|\/\//', '')
    return JSON.parse(result)
  end
=begin
  <summary> get the field content by the filed name </summary>  
=end  
  def get_field(field_name)
    fields = @data_source['fields']
    
    fields.each do | f |
      if f['name'] == filed_name
        return f
      end
    end     
    return nil
  end
=begin
  <summary> process the request </summary>  
=end
  def execute(request)
    operation_type = request.operationType      
      case operation_type
       when 'fetch' 
         @result = fetch(request)
       when 'add'         
         @result = add(request)
       when 'remove'
         @result = remove(request)
       when 'update'
         @result = update(request)
      end
    return @result
  end
  
private
=begin
  <summary> get the item list from the table </summary>
  <note>Before this method is called, the filter method should define in the model of the projects.</note>  
=end  
  def fetch(request)      
      unless request.data.empty?
          # get the filter from the model                      
          @obj_items = @model.filter(request) 
      else
          # get all supplyitems from the database
          @obj_items = @model.find(:all) 
      end 

      objs_count = @obj_items.count
      # get the count of the obj_items      
      endRow = (objs_count > 0)?objs_count - 1 : objs_count
      
      # make the Response result object 
      response = DSResponse.new
      response.data = @obj_items
      response.startRow = 0
      response.endRow = endRow
      response.status = 0
      response.totalRow = objs_count      
    
      @result = { :response => response } 
      return @result 
    end
=begin
  <summary>Add new item</summary>  
=end     
    def add(request)      
      new_data = request.data
      new_supplyitem = @model.create(new_data)
      response = DSResponse.new
      response.data = new_data
      response.status = 0
      @result = { :response => response }
      return @result
    end
=begin
  <summary>Remove the selected item</summary>  
=end         
    def remove(request)      
      data = request.data
      item_id = data['itemID']
      # remove the item
      @model.destroy(item_id)
      response = DSResponse.new
      response.data = data
      response.status = 0
      @result = { :response => response }
      return @result 
    end
=begin
  <summary>Update the items</summary>  
=end         
    def update(request)      
      # get the old data from the request object
      old_data = request.oldValues
      # get the date from the request object
      update_data = request.data
      item_id = update_data['itemID']
      # merge to hash objects      
      merged_data = old_data.merge!(update_data)      
      merged_data.delete('itemID')
      
      #update
      @model.update(item_id, merged_data)      
      return nil
    end
end