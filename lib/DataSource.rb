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
    result = ds_content
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
	def buildStandardCriteria(request, table_name)
		query = 'SELECT * FROM ' + table_name + ' WHERE '
		param = Array.new    
		condition = '' 
		request.data.each do |key, value|
			condition += "#{key} LIKE ? AND "
			param << "%" + value + "%" 
		end
		q = condition[0, condition.rindex('AND ')]
		query += q
		
		order = ''
		unless request.sortBy.nil?
		  request.sortBy.each do |idx|
			 if idx.index('-') === nil 
				  order = " ORDER BY " + idx.to_s + " ASC"
			 else
				  order = " ORDER BY " + idx.to_s + " DESC"    
			 end
		  end
		end
		
		query += order
		temp = Array.new
		temp << query    
		temp.concat(param)
		return temp 
	end
	
	def buildAdvancedCriteria(request, table)
		advancedCriteria = request.advancedCriteria
		criteria_query = buildCriterion(advancedCriteria)		
		query = "SELECT * FROM " + table.to_s + " WHERE " + criteria_query[:query] 
		
		# sort by
		order = ''
		unless request.sortBy.nil?
		  request.sortBy.each do |idx|
			 if idx.index('-') === nil 
				  order = " ORDER BY " + idx.to_s + " ASC"
			 else
				  order = " ORDER BY " + idx.to_s + " DESC"    
			 end
		  end
		end
		query += order
		
		result = Array.new
		result << query   
		result.concat(criteria_query[:values])		
		
		Rails.logger.info('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
			Rails.logger.info(result)
		Rails.logger.info('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
		return result
	end
	
	def buildCriterion(advancedCriteria)
		criterias = advancedCriteria[:criteria]
			
		operator = advancedCriteria[:operator]
		values = Array.new
		result = ''
		criterias.each do | c |  
			if c.has_key?(:fieldName)
				fn = c[:fieldName]
			end
			
			if c.has_key?(:operator)
				op = c[:operator]
			end
			
			if c.has_key?(:value)
				if c[:value] === true
					val = 1
				elsif c[:value] === false
					val = 0
				else
					val = c[:value]
				end
			end
			
			if c.has_key?(:start)	
				start = c[:start]
			end
			
			if c.has_key?(:end)
				_end = c[:end]
			end
			
			if c.has_key?(:criteria)
				criteria = c[:criteria]
			else
				criteria = nil
			end
			
			if criteria == nil				
				query = ''
				case op
					when 'equals'
						query = "#{fn} = ?"; 
						values << val
						
					when 'notEqual'
						query = "#{fn} != ?"; 
						values << val
						
					when 'iEquals'
						query = "UPPER(#{fn}) = ?"						
						values << "UPPER('#{val}')" 
						
					when 'iNotEqual'                            
						query = "UPPER(#{fn}) != ?"
						values << "UPPER('#{val}')"
						
					when 'greaterThan'
						query = "#{fn} > ?"		
						values << val
						
					when 'lessThan'
						query = "#{fn} < ?"		
						values << val
						
					when 'greaterOrEqual'
						query = "#{fn} >= ?"		
						values << val
						
					when 'lessOrEqual'
						query = "#{fn} <= ?"; 
						values << val
						
					when 'contains'
						query = "#{fn} LIKE ?";  
						values << "%#{val}%"
						
					when 'startsWith'
						query = "#{fn} LIKE ?";  
						values << "#{val}%"
						
					when 'endsWith'
						query = "#{fn} LIKE ?";  
						values << "%#{val}"
						
					when 'iContains'
						query = "#{fn} LIKE ?";  
						values << "%#{val}%"
						
					when 'iStartsWith'
						query = "UPPER(#{fn}) LIKE ?" 
						values << "UPPER('#{val}%')"
						
					when 'iEndsWith'
						query = "UPPER(#{fn}) LIKE ?" 
						values << "UPPER('%#{val}')"
							
					when 'notContains'
						query = "#{fn} NOT LIKE ?" 
						values << "%#{val}%"
							
					when 'notStartsWith'
						query = "#{fn} NOT LIKE ?" 
						values << "#{val}%"
						
					when 'notEndsWith'
						query = "#{fn} NOT LIKE ?" 
						values << "%#{val}"
						
					when 'iNotContains'
						query = "UPPER(#{fn}) NOT LIKE ?" 
						values << "UPPER('%#{val}%')"
						
					when 'iNotStartsWith'
						query = "UPPER(#{fn}) NOT LIKE ?" 
						values << "UPPER('#{val}%')"
												
					when 'iNotEndsWith'
						query = "UPPER(#{fn}) NOT LIKE ?" 
						values << "UPPER('%#{val}')"
						
					when 'isNull'
						query = "#{fn} IS NULL"
						
					when 'notNull'
						query = "#{fn} IS NOT NULL"
						
					when 'equalsField'
						query = "#{fn} LIKE ?"
						values << "CONCAT('#{val}', '%')"
						
					when 'iEqualsField'
						query = "UPPER(#{fn}) LIKE ?"
						values << "UPPER(CONCAT('#{val}', '%'))"
						
					when 'iNotEqualField'
						query = "UPPER(#{fn}) NOT LIKE ?"
						values << "UPPER(CONCAT('#{val}', '%'))"
						
					when 'notEqualField'
						query = "#{fn} NOT LIKE ?" 
						values << "CONCAT('#{val}', '%')"
						
					when 'greaterThanField'
						query = "#{fn} > ?"
						values << "CONCAT('#{val}', '%')"
						
					when 'lessThanField'
						query = "#{fn} < ?"
						values << "CONCAT('#{val}', '%')"
						
					when 'greaterOrEqualField'
						query = "#{fn} >= ?"
						values << "CONCAT('#{val}', '%')"
						
					when 'lessOrEqualField'
						query = "#{fn} <= ?"
						values << "CONCAT('#{val}', '%')"
						
					when 'iBetweenInclusive'
						query = "#{fn} BETWEEM ? AND ?"
						values << start
						values << _end
						
					when 'betweenInclusive'
						query = "#{fn} BETWEEM ? AND ?" 
						values << start
						values << _end
						
				end 	
				result = result.to_s + " " + query.to_s + " " + operator.to_s + " " 
			else
				# build the list of subcriterias or criterions                    
				temp = result
				result1 = buildCriterion(c)
				result = temp.to_s + "(" + result1[:query] + ") " + operator + " "
				
				result1[:values].each do | value |
					values << value
				end
			end 
		end 
		
		q = result[0, result.rindex(operator)]
		
		criteria_result = Hash.new
		criteria_result[:query] = q
		criteria_result[:values] = values
		
		return criteria_result 
	end
=begin
  <summary> get the item list from the table </summary>
  <note>Before this method is called, the filter method should define in the model of the projects.</note>  
=end  
	def fetch(request)      
		table_name = @model.table_name
		data = request.data
		# check the advanced cretira
		unless request.advancedCriteria.nil?			
			query = buildAdvancedCriteria(request, table_name)
			@obj_items = @model.find_by_sql(query) 
		else
			unless request.data.empty?
				query = buildStandardCriteria(request, table_name)
				@obj_items = @model.find_by_sql(query) 
			else
				@obj_items = @model.find(:all) 
			end
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

		return response 
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
      return response
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
      return response 
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
	  response = DSResponse.new      
      response.status = 0      
      return response
    end
end