require 'DataSource'
=begin
  <summary>
     reference to the RPCManager executing this request will be stored in DSRequest.
     This has to be done because, while the request is being.executed, access will be required to various items such as 
     the DataSource object, etc - These items will all be provided by the RPCManager class.
  </summary> 
=end
class DSRequest
    attr_accessor :dataSource, :operationType, :startRow, :endRow, :textMatchStyle, :data, :sortBy, :oldValues
    
    @dataSource = nil
    @operationType = nil
    @startRow = nil
    @endRow = nil
    @textMatchStyle = nil
    @componentId = nil
    @data = nil             
    @sortBy = nil
    @oldValues = nil
           
    @@obj = nil      
    def initialize(data, model)
      @componentId = data[:componentId]
      @dataSource = data[:dataSource]
      @operationType = data[:operationType]
      @startRow = data[:startRow]
      @endRow = data[:endRow]
      @textMatchStyle = data[:textMatchStyle]
      @data = data[:data]
      @sortBy = data[:sortBy]
      @oldValues = data[:oldValues]
      
      @@obj = model
    end 
=begin
    <summary>
      The execute() method itself only loads the DataSource object then calls the DataSource's execute method for 
      processing the request.
    </summary>
      <params>
        @datasource: DataSource object from the RPCManager helper class
        @@obj: model object that is mapped to the table
      </params>  
=end
    def execute
      ds = DataSource.new(@dataSource, @@obj)
      if ds.nil?
        return nil
      else
        return ds.execute(self)
      end
    end
end

