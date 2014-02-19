class Helper
  def self.render_view(filename)
    contents = File.read("views/#{filename}.haml")
    Haml::Engine.new(contents).render
  end
end
