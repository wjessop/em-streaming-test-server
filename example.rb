require 'eventmachine'
require 'evma_httpserver'
require 'em-http-request'

class MyHttpServer < EM::Connection
	include EM::HttpServer

	def post_init
		super
		no_environment_strings
	end

	def process_http_request
		response = EM::DelegatedHttpResponse.new(self)
		response.status = 200
		response.content_type 'text/plain'

		timer = EventMachine::PeriodicTimer.new(1) do
			response.chunk "."
			response.send_chunks
		end
	end
end

EM.run{
	EM.start_server '0.0.0.0', 8080, MyHttpServer
	http = EventMachine::HttpRequest.new('http://localhost:8080/').get
	http.errback {
		puts "Couldn't stream, error was #{http.error}"
	}
	http.callback {
		if http.response_header.status == 200
			puts "Disconnected from #{url}"
		else
			puts "Couldn't stream, http response was #{http.response_header.status}"
		end
	}
	http.stream { |chunk| print chunk }
}
