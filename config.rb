require "redcarpet"
require "active_support/core_ext"

Dir["./lib/*"].each{|f| require f }

# Debugging
set(:logging, ENV['RACK_ENV'] != 'production')


set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
         :fenced_code_blocks => true,
         :lax_html_blocks => true,
         :renderer => Highlighter::HighlightedHTML.new

activate :directory_indexes
activate :toc
activate :highlighter

activate :api_docs,
  :default_class => "Ember",
  :repo_url => "https://github.com/emberjs/ember.js"


###
# Blog
###

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "blog_layout"
  blog.summary_separator = %r{(<p>READMORE</p>)} # Markdown adds the <p>
end

page "/blog/feed.xml", :layout => false


###
# Pages
###

page 'guides*', :layout => :guide do
  @guides = data.guides
end

page "community.html" do
  @chapters = data.community.chapters
end

# Is this used?
page "examples/*", :directory_index => false

page "index.html", :proxy => "about.html"

page "404.html", :directory_index => false



###
# Helpers
###

helpers do
  # Workaround for content_for not working in nested layouts
  def partial_for(key, partial_name=nil)
    @partial_names ||= {}
    if partial_name
      @partial_names[key] = partial_name
    else
      @partial_names[key]
    end
  end

  def rendered_partial_for(key)
    partial_name = partial_for(key)
    partial(partial_name) if partial_name
  end

  def link_to_page name, url
    path = request.path
    current = path =~ Regexp.new(url)

    if path == '/index.html' and name == 'about'
      current = true
    end

    class_name = current ? ' class="active"' : ''

    "<li#{class_name}><a href=\"#{url}\">#{name}</a></li>"
  end
end
