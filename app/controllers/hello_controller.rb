class HelloController < ApplicationController
	def index
		render :text => "hello,world"
	end
end
