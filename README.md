# Teasier (experimental)

This gem aims to write test automation code in a simple way. Just use a data- like attribute with values according to the UI.

If you have a text field where you type email and the associated label is email, then you just have to use a data-x='email' attribute on html


## Install

Add to Gemfile:

```ruby
gem 'teasier'
```

Then bundle:

    $ bundle

Or manually:

    $ gem install teasier

## Usage

If you work closely with dev team, you have to ask for an attribute of data-something like.

Suppose you have a field where you have to type some name, the html should have an attribute like data-something="name" and that is enough to write automation code.

If you cannot modify html or devs reuse to do it, you can use the value for other attributes.
Teasier will try to find elements by :id, :data_x, :name, :placeholder or :text if possible.
If you want to add another way of search you can do it by adding it to search criteria with :add_search_attribute


```ruby
require 'teasier'


# Define a PageObject class
class MyPageObject
	include Teasier
	page_url "http://application_under_test.io:8080"
end


# Open new desktop browser
browser = Teasier.new_browser

# Or a browser on Android
browser = Teasier.new_android

# Or iPhone
browser = Teasier.new_iphone

# May be iPhone6plus
browser = Teasier.new_iphone6plus

# Also an ipad
browser = Teasier.new_ipad



# Initialize a page object
page = MyPageObject.new(browser)
page.open

# then write code like:
page.type('Roman').on('name')
page.type('email@addres.com').on('email')
page.click_on 'send'

page.click_on_button('Accept terms')

```

800 x 600 is the default window size, but it can be modified using

 ```{width: <value>, height: <value>}``` 

like:

```ruby
browser = Teasier.new_android height: 300, width: 600
```

You can use it with Selenium Grid:

```ruby
browser = Teasier.new_android height: 300, width: 600, url: "http://gridhost:port/wd/hub"
```

Or using GRID environment variable at running your script
```
GRID=http://gridhost:port/wd/hub ruby my_script.rb
```


Timeout can be modified with _default_timeout_ argument:

```ruby
browser = Teasier.new_android default_timeout: 5
```

You can also run in headless mode just by setting headless flag as true:
```ruby
browser = Teasier.new_android headless: true
```
