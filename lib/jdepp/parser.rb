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

         def recurse(accum, cursor, path)
            re = /^\/\/\s*@requires\s*"(([^"\n:]+):)?([^"\n]+)"\s*$/
            s = cursor.realdirpath.to_s
            @feedback.puts_if(:verbose) { "scanning #{s}..." }
            if path.include?(s) then
               raise "cyclic dependency upon #{s} detected:\n   referenced by #{path.reverse.join ",\n   referenced by "}."
            else
               path.push(s)
            end
            lines = File.readlines(cursor.to_s)
            result =
               lines.reduce(accum) do
                  |a, ln|
                  matches = re.match(ln)
                  if matches != nil then
                     if matches[1].nil? then
                        rel = Pathname.new(cursor.dirname + matches[3])
                     else
                        loc_alias = matches[2]
                        if @locations.key?(loc_alias) then
                           rel = @locations[loc_alias].join(matches[3])
                        else
                           # todo: convert cursor to relative path.
                           raise "i don't recognize the location alias \"#{loc_alias}\" encountered in <#{cursor}>."
                        end
                     end
                     if not rel.exist? then
                        raise "i can't find #{rel.to_s} (required by #{cursor})."
                     end
                     abs = rel.realdirpath
                     if not a.key?(abs) then
                        @feedback.puts_if(:verbose) {"i matched #{rel} (#{abs})"}
                        recurse(a, rel, path)
                        a[abs] = rel
                     else
                        @feedback.puts_if(:verbose) {"i am ignoring a duplicate directive for #{rel} (#{abs})"}
                     end
                  end
                  a
               end
            path.pop
            result
         end

         # todo: default to returning relative paths; absolute on request.
         (file_list.reduce({}) do
            |accum, s|
            recurse(accum, Pathname.new(s), [])
            accum
         end).values.map {|p| p.to_s}
      end

   end

end
