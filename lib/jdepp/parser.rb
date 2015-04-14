require "pathname"
require "pp"
require "set"

module Jdepp

   class Parser

      def initialize(locations={}, feedback=Feedback.new)
         @locations = locations
         @feedback = feedback
      end

      def parse(file_list)

         def recurse(accum, path)
            re = /^\/\/\s*@requires\s*"(([^"\n:]+):)?([^"\n]+)"\s*$/
            lines = File.readlines(path.to_s)
            lines.reduce(accum) do
               |a, ln|
               matches = re.match(ln)
               if matches != nil then
                  if matches[1].nil? then
                     rel = Pathname.new(path.dirname + matches[3])
                  else
                     loc_alias = matches[2]
                     if @locations.key?(loc_alias) then
                        rel = @locations[loc_alias].join(matches[3])
                     else
                        # todo: convert path to relative path.
                        raise "unspecified location alias \"#{loc_alias}\" encountered in <#{path}>."
                     end
                  end
                  abs = rel.realdirpath
                  if not a.key?(abs) then
                     @feedback.puts_if(:verbose) {"i matched #{rel} (#{abs})"}
                     recurse(a, rel)
                     a[abs] = rel
                  else
                     @feedback.puts_if(:verbose) {"i am ignoring a duplicate directive for #{rel} (#{abs})"}
                  end
               end
               a
            end
         end

         # todo: default to returning relative paths; absolute on request.
         (file_list.reduce({}) do
            |accum, s|
            recurse(accum, Pathname.new(s))
            accum
         end).values.map {|p| p.to_s}
      end

   end

end
