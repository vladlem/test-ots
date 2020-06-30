class TransferService

  class << self
    def call(from_user_id, to_user_id, amount)
      raise 'Please send not blank user ids' if from_user_id.blank? || to_user_id.blank?
      raise 'Please set positive amount' if amount.blank? || amount <= 0

      transfer_money(from_user_id, to_user_id, amount)
    end

    private

    def transfer_money(from_user_id, to_user_id, amount)
      begin
        User.transaction(isolation: :serializable) do
          from_user = User.find(from_user_id)
          to_user = User.find(to_user_id)
          raise ActiveRecord::Rollback if from_user.balance < amount

          from_user.update!(balance: from_user.balance - amount.to_f)
          to_user.update!(balance: to_user.balance + amount.to_f)
        end
      rescue ActiveRecord::StatementInvalid => e
        delay = rand * 0.01
        sleep delay

        retry
      end
    end
  end

end
