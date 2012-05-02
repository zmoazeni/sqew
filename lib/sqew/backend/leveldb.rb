module Sqew
  module Backend
    class LevelDB < Qu::Backend::Base
      alias_method :db_path, :connection

      def enqueue(payload)
        id = Time.now.to_f.to_s
        queue.put(id, MultiJson.encode(klass:payload.klass.to_s, args:payload.args), :sync => true)
      end

      def length(*)
        queue.keys.length
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
        errors.put(payload.id, MultiJson.encode(klass:payload.klass.to_s, args:payload.args, error:error.to_s), :sync => true)
      end

      def failed_jobs
        errors.values.map {|v| MultiJson.decode(v) }
      end

      def running_jobs
        running.values.map {|v| MultiJson.decode(v) }
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
      end

      private
      def queue
        @queue ||= ::LevelDB::DB.new("#{db_path}/queue.ldb")
      end

      def running
        @running ||= ::LevelDB::DB.new("#{db_path}/running.ldb")
      end

      def errors
        @errors ||= ::LevelDB::DB.new("#{db_path}/errors.ldb")
      end
    end
  end
end
