module Sqew
  module Backend
    class LevelDB < Qu::Backend::Base
      alias_method :db_path, :connection

      def enqueue(payload)
        queue[Time.now.to_f.to_s] = MultiJson.dump(klass:payload.klass.to_s, args:payload.args)
      end

      def length(*)
        queue.keys.length
      end
      
      def reserve(_, options = {block:false})
        loop do
          logger.debug { "Reserving job" }

          if raw = queue.first
            id, job = raw
            queue.delete(id)
            running[id] = job
            return Qu::Payload.new(MultiJson.load(job).update(id:id))
          end

          if options[:block]
            sleep 3
          else
            break
          end
        end
      end

      def completed(payload)
        running.delete(payload.id)
      end

      def failed(payload, error)
        running.delete(payload.id)
        errors[payload.id] = MultiJson.dump(klass:payload.klass.to_s, args:payload.args, error:error.to_s)
      end

      def failed_jobs
        errors.values.map {|v| MultiJson.load(v) }
      end

      def running_jobs
        running.values.map {|v| MultiJson.load(v) }
      end

      def release(*)
      end

      def register_worker(*)
      end

      def unregister_worker(*)
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
