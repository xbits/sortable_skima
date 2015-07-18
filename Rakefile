#require "bundler/gem_tasks"

require 'rdoc/task'


require 'geminabox-release'
GeminaboxRelease.patch(:host => "http://XXXXXXXXXXXXX")

desc 'generate API documentation to doc/rdocs/index.html'
RDoc::Task.new :generate_docs do |rdoc|
  rdoc.main = "README.rdoc"
  #rdoc.markup = 'tomdoc'
  rdoc.rdoc_files.include("README.rdoc", "lib/*")
  rdoc.rdoc_dir = 'doc'
  rdoc.options << "--all"
end

#require 'github/markup'
#require 'html/pipeline'


task :try_readme do
  in_file_name = "./README.md"
  out_file_name = "./README.html"
#  GitHub::Markup.render('README.markdown', "* One\n* Two")
  unless File.file?(in_file_name)
    puts "file '#{in_file_name} does not exist', ABORTING"
    return
  end
  unparsed_text = File.read(in_file_name)
  pipeline = HTML::Pipeline.new [
             HTML::Pipeline::MarkdownFilter,
             HTML::Pipeline::SyntaxHighlightFilter
            ]

  parsed_text =  pipeline.call unparsed_text
  out_file = File.new(out_file_name, "w")
  out_file.write parsed_text
  out_file.close
  puts parsed_text
end



