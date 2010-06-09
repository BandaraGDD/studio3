require "java"
require "ruble/bundle_manager"
require "ruble/scope_selector"

module Ruble
  
  class ContentAssist < Command
    def initialize(name)
      if name.kind_of? String
        super(name)
      else
        # hack to pass in java object...should test type
        @jobj = name
        @jobj.runtime = self # set the runtime for this command
      end
    end
    
    def to_s
      <<-EOS
      snippet(
        path:      #{path}
        name:      #{display_name}
        scope:     #{scope}
      )
      EOS
    end
    
    class << self
      def define_content_assist(name, &block)
        log_info("loading content_assist #{name}")
        
        snippet = ContentAssist.new(name)
        block.call(snippet) if block_given?
        
        # add snippet to bundle
        bundle = BundleManager.bundle_from_path(snippet.path)
        
        if !bundle.nil?
          bundle.add_command(snippet)
        else
          log_warning("No bundle found for content_assist #{name}: #{snippet.path}")
        end
      end
    end
    
    private
    
    def create_java_object
      com.aptana.scripting.model.ContentAssistElement.new($fullpath)
    end
    
  end
  
end

# define top-level convenience methods

def content_assist(name, &block)
  Ruble::ContentAssist.define_content_assist(name, &block)
end
