module Yfuji
    module Cron
      class Enreq4381
        include Sidekiq::Worker
  
        sidekiq_options retry: false
  
        BATCH_NAME = 'enreq4381'
        SUFFIXES = %w[.jpg .png .js].freeze
        PREFIX = 'recojp/uploads/cron'
        FROM_DIR = 'copy'
        TO_DIR = 'paste'
  
        def perform
          ::NewRelic::Agent.add_custom_attributes(project_id: Yfuji::Config.project_id)
          logger.info{ '処理を開始します。' }
  
          self.class.include ::Yfuji::AsyncJob::Shared::Util
  
          batch.start!
  
          s3_client.list_objects_v2(
            bucket: source_bucket,
            prefix: "#{PREFIX}/#{FROM_DIR}/"
          ).contents.each do |obj|
            begin
              key = obj.key.gsub("#{PREFIX}/#{FROM_DIR}", "#{PREFIX}/#{TO_DIR}")
              if key.ends_with?('/')
                s3_client.put_object(
                  if ::Yfuji::Config.aws_s3_cache_control.present?
                    default_params.merge(key: key, cache_control: ::Yfuji::Config.aws_s3_cache_control)
                  else
                    default_params.merge(key: key)
                  end
                )
              elsif key.ends_with?(*SUFFIXES)
                s3_client.copy_object(default_params.merge(key: key, copy_source: source_bucket + "/#{obj.key}"))
              end
            rescue StandardError => e
              logger.error{ e.message }
              logger.error{ e.backtrace.join("\n") }
            end
          end
  
          batch.success!
        rescue StandardError => e
          logger.error{ e.message }
          logger.error{ e.backtrace.join("\n") }
          batch.failure!
        ensure
          logger.info{ '処理を終了します。' }
        end
  
        private
  
        def source_bucket
          @source_bucket ||= ::Yfuji::Config.aws_s3_bucket
        end
  
        def default_params
          @default_params ||= {
            bucket: source_bucket,
            acl: 'public-read'
          }
        end
  
        def s3_client
          @s3_client ||= Aws::S3::Client.new(
            region: 'ap-northeast-1',
            credentials: Aws::Credentials.new(
              ::Yfuji::Config.aws_access_key_id,
              ::Yfuji::Config.aws_secret_access_key
            )
          )
        end
  
        def batch
          @batch ||= Batch.create(
            bid: SecureRandom.hex(7),
            title: 'ファイルコピー',
            admin_id: nil,
            job_count: 1
          )
        end
  
        def logger
          @logger ||= Logger.new(Rails.root.join("log/cron_#{BATCH_NAME}.log"))
        end
      end
    end
  end