[<img src="https://badge.fury.io/rb/activerecord-nulldb-adapter.png" alt="Gem
Version" />](http://badge.fury.io/rb/activerecord-nulldb-adapter) [<img
src="https://codeclimate.com/github/nulldb/nulldb.png"
/>](https://codeclimate.com/github/nulldb/nulldb) [<img
src="https://github.com/nulldb/nulldb/workflows/build/badge.svg?branch=master"
alt="Build Status" />](https://github.com/nulldb/nulldb/actions)

# The NullDB Connection Adapter Plugin

## What

NullDB is the Null Object pattern as applied to ActiveRecord database
adapters.  It is a database backend that translates database interactions into
no-ops.  Using NullDB enables you to test your model business logic -
including `after_save` hooks - without ever touching a real database.

## Compatibility

### Ruby
Currently supported Ruby versions: `2.7.X`, `3.X`.

Experimental support provided for: JRuby

### ActiveRecord
Any version of ActiveRecord `>= 6.1`

## Installation

```bash
gem install activerecord-nulldb-adapter
```

## How

Once installed, NullDB can be used much like any other ActiveRecord database
adapter:

```ruby
ActiveRecord::Base.establish_connection :adapter => :nulldb
```

NullDB needs to know where you keep your schema file in order to reflect table
metadata.  By default it looks in RAILS_ROOT/db/schema.rb.  You can override
that by setting the `schema` option:

```ruby
ActiveRecord::Base.establish_connection :adapter => :nulldb,
                                        :schema  => 'foo/myschema.rb'
```

NullDB comes with RSpec integration.  To replace the database with NullDB in
all of your specs, put the following in your spec/rails_helper:

```ruby
require 'nulldb_rspec'
include NullDB::RSpec::NullifiedDatabase
```

after you load your rails environment

```ruby
require File.expand_path('../config/environment', __dir__)
```

otherwise you will encounter issues such as
([bug)](https://github.com/nulldb/nulldb/pull/90#issuecomment-496690958).

Or if you just want to use NullDB in a specific spec context, you can include
the same module inside a context:

```ruby
require 'nulldb_rspec'

describe Employee, "with access to the database" do
  fixtures :employees
  # ...
end

describe Employee, "with NullDB" do
  include NullDB::RSpec::NullifiedDatabase
  # ...
end
```

If you want to have NullDB enabled by default but disabled for particular
contexts then (see this
[post)](https://web.archive.org/web/20120419204019/http://andywaite.com/2011/5
/18/rspec-disable-nulldb)

NullDB::Rspec provides some custom matcher support for verifying expectations
about interactions with the database:

```ruby
describe Employee do
  include NullDB::RSpec::NullifiedDatabase

  it "should cause an insert statement to be executed" do
    Employee.create!
    Employee.connection.should have_executed(:insert)
  end
end
```

UnitRecord-style verification that no database calls have been made at all can
be achieved by using the special `:anything` symbol:

```ruby
describe "stuff that shouldn't touch the database" do
  after :each do
    Employee.connection.should_not have_executed(:anything)
  end
  # ...
end
```

You can also experiment with putting NullDB in your database.yml:

```yaml
unit_test:
  adapter: nulldb
```

However, due to the way Rails hard-codes specific database adapters into its
standard Rake tasks, you may find that this generates unexpected and
difficult-to-debug behavior.  Workarounds for this are under development.

## Why

There are a number of advantages to writing unit tests that never touch the
database.  The biggest is probably speed of execution - unit tests must be
fast for test-driven development to be practical. Another is separation of
concerns: unit tests should be exercising only the business logic contained in
your models, not ActiveRecord. For more on why testing-sans-database is a good
idea, see:
http://www.dcmanges.com/blog/rails-unit-record-test-without-the-database.

NullDB is one way to separate your unit tests from the database.  It was
inspired by the [ARBS](http://arbs.rubyforge.org/) and
[UnitRecord](http://unit-test-ar.rubyforge.org/) libraries.  It differs from
them in that rather than modifying parts of ActiveRecord, it implements the
same [semi-]well-documented public interface that the other standard database
adapters, like MySQL and SQLServer, implement. This has enabled it to evolve
to support new ActiveRecord versions relatively easily.

One concrete advantage of this null-object pattern design is that it is
possible with NullDB to test `after_save` hooks.  With NullDB, you can call
`#save` and all of the usual callbacks will be called - but nothing will be
saved.

## Limitations

*   It is **not** an in-memory database.  Finds will not work.  Neither will
    `reload`, currently.  Test fixtures won't work either, for obvious
    reasons.
*   It has only the most rudimentery schema/migration support.  Complex
    migrations will probably break it.
*   Lots of other things probably don't work.  Patches welcome!


## Who

NullDB was originally written by Avdi Grimm <mailto:avdi@avdi.org>. It is
currently maintained by [Danilo Cabello](https://github.com/cabello).
Previously maintained by: [Bram de Vries](https://github.com/blaet).

## Where

*   Homepage: https://github.com/nulldb/nulldb


## License

See the LICENSE file for licensing information.
