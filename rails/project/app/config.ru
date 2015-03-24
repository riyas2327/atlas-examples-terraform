# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

app = proc do |env|
  [200, { "Content-Type" => "text/html" }, ["hello <b>world</b>"]]
end
run app
