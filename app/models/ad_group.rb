class AdGroup < ApplicationRecord
  enum status: { enabled: 'ENABLED', paused: 'PAUSED', disabled: 'DISABLED' }
  enum xsi_type: { CpcBid: 'CpcBid', CpmBid: 'CpmBid' }

  self.primary_key = 'id'
end
