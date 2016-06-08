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

To run, execute the command:

`tests_via_sumo [-c or --count <count>] [-s or --source_category <category>]`

source_category defaults to a * .

Count defaults to 25, and controls the number of tests generated.

Results are generated on stdout, for maximum flexibility on where the tests are placed in the Rails application.


## Caveats

Since Sumo Logic is nice enough to process logs for free, for smaller users, I'm releasing this gem with heavy dependence on Sumo's query function, for now.  I plan on adding hooks to allow it to be more useful for processing logfiles without relying on Sumo for summing up the number of visits per page, ordering them from greatest to smallest, and parsing data out of the logfiles.

### Prerequisites

Currently, this gem requires an active account with sumologic, and that you read your logfiles into sumologic.  It then uses their api to aggregate the results, and create tests, based on frequency.

After reading log files with Sumo, run the sumo_sum command.  It will prompt you to fill in the ~/.sumo_creds file, with your credentials, if you haven't already.  Otherwise, it should parse your sumo  logs, and return a list of tests to your command line, which you can pipe into a test file of your choise.

All of the tests are initially set to `skip`, so that you can enable them one at a time. Start at the first test, which is the most-visited link, and try to run it.  It may need to have some prerequisites filled in; for example, perhaps it requires that the user be logged in, which may require you to create a relevant fixture, and ensure that a login url is called first.


#### Examples

These examples assume no real knowledge on building tests, other than the ability to run the `rake test` command; it is a summary of the things I wish I knew, when I tried to figure out how to test my legacy application, so if you are already familiar with writing tests, you may want to just skim this section.



#### Example 1:  Base url test

I took the output from `tests_via_sumo`, and appended them to the `./test/integration/user_stories_test.rb` file.

Modifying the auto-generated test to work for you:

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

This indicates that this url was redirected

You can then go to the production site, and verify that visit always results in a redirect, and modify the test accordingly.  Also, you can add checks against the page content/type, perhaps by adding an `assert_content :index`, or whatever is appropriate.  Also, the auto-generated name is a placeholder; rename it, once you understand the context.

After the test is cleaned up, it may look more like this:

```ruby
test "visit home url, ensure it redirects to index" do
  get '/'
  assert_response :redirect 
  assert_template :index
end
```

Once you have this one test perfected, you will have the most visited part of the site tested, and you can move to the next test.  


Wow, that was easy, wasn't it?  Unfortunately, building tests on a legacy application is rarely a simple matter, and you may have to go prospecting deep into the application to make a test work.  Hopefully, using logs as a guide will help to create the most informative, useful tests first, and give us an idea of what setup requirements we will need for many other tests.

#### Example 2: Url requiring a login

This example walks through the process of building a test with several setup requirements. I'm going to break the setup into separate methods, which I can hopefully be reused other tests.

This test, as generated, doesn't work:
```ruby
test "visit /user/profile/:id" do
  skip
  #this url was visited 424 times
  get '/user/profile/:id'
  assert_response :success
end
```

after taking a look in `app/views/users/profile.erb`, looking at `/app/controllers/user_controller.rb`, examining the User model, and logging in to the website to browse this url, we find these setup requirements:
1. The ability to login before running this test
2. The link to this page is found on root page, which is what the first test covers. For consistency, we want to verify that the root page has this link.

Step two feels easier, so let's start with that, by turning the test from example one into a private method called 'visit_home', so we can call it as needed.  

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

Note that these tests are a stopgap.  Some of them might turn out to be useful, but many of them will be too brittle for the long term.  But they can provide a bridge that allows you to proceed with an upgrade, to preserve the current functionality of the site, and to exercise the site enough to generate deprecation warnings.

Now for step 1.  We need a private method called 'login', as well as the relevant fixture data.  The Users model shows that our fixture needs to contain a username at least 7 characters long, a password, a valid email, and a date that is in the future, for the 'expires_at' value.

The log reveals that logging in is executed as a `post` to `/user/login`, which passes this data: 

    `user: { login: <login> , password: <p> }`

At this point, it might be more useful to divert from writing these tests, to writing tests for the Users model, or at least create a to-do item somewhere, noting that the users model should have tests that ensure we come back to testing the things we discovered.


Additionally the database turns out to contain hashed passwords, so we dig into the User model, and find the command used to hash a password:
Digest::SHA1.hexdigest(password)


We now have enough information to create our fixture, which looks like this:
```
good888:
  login: good888
  password: <%= Digest::SHA1.hexdigest("pw") %>
  physician_name: good
  email: good@email.com
  expires_at: <%= (Date.today + 5.days).to_s(:db) %> 
```

So, now we can try to log in from our test.  We should put login in its own method, but for now, let's just give this a shot as-is:

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

We run it, it seems to work, so now we can add this line, to check for the profile link on the home page:

```ruby
assert_select 'a[href=?]', "/user/profile/#{users(:good888).id}", {count: 1}
```


Then do a little refactoring, to break login into a reusable method, and finalize this test:

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tnordloh/your_legacy_tests. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
