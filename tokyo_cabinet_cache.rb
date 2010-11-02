require 'tokyocabinet'
include TokyoCabinet

module TokyoCabinetCache

  def tokyo_cache(key, &block)
    perform_operation do
      existing = @hdb.get(key)
      
      if existing
        Marshal.load(existing)
      else
        output = capture(&block)
        @hdb[key] = Marshal.dump(output)
        output
      end
    end
  end
  
  def expire_tokyo_cache(key)
    perform_operation do
      @hdb.delete(key)
    end
    nil
  end
  
  def perform_operation
    return if !block_given?

    @hdb = HDB.new
    path = File.join(Rails.root, "tmp/cache.tch")
    @hdb.open(path, HDB::OWRITER | HDB::OCREAT)

    yield
  ensure
    @hdb.close
  end
  
end