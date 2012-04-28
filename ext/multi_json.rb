module MultiJson
  unless respond_to?(:load)
    def self.load(*args)
      self.decode(*args)
    end
  end

  unless respond_to?(:dump)
    def self.dump(*args)
      self.encode(*args)
    end
  end
end
