# encoding: UTF-8

module CASServer::Model
  module Consumable
    def consume!
      self.consumed = Time.now
      self.save!
    end

    def self.included(mod)
      mod.extend(ClassMethods)
    end

    module ClassMethods
      def cleanup(max_lifetime, max_unconsumed_lifetime)
        transaction do
          conditions = ["created_on < ? OR (consumed IS NULL AND created_on < ?)",
                          Time.now - max_lifetime,
                          Time.now - max_unconsumed_lifetime]
                        
          expired_tickets_count = where(conditions).count

          $LOG.debug("Destroying #{expired_tickets_count} expired #{self.name.demodulize}"+
            "#{'s' if expired_tickets_count > 1}.") if expired_tickets_count > 0

          where(conditions).destroy_all
        end
      end
    end
  end
end
