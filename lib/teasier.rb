require 'watir'
require 'page-object'
require 'chromedriver-helper'
require 'webdriver-user-agent'


# User Agent analysis at => https://developers.whatismybrowser.com/useragents/parse/?analyse-my-user-agent=yes

module Teasier

	DEFAULT_HOW = "data-x"
	SEARCH_BY = [:id, :data_x, :name, :placeholder, :text]

	class WhereElement

		def initialize browser, text
			@browser = browser
			@text = text
		end

		def on what
			return @browser.text_field(what).set(@text) if what.is_a? Hash
			where = text_field_for(what)
			where.clear
			return where.set @text	
		end

		def text_field_for(what)
			SEARCH_BY.each do |how|
				begin
					criteria = Teasier.criteria_for(what,how)
					where = @browser.text_field(criteria)
					return where if where.located? or where.present?
				rescue Watir::Exception::UnknownObjectException
				rescue => e
					Teasier.error(e)
				end
			end
			Teasier.ups!
		end
	end

	def self.new_browser opts = {}
		browser = opts[:browser] || :chrome
		args = {}		
		unless (args[:url]= ENV['GRID']) # priority for remote
			caps = !!opts.delete(:headless) && self.options || {}
			args = {options: caps}
		end
		Watir::Browser.new browser, args
	end

	def self.new_android opts={}
		opts[:agent]= :android_phone
		self.new_device opts
	end

	def self.new_iphone opts={}
		opts[:agent]= :iphone
		self.new_device opts
	end	

	def self.new_iphone6plus
		opts[:agent]= :iphone6plus
		self.new_device opts
	end

	def self.new_ipad opts={}
		opts[:agent]= :ipad
		self.new_device opts
	end

	def self.add_search_attribute which
		SEARCH_BY << "#{which}".to_sym
		SEARCH_BY.uniq!
	end

	def self.new_device opts={}
		default_timeout = opts.delete(:default_timeout)
		height = opts.delete(:height) || 800
		width  = opts.delete(:width) || 600
		# sets defaults	
		opts[:browser]= 	:chrome unless opts[:browser]
		opts[:orientation]= :landscape unless opts[:orientation]
	
		if ENV['GRID'] # priority for remote
			opts[:url] = ENV['GRID'] 
		else
			opts[:options]= self.options(!!opts.delete(:headless))
		end
		driver = Webdriver::UserAgent.driver(opts)
		browser = Watir::Browser.new(driver)

		Watir.default_timeout= default_timeout if default_timeout		
		
		# resize if given	
		browser.window.resize_to(width, height) if height && width
		browser
	end

	def self.options headless = false
		options = ::Selenium::WebDriver::Chrome::Options.new
		if headless
		  	options.add_argument '--no-sandbox'
		  	options.add_argument '--disable-dev-shm-usage'
		  	options.add_argument '--headless'
		end
	  	options
	end

	def open			
		self.goto
	end

	def wait_until_text_present text
		@browser.wait_until{|b| b.html.include? text}
	end

	def self.included(base)
      	base.class_eval do
      		include PageObject
    	end
  	end
	
	def click_on what
		return @browser.element(what).click if what.is_a? Hash
		element_for(what).click
	end

	def wait_and_click_on what
		element_for(what).wait_until(&:present?)&.click
	end

	def click_on_button what
		@browser.button(text: what).click
	end

	def type text
		element = WhereElement.new @browser, text
	end

	def clear what
		field = element_for(what)
		loop do
			break if ["",nil].include? field.attribute('value')
			field.send_keys :backspace
		end
	end

	def element_for(what)
		SEARCH_BY.each do |how|
			begin
				criteria = Teasier.criteria_for(what,how)
				where = @browser.element(criteria)
				return where if where.located? or where.present?
			rescue Watir::Exception::UnknownObjectException
			rescue => e
				Teasier.pasaron_cosas(e)
			end
		end
		Teasier.ups!
	end

	def self.criteria_for what, how
		value = how == :data_w ?  what.downcase.gsub(' ','_') : what
		{how => value}
	end

	def self.ups!
		raise "Ups, cannot find the element. 
Try by adding #{DEFAULT_HOW} attribute on html"
	end

	def self.error e
		raise "An error ocurred! #{e}"
	end

	def self.default_timeout= value
		Watir.default_timeout= value
	end


end
