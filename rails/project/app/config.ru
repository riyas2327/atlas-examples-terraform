# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

app = proc do |env|
  [200, { "Content-Type" => "text/html" }, ["You've just deployed a <i>Rails App</i>!"]]
end
run app
