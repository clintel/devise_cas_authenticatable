module RubyCas
  class Session < ActiveRecord::SessionStore::Session
    before_save :save_cas_ticket
    
    def save_cas_ticket
      if self.data
        t = self.data['cas_last_valid_ticket']
        if t
          self.cas_ticket ||= t.ticket
        end
      end
    end
  end
end