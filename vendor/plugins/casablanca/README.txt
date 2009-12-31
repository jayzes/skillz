= Casablanca

* http://rubyforge.org/projects/casablanca/

== DESCRIPTION:

Casablanca is a ruby single sign-on client for the CAS 2.0 protocol.

== FEATURES:

* Includes a commandline Client to test getting service tickets from a CAS server
* It can be run as a Rails plugin
* Supports gatewaying and renewing

== TODO:

* Implement proxying
* Check for single signout

== SYNOPSIS:

=== Commandline:

  % casablanca

In IRB:

  require 'casablanca'

  C = Casablanca::CommandLineClient.new({ :cas_server_url => "http://localhost:4567",
                                        :service_url => "http://localhost:3000" })

  ticket = C.get_service_ticket('admin', 'admin')
  C.authenticate_ticket(ticket)


=== Rails:
Configure your Cas server url in environment.rb:

  Casablanca::Rails::Config.config do |config|
     config[:cas_server_url]  = "http://localhost:4567"
  end
  

Add filters to the protected controllers.
For most cases you would want the default filter:

  before_filter Casablanca::Rails::Filter
  
If you want users without credentials to view the page as well use the Gateway filter

  before_filter Casablanca::Rails::GatewayFilter
  
If you want users to always require new credentials for authentication use the renew filter

  before_filter Casablanca::Rails::RenewFilter  

Add something like the following to application.rb to get the current user from the Cas session:
  
  def current_user
    if session[:cas_user] && @user.nil?
        @user = User.find_by_name(session[:cas_user])
        logout_killing_session! unless @user
    end
    @user
  end

Your logout action could look like:

  def logout
    Casablanca::Rails::Filter.logout(self)
    redirect_to Casablanca::RailsFilter.logout_url(self)
  end
  
  
== REQUIREMENTS:

== INSTALL:

Stable version
* sudo gem install casablanca
Development version
* gem sources -a http://gems.github.com; sudo gem install p8-casablanca

== LICENSE:

(The MIT License)

Copyright (c) 2009 Petrik de Heus

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
