require 'devise/strategies/base'

module Devise
  module Strategies
    class CasAuthenticatable < Base
      def valid?
        mapping.to.respond_to?(:authenticate_with_cas_ticket)
      end
      
      def authenticate!
        ticket = read_ticket(params)
        if ticket
          if resource = mapping.to.authenticate_with_cas_ticket(ticket)
            success!(resource)
          else
            fail(:invalid)
          end
        elsif returning_from_cas?
          fail(:invalid)
        else
          redirect!(login_url)
        end
      end
      
      protected
      def returning_from_cas?
        request.referer =~ /^#{::Devise.cas_client.cas_base_url}/
      end
     
      def login_url
        ::Devise.cas_client.add_service_to_login_url(service_url)
      end
      
      def service_url
        u = URI.parse(request.url)
        u.query = nil
        u.path = if mapping.respond_to?(:fullpath)
          mapping.fullpath
        else
          mapping.raw_path
        end
        u.to_s
      end
  
      def read_ticket(params)
        return session[:cas_last_valid_ticket] if session[:cas_last_valid_ticket]
        ticket = params[:ticket]
        return nil unless ticket
              
        if ticket =~ /^PT-/
          ::CASClient::ProxyTicket.new(ticket, service_url, params[:renew])
        else
          ::CASClient::ServiceTicket.new(ticket, service_url, params[:renew])
        end
      end
    end
  end
end

Warden::Strategies.add(:cas_authenticatable, Devise::Strategies::CasAuthenticatable)
