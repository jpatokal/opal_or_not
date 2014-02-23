opal_or_not
===========

This is the source code behind [Opal or Not](http://www.opalornot.com).  Read more about it in the [FAQ](http://www.opalornot.com/faq).

Written with Sinatra because the application is essentially stateless, the fare comparison is done with a single backend call.  The Postgres DB is used only for keeping statistics, and can be disabled by removing the call to _.record_ from app.rb.

# Requirements

The following are what I develop with, but older/newer versions may well work.
* Ruby 2.1
* Postgres 9.3
* Bundler

Designed for easy hosting with [Heroku](http://heroku.com/).  See the Rakefile for tests, running locally, deploying, database preparation etc.

# License

This is licensed under [GNU Affero GPL](http://www.gnu.org/licenses/agpl-3.0.html).  Non-lawyerly TL;DR: You're welcome to use this as you wish, but if you modify this source code _and_ you put your modified version up on the Internet, you have to make your modified source code available for download as well.  (A public fork on Github will do nicely.)
