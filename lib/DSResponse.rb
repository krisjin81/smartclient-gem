class DSResponse
	@data = nil
	@startRow = 0
	@endRow = 0
	@totalRow = 0
	@status = -1
	 
	def data=(value)
	  @data = value
	end
	 
	def startRow=(value)
	  @startRow = value
	end

	def endRow=(value)
	  @endtRow = value
	end

	def totalRow=(value)
	  @totalRow = value
	end

	def status=(value)
	  @status = value
	end
end  

