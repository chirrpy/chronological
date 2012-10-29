Chronological: The 'Start' of Your Fun Will Never 'End'
================================================================================

[![Build Status](https://secure.travis-ci.org/chirrpy/chronological.png?branch=master)](http://travis-ci.org/chirrpy/chronological)

Chronological is your one-stop solution for handling time ranges in your classes.

Have an item that is only available between two dates/times?  In these
situations, there is quite a bit of logic which is common among use
cases and that's what Chronological provides.

![Clock Tower Flier](http://www.thekompanee.com/public_files/clock-tower-flier-small.png)

Supported Rubies
--------------------------------------------------------------------------------
* MRI Ruby 1.9.2
* MRI Ruby 1.9.3
* JRuby (in 1.9 compat mode)

Installation
--------------------------------------------------------------------------------

First:

```ruby
gem install chronological
```

Then in your script:

```ruby
require 'chronological'
```

Finally in your class:

```ruby
include Chronological
```

or from IRB

    irb -r 'chronological'

Basic Usage
--------------------------------------------------------------------------------

The easiest way to use Chronological is to just let it know which [strategy](#strategies)
you would like to use for the time range for that particular object.

```ruby
class MyTimeRangeClass
  include Chronological

  timeframe  :type => :absolute
end
```

This will look for a `started_at` and an `ended_at` method on your object and
will base all of its dynamic methods on those.

Now you can use any of the methods that Chronological adds to your class:

--------------------------------------------------------------------------------
### Range Status Predicates

* `started?` - Whether it is currently on or after the start date
* `ended?` - Whether it is currently on or after the end date
* `not_yet_ended?` - Whether it is currently before the end date
* `in_progress?` _(aliased to `active?`)_ - Whether it is between the start and end dates
* `inactive?` - The inverse of `in_progress?`/`active?`

--------------------------------------------------------------------------------
### Scheduling Validity Predicates

* `scheduled?` - Whether all of the pieces needed to determine a timeframe have been set
* `partially_scheduled?` - Whether _any_ of the pieces needed to determine a timeframe have been set

--------------------------------------------------------------------------------
### Range Type Predicates

* `same_day?` - Whether the starting time and the ending time are on the same day
* `one_day?` - Whether the starting time and the ending time are less than 24 hours apart
* `multi_day?` - Whether the starting time and the ending time are on different days

--------------------------------------------------------------------------------
### Other Methods

* `duration` - A Hash containing the days, hours, minutes and seconds

--------------------------------------------------------------------------------
### Scopes

Each of these methods also has a corresponding ActiveRelation method that will
represents all of the items that meet the requirements of that method.

* `started`
* `ended`
* `not_yet_ended`
* `in_progress` _(also aliased to `active?`)_
* `scheduled`
* `partially_scheduled`
* `one_day`
* `multi_day`

#### Example

If this is true:

```ruby
range_instance = InstanceWithTimeRange.create

range_instance.started? #=> true
```

Then this would also be the case:

```ruby
expect { InstanceWithTimeRange.started }.to include range_instance #=> true
```

### Ordering

* `by_duration(:asc)` - Sort the results by the length of the duration
* `by_date(:asc)` - Intelligently sort based on the start and end date

Advanced Usage
--------------------------------------------------------------------------------
_Note 1: All durations and offsets are represented in seconds._
_Note 2: All 'Defaults' are in the same order as the 'Options' above them._

### Strategies

Chronological is extremely flexible and can handle multiple strategies for
calculating your time range information.

If you choose to use our default field names, you can simply pass the strategy
in as a symbol and it will Just Work(tm).

```ruby
class MyTimeRangeClass
  timeframe :type => :duration_until_end
end
```

Alternatively, you can pass in the specific set of options per strategy as a
hash and set the values to the field names you want Chronological to use.

```ruby
class MyTimeRangeClass
  timeframe :ending_time => :available_until,
            :duration    => :length_of_availability
end
```

--------------------------------------------------------------------------------
#### Absolute

**Options:** `starting_time` and `ending_time`

**Defaults:** `started_at` and `ended_at`

**Example:** The concert starts at 5:30pm and ends at 11:30pm

--------------------------------------------------------------------------------
#### Relative

**Options:** `base_of_offset`, `starting_offset` and `ending_offset`

**Defaults:** `base_of_range_offset`, `start_of_range_offset` and `end_of_range_offset`

**Example:** You can buy the ticket anytime between 1-2 weeks before the event starts

--------------------------------------------------------------------------------
#### Dual Relative

**Options:** `base_of_starting_offset`, `starting_offset`, `base_of_ending_offset` and `ending_offset`

**Defaults:** `base_of_range_starting_offset`, `start_of_range_offset`, `base_of_range_ending_offset` and `end_of_range_offset`

**Example:** The coupon is active from 2 hours after the first sale until 3 hours before the store closes

--------------------------------------------------------------------------------
#### Duration From Start

**Options:** `starting_time`, `duration`

**Defaults:** `started_at` and `duration_in_seconds`

**Example:** The donut shop opens at 7am but only for 30 minutes

--------------------------------------------------------------------------------
#### Duration Until End

**Options:** `ending_time`, `duration`

**Defaults:** `ended_at` and `duration_in_seconds`

**Example:** Your 'roadie' pass will only get you backstage for the 30 minutes before the band goes on stage at 9pm

--------------------------------------------------------------------------------
#### Duration From Relative Start

**Options:** `base_of_starting_offset`, `starting_offset` and `duration`

**Defaults:** `base_of_range_starting_offset`, `start_of_range_offset` and `duration_in_seconds`

**Example:** The party will start 30 minutes after the concert ends and last for 4 hours

--------------------------------------------------------------------------------
#### Duration Until A Relative End

**Options:** `base_of_ending_offset`, `ending_offset` and `duration`

**Defaults:** `base_of_range_ending_offset`, `end_of_range_offset` and `duration_in_seconds`

**Example:** The secret vault will be open for 3 hours and will relock 15 minutes prior to the office opening

### Determining Absolute Dates

Other than the 'Absolute' strategy above, any of those combinations will
calculate the absolute dates of the time range and make them available via
these accessors:

  * `started_at`
  * `ended_at`
  * `started_on`
  * `ended_on`

If you want to override these values, simply pass in the
`absolute_start_date_field`, `absolute_end_date_field`,
`absolute_start_time_field` and/or `absolute_end_time_field` options to
`timeframe` like so:

#### Example

```ruby
class MyTimeRangeClass
  timeframe :base_of_offset             => :event_start_time,
            :starting_offset            => :starting_availability_offset
            :ending_offset              => :ending_availability_offset,
            :absolute_start_time_field  => :starting_time
            :absolute_end_time_field    => :ending_time
end
```

### Advanced Method Usage

--------------------------------------------------------------------------------
#### Range Status As Of A Given Date

All range status methods can take an `:as_of` option which will replace the
default behavior which is `Time.now.utc`.  Using this option you can more easily
see if an instance (or instances) would be started, ended, etc as of a given
date.

Affected methods:

* `started?`
* `ended?`
* `not_yet_ended?`
* `in_progress?` _(or `active?`)_
* `inactive?`

Affected scopes:

* `started`
* `ended`
* `not_yet_ended`
* `in_progress` _(or `active`)_
* `inactive?`

```ruby
range_instance = MyTimeRangeClass.create

range_instance.ended?                               #=> false
range_instance.ended? :as_of => 42.years.from_now   #=> true

MyTimeRangeClass.ended                              #=> []
MyTimeRangeClass.ended :as_of => 42.years.from_now  #=> [range_instance]
```

## Is It Scheduled?

Even though Chronological does not handle anything having to do with time
zones, it is valid however, to assume there will be use cases where,
without a time zone, the model should not be considered `scheduled`.

If you wish to account for this, pass in the `:time_zone` option to
`timeframe` and give it the field name that contains the time zone you
wish to use.  For example:

```ruby
class MyTimeRangeClass
  timeframe  :starting_time => :started_at,
             :ending_time   => :ended_at,
             :time_zone     => :time_zone
end

range_instance            = MyTimeRangeClass.new
range_instance.started_at = 5.minutes.from_now
range_instance.ended_at   = 30.minutes.from_now

range_instance.scheduled? # => false

range_instance.time_zone  = 'Alaska'

range_instance.scheduled? # => true
```

Issues
--------------------------------

If you have problems, please create a [Github issue](https://github.com/chirrpy/chronological/issues).

Credits
--------------------------------

![chirrpy](https://dl.dropbox.com/s/f9s2qd0kmbc8nwl/github_logo.png?dl=1)

greenwich is maintained by [Chrrpy, LLC](http://chirrpy.com)

The names and logos for Chirrpy are trademarks of Chrrpy, LLC

Contributors
--------------------------------
* [Jeff Felchner](https://github.com/jfelchner)
* [Mark McEahern](https://github.com/m5rk)

License
--------------------------------

chronological is Copyright &copy; 2012 Chirrpy. It is free software, and may be redistributed under the terms specified in the LICENSE file.
