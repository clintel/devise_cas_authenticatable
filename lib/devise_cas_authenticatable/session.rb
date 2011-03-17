module RubyCas
  class Session < ActiveRecord::SessionStore::Session
    before_save :save_cas_ticket
    
    def self.find_by_session_id(session_id)
      find :first, :conditions => {:session_id=>session_id}
    end
    
    def save_cas_ticket
      if self.data && self.cas_ticket.nil?
        t = self.data['cas_last_valid_ticket']
        if t
          self.cas_ticket = t.ticket
        end
      end
    end
  end
end