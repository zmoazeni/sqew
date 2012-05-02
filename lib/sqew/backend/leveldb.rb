module Sqew
  module Backend
    class LevelDB < Qu::Backend::Base
      attr_accessor :db

      def enqueue(payload)
        id = Time.now.to_f.to_s
        queue.put(id, MultiJson.encode(klass:payload.klass.to_s, args:payload.args), :sync => true)
      end

      def length(*)
        queue.keys.length
      end

      def clear(*queues)
        drop_all(queue) if queues.include?("queue") || queues.empty?
        drop_all(errors) if queues.include?("failed") || queues.empty?
      end
      
      def reserve(_, options = {block:false})
        loop do
          if raw = queue.first
            id, job = raw
            queue.delete(id, :sync => true)
            running.put(id, job, :sync => true)
            return Sqew::Payload.new(MultiJson.decode(job).update(id:id))
          end
          
          if options[:block]
            sleep 3
          else
            break
          end
        end
      end

      def completed(payload)
        running.delete(payload.id, :sync => true)
      end

      def failed(payload, error)
        running.delete(payload.id, :sync => true)
        errors.put(payload.id, MultiJson.encode("klass" => payload.klass.to_s, "args" => payload.args, "error" => error.message, "backtrace" => error.backtrace.join("\n")), :sync => true)
      end

      def failed_jobs
        errors.to_a.map {|k,v| MultiJson.decode(v).update("id" => k) }
      end

      def running_jobs
        running.to_a.map {|k,v| MultiJson.decode(v).update("id" => k) }
      end

      def queued_jobs
        queue.to_a.map {|k,v| MultiJson.decode(v).update("id" => k) }
      end

      def release(*)
      end

      def register_worker(*)
      end

      def unregister_worker(*)
      end

      def close
        queue.close
        running.close
        errors.close
        @queue, @running, @errors = nil
      end

      private
      def queue
        @queue ||= ::LevelDB::DB.new("#{db}/queue.ldb")
      end

      def running
        @running ||= ::LevelDB::DB.new("#{db}/running.ldb")
      end

      def errors
        @errors ||= ::LevelDB::DB.new("#{db}/errors.ldb")
      end

      def drop_all(db)
        db.each {|k,_| db.delete(k) }
      end
    end
  end
end
