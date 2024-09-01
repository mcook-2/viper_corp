class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.ransackable_attributes(auth_object = nil) # rubocop:disable Lint/UnusedMethodArgument
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(auth_object = nil) # rubocop:disable Lint/UnusedMethodArgument
    authorizable_ransackable_associations
  end
end
