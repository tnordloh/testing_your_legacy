# YourLegacyTests

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'your_legacy_tests'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install your_legacy_tests

## Usage

This gem should be used by people who have inherited a legacy application which lacks any tests, but has been running in production for a while.  It uses Sumo Logic to find the most frequently used urls in an application, and then generates tests for those urls.

### Prerequisites

Currently, this gem requires an active account with sumologic, and that you read your logfiles into sumologic.  It then uses their api to aggregate the results, and create tests, based on frequency.

After reading in log files with Sumo, you can run the sumo_sum script.  It will prompt you to fill in the ~/.sumo_creds file, with your credentials, if you haven't already.  Otherwise, it should parse your sumo account, and return a list of tests to your command line, which you can pipe into a test file of your choise.

All of the tests are initially set to `skip`, so that you can enable them one at a time. Start at the first test, which is the most-visited link, and try to run it.  It may need to have some prerequisites filled in; for example, perhaps it requires that the user be logged in, which may require you to create a relevant fixture, and ensure that a login url is called first.


#### Examples
Fair warning; these examples assume no real knowledge on building tests, other than the ability to run the `rake test` command.  This is mostly written as the reference I wish I had access to, when I tried to figure out how to test my legacy application, so experts may want to just skim the examples, when my lecture mode kicks in.
#### Example 1:  Base url test

```ruby
test "visit /" do
  skip
  #this url was visited 1647 times
  get '/'
  assert_response :success
end
```

After uncommenting the `skip`, and running `rake test`, you might see something like:
```
  1) Failure:
  UserStoriesTest#test_visit_/ [/my_app/test/integration/user_stories_test.rb:96]:
  Expected response to be a <success>, but was <302>
```

You can then go to the production site, and take a look for yourself, to see if this visit always results in a redirect, and modify the test accordingly.  Also, you can look at the content of the page, and modify this test to be aware of that content, perhaps by adding an `assert_content :index`, or whatever is appropriate.  Also, the auto-generated name is a placeholder; rename it, once you understand the context.

After the test is cleaned up, it may look more like this:

```ruby
test "visit home url, ensure it redirects to index" do
  get '/'
  assert_response :redirect 
  assert_template :index
end
```

Once you have this one test perfected, you will have the most visited part of the site tested, and you can move to the next test.  

#### Example 2: url requiring a login
Wow, that was easy, wasn't it?  Unfortunately, building tests on a legacy application is rarely a simple matter, and you may have to go prospecting deep into the application to make a test work.  Just remember, we are leveraging logfiles to make sure that the tests we write give us the most bang for the buck possible.  Once you've done these tests,

I'm going to break down building a specific test, on something that requires a little more work.  As we build this test out, I'm going to break out reusable chunks as I go, which I can use later on, in future tests.

Say this test, as generated, doesn't work:
```ruby
test "visit /user/profile/:id" do
  skip
  #this url was visited 424 times
  get '/user/profile/:id'
  assert_response :success
end
```

after taking a look in `app/views/users/profile.erb`, looking at `/app/controllers/user_controller.rb`, examining the model, and logging in to the website to browse this url, you determine that you need the following things to make this test work:
1. The ability to login before running this test
2. To treat this like a 'real' application, you want to visit the login page.

At this point you might be tempted to go write model tests instead.  If so, go for it.  These tests are meant as a stopgap, and as a hint on what needs testing, so if you're inspired to knock out the model tests on the User, go for it.

Step two feels easier to , so let's start with that.  We'll be turning the test from example one into a private method called 'visit_home', so we can call it at will.  

```ruby
private

def visit_home
  get_via_redirect '/'
  assert_response :success
  assert_template :index
end
```

then change our old test to match, so we can see that visit_home works correctly.  Tests testing tests, cats and dogs living together, mass hysteria!  But hey, it lets us call 'visit_home', and have confidence that it works, before we embed it in another test.

rewritten test from example 1:

```ruby
test "visit home url, ensure it redirects to index" do
  visit_home
end
```

so, now we need to have the ability to login, which we'll probably use a lot.  So we should make a private method called 'login', as well as create the relevant fixture data.  Looking at the application, we see that we will be working in the Users model and will need, at a minimum, a username at least 7 characters long, a password, a valid email, and a date that is in the future, for the 'expires_at' value.

We also see that the login is done with a 'post' to '/user/login', and requires a JSON object that looks like 

    user: { login: login , password: p }

We also know, that the database only contains hashed passwords, so we dig into the User model, and find this line in the password file:
Digest::SHA1.hexdigest(password)

Well, we are going to have to look at that later, because that password generation might not be secure, but right now, let's get that hashed password created:
at a rails console prompt, we can run:

    irb(main):002:0> Digest::SHA1.hexdigest("pw")
    => "1a91d62f7ca67399625a4368a6ab5d4a3baa6073"

and create our entry:
```
good888:
  login: good888
  password: <%= Digest::SHA1.hexdigest("pw") %>
  physician_name: good
  email: good@email.com
  expires_at: <%= (Date.today + 5.days).to_s(:db) %> 
```

So, now we can try to make our test work.  We should break the login functionality out, but for now, let's just give this a shot as-is.  To simplify things, we'll just do the 'login' portion:

```ruby
test "visit /user/profile/:id" do
  visit_home
  post '/user/login', user: { login: 'admin888' , password: 'pw' }
  follow_redirect!
  assert_response :success
  assert_equal '/', path
  get "/user/profile/#{users(:good888).id}"
  assert_response :success
end
```

We run it, it seems to work.  But this test probably should validate that we have a link to the profile, before it does the 'get' on that url. We'll add this line, and test again:

    assert_select 'a[href=?]', "/user/profile/#{users(:good888).id}", {count: 1}

Then do a little refactoring, break login into it's own method, and finalize this test:

private login method:
```ruby
def login(login, p)
  post '/user/login', user: { login: login , password: p }
  follow_redirect!
  assert_response :success
  assert_equal '/', path
end
```

**The 'login' method could be useful in many places.  If you find yourself needing it elsewhere, push it up into 'test/test_helper.rb', to make it available in your model/view/controller tests.**

cleaned up test:
```ruby
test "login, make sure user profile link is available, and that we can visit it" do
  visit_home
  login('good888','pw')
  user_id=users(:good888).id.to_s
  assert_select 'a[href=?]', "/user/profile/#{user_id}", {count: 1}¬
  get "/user/profile/#{user_id}"
  assert_response :success
end
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tnordloh/your_legacy_tests. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

