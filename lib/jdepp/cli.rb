require "jdepp/cli/feedback"
require "jdepp/parser"

require "optparse"

module Jdepp::CLI

   def self.cli(argv)

      argv = ARGV
      end_of_options = argv.index("--")
      output_to_stdout = end_of_options.nil?
      if not output_to_stdout then
         if argv.length > 0 then
            recipient = argv[end_of_options + 1..-1].join(" ")
         else
            recipient = nil
         end
         argv = ARGV.first(end_of_options)
      end

      opts = {:feedback => Feedback.new, :locations => {}}
      OptionParser.new do 
         |o|
         o.banner = "usage: jdepp.rb [options] FILE [FILE ...] [-- COMMAND]"
         o.on("-v", "--[no-]verbose", "i will provide extra detail about my activity.") do
            |v|
            if (v) then
               opts[:feedback].add_tag(:verbose)
            end
         end
         o.on("-n", "--[no-]dry-run", "i will report what i would do if i were to perform the specified work.") do
            |flag|
            if (flag) then
               opts[:feedback].add_tag(:dry_run)
            end
         end
         o.on("-D", "--define=LOCATION", 'if provided with a specification of the form "PREFIX=PATH", i will substitute PREFIX: for PATH if encountered.') do
            |s|
            name, path = s.split("=", 2)
            opts[:locations][name] = Pathname.new(path)
         end
         o.on("-F","--feedback-tags=TAGS", "i will provide feedback related to the specified tags") do
            |tag_list|
            tags = tag_list.split(",")
            tags.each {|t| opts[:feedback].add_tag(t.to_sym)}
         end
         o.on("-a","--[no-]append-dependents", "i will append the dependents to the list of dependencies") do
            |flag|
            opts[:append_dependents] = flag
         end
      end.parse!(argv)

      parser = Jdepp::Parser.new(opts[:locations], opts[:feedback])
      result = parser.parse(argv)
      if opts.fetch(:append_dependents, false) then
         result.concat(argv)
      end

      if output_to_stdout then
         if result.length == 0 then
            $stderr.puts "i have an empty result-- is this what you intended?\n"
         else
            puts result
         end
      elsif not recipient.nil? then
         # todo: thread the exit status through
         opts[:feedback].system "#{recipient} #{result.join(' ')}"
      else
         $stderr.puts "i have nothing to do!"
      end

   end

end








