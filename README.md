Wrapped
-------

This gem is a tool you can use while developing your API to help consumers of your code to find bugs earlier and faster. It works like this: any time you write a method that could produce nil, you instead write a method that produces a wrapped value.

Example
-------

Here's an example along with how it can help with errors:

Say you have a collection of users along with a method for accessing the first user:

    class UserCollection
      def initialize(users)
        @users = users
      end
  
      def first_user
        @users.first
      end
    end

Now your friend uses your awesome UserCollection code:

    class FriendGroups
      def initialize(user_collections)
        @user_collections = user_collections
      end

      def first_names
        @user_collections.map do |user_collection|
          user_collection.first_user.first_name
        end
      end
    end

And then she tries it:

    FriendGroups.new([UserCollection.new([])]).first_names

... and it promptly blows up:

    NoMethodError: undefined method `first_name' for nil:NilClass
            from (irb):52:in `first_names'
            from (irb):51:in `map'
            from (irb):51:in `first_names'
            from (irb):57

But that's odd; UserCollection definitely has a `#first_names` method, and we definitely passed a UserCollection, and ... oooh, we passed no users, and so we got `nil`.

Right.

Instead what you want to do is wrap it. Wrap that nil. Make the user know that they have to consider the result.

    class UserCollection
      def initialize(users)
        @users = users
      end
  
      def first_user
        @users.first.wrapped
      end
    end

Now in your documentation you explain that it produces a wrapped value. And people who skip documentation and instead read source code will see that it is wrapped.

So they unwrap it, because they must. They can't even get happy path without unwrapping it.

    class FriendGroups
      def initialize(user_collections)
        @user_collections = user_collections
      end

      def first_names
        @user_collections.map do |user_collection|
          user_collection.first_user.inject('') do |default,user|
            user.first_name
          end
        end
      end
    end

Cool Stuff
----------

In the example above I made use of the fact that a wrapped value mixes in Enumerable. The functional world would say "that's a functor!". That's right it is.

This means that you can `map`, `inject`, `to_a`, `any?`, and so on over your wrapped value. By wrapping it you've just made it more powerful!

Other Methods
-------------

Then we added some convenience methods to all of this. Here's a tour:

    irb(main):001:0> require 'wrapped'
    => true
    irb(main):002:0> 1.wrapped.unwrap_or(-1)
    => 1
    irb(main):003:0> nil.wrapped.unwrap_or(-1)
    => -1
    irb(main):004:0> 1.wrapped.present {|n| p n }.blank { puts "nothing!" }
    1
    => #<Present:0x7fc570aed0e8 @value=1>
    irb(main):005:0> nil.wrapped.present {|n| p n }.blank { puts "nothing!" }
    nothing!
    => #<Blank:0x7fc570ae21c0>
    irb(main):006:0> 1.wrapped.unwrap
    => 1
    irb(main):007:0> nil.wrapped.unwrap
    IndexError: Blank has no value
    	from /home/mike/wrapped/lib/wrapped/types.rb:43:in `unwrap'
    	from (irb):7
    irb(main):008:0> 1.wrapped.present?
    => true
    irb(main):009:0> nil.wrapped.present?
    => false
    irb(main):010:0> nil.wrapped.blank?
    => true
    irb(main):011:0> 1.wrapped.blank?
    => false

Inspiration
-----------

Inspired by a conversation about a post on the thoughtbot blog titled "If you gaze into nil, nil gazes also into you":
  http://robots.thoughtbot.com/post/8181879506/if-you-gaze-into-nil-nil-gazes-also-into-you

Most ideas are from Haskell and Scala. This is not new: look into the maybe monad or the option class for more.

Copyright
---------
Copyright 2011 Mike Burns
