require "pp"
require "set"

module Jdepp
   module CLI

      class Feedback
         attr_reader :enabled_tags
         attr_reader :output

         def initialize(enabled_tags=[], output=$stderr)
            @enabled_tags = Set.new(enabled_tags)
            @output = output
         end

         def add_tag(tag)
            @enabled_tags.add(tag)
         end
         
         def delete_tag(tag)
            @enabled_tags.delete(tag)
         end

         def dry_run?
            @enabled_tags.member?(:dry_run)
         end

         def dry_run
            add_tag(:dry_run)
         end

         def verbose?
            @enabled_tags.member?(:verbose)
         end

         def verbose
            add_tag(:verbose)
         end

         def action?
            @enabled_tags.member?(:action)
         end

         def action
            add_tag(:action)
         end

         def quiet
            preserve_dry = dry_run
            @enabled_tags = Set.new
            if preserve_dry then
               dry_run
            end
         end

         def puts_if(relevant_tags, &msg)
            if relevant_tags.is_a?(Array) then
               relevant_tags = Set.new(relevant_tags)
            elsif not relevant_tags.is_a?(Set) then
               relevant_tags = Set.new([relevant_tags])
            end
            tags = relevant_tags.intersection(@enabled_tags)
            if tags.length > 0 then
               @output.puts("#{prefix tags}#{msg.call()}")
            end
            nil
         end

         def system(cmds)
            puts_if([:dry_run, :verbose, :action]) { cmds }
            if not self.dry_run? then
               Kernel::system(cmds)
            else
               nil
            end
         end

         private

         def prefix(relevant_tags)
            if relevant_tags.empty? then
               raise "i cannot create a feedback from an empty tag set."
            end
            tags = (relevant_tags.map {|tag| tag.to_s}).sort
            # todo: refactor to reduce
            result = ""
            tags[0..-2].each {|s| result += "#{s}, "}
            result += "#{tags[-1]}: "
            result
         end

      end
   end
end

