class Slave
  def shutdown opts = {}
    quiet = getopts(opts)['quiet']
    raise "already shutdown" if @shutdown unless quiet
    begin; @lifeline.cut; rescue Exception; end
    @shutdown = true
  end
  
  class LifeLine
    def cling &b
      on_cut{ b.call if b }.join
    end
  end
end
