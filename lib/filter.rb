def self.filter(request)    
    param = Array.new    
    condition = '' 
    request.data.each do |key, value|
        condition += "#{key} LIKE ? AND "
        param << "%" + value + "%" 
    end
    q = condition[0, condition.rindex('AND ')]
    temp = Array.new
    temp << q    
    temp.concat(param)
    where(temp)
    order = ''
    # sort by
    unless request.sortBy.nil?
      request.sortBy.each do |idx|
         if idx.index('-') === nil 
              order = idx.to_s + " ASC"
         else
              order = idx.to_s + " DESC"    
         end
      end  
    end    
   # return the result
    
    
   if order == nil
      where(temp)
   else
     where(temp).order(order)
   end  
end 