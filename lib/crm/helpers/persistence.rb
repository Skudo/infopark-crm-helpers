# frozen_string_literal: true

module Crm
  module Helpers
    module Persistence
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def create(attributes = {})
          attributes = attributes.with_indifferent_access
          instance = new(attributes)
          instance.save! unless instance.invalid?
          instance
        end

        def create!(attributes = {})
          instance = create(attributes)
          if instance.invalid?
            raise Crm::Errors::InvalidValues.new('', instance.errors)
          end

          instance
        end
      end

      def save
        update
      end

      def save!
        update!
      end

      def update(attributes = {})
        assign_crm_attributes(attributes)
        return false if invalid?

        persist
      end

      def update!(attributes = {})
        assign_crm_attributes(attributes)
        raise Crm::Errors::InvalidValues.new('', errors) if invalid?

        persist
      end

      def destroy
        crm_object.destroy
        self
      end

      def persist
        return false if invalid?

        @crm_object = if crm_object.nil?
                        self.class.crm_class.create(crm_attributes)
                      else
                        crm_object.update(crm_attributes)
                      end
        assign_crm_attributes(crm_object.attributes)
        true
      end

      protected

      def crm_object
        return @crm_object if defined?(@crm_object)
        return nil if id.blank?

        @crm_object = self.class.crm_class.find(id)
      end
    end
  end
end
