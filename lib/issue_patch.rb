require_dependency 'issue'

# Patches Redmine's Issues dynamically.  Adds a relationship 
# Issue +belongs_to+ to Deliverable
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :deliverable
      
    end

  end
  
  module ClassMethods

    # Muck with the find arguements to append an include for deliverables
    def find(*args)
      # Options defined
      if args[1].is_a?(Hash)
        # Abort the special case of issue.search.  LIKE is used by search
        if args[1].has_key?(:conditions) && args[1][:conditions].is_a?(Array) && args[1][:conditions][0].match(/LIKE \?/)
          # skip
        elsif args[1].has_key?(:include) && !args[1][:include].nil? # include used?
          # Add our include
          if args[1][:include].is_a?(Array)
            args[1][:include] << :deliverable
          else
            args[1][:include] = [args[1][:include], :deliverable] # Rewrite a the include as an array
          end
        else
          # Add an include
          args[1][:include] = [:deliverable]
        end
      end
      super
    end
    
  end
  
  module InstanceMethods
    # Wraps the association to get the Deliverable subject.  Needed for the 
    # Query and filtering
    def deliverable_subject
      unless self.deliverable.nil?
        return self.deliverable.subject
      end
    end
  end    
end

# Add module to Issue
Issue.send(:include, IssuePatch)


