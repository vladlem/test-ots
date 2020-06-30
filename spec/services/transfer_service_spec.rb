require 'rails_helper'

describe TransferService do
  after do
    User.delete_all
  end

  context 'not valid user ids and amount' do
    let(:from_user_id) { 1 }
    let(:to_user_id) { 2 }
    let(:from_user) { User.create({ id: from_user_id, name: 'from_user' }) }
    let(:to_user) { User.create({ id: to_user_id, name: 'to_user' }) }

    it 'user ids are blank' do
      expect {
        TransferService.call(nil, nil, 100)
      }.to raise_error('Please send not blank user ids')
    end

    it 'blank amount' do
      expect {
        TransferService.call(from_user_id, to_user_id, '')
      }.to raise_error('Please set positive amount')
    end

    it 'negative amount' do
      expect {
        TransferService.call(from_user_id, to_user_id, -100)
      }.to raise_error('Please set positive amount')
    end

    it 'from user was not found' do
      expect {
        TransferService.call(from_user_id, to_user_id, 100)
      }.to raise_error.with_message("Couldn't find User with 'id'=#{from_user_id}")
    end

    it 'to user was not found' do
      expect {
        TransferService.call(from_user.id, to_user_id, 100)
      }.to raise_error.with_message("Couldn't find User with 'id'=#{to_user_id}")
    end
  end

  context 'valid user ids and amount' do
    let(:from_user) { User.create({ id: 1, name: 'from_user', balance: 100 }) }
    let(:to_user) { User.create({ id: 2, name: 'to_user' }) }

    it 'balance not changed if from user is less then amount' do
      TransferService.call(from_user.id, to_user.id, 200)
      expect(from_user.reload.balance).to eq(100)
      expect(to_user.reload.balance).to eq(0)
    end

    it 'balance changed correctly' do
      thread1 = Thread.new do
        TransferService.call(from_user.id, to_user.id, 50)
      end

      thread2 = Thread.new do
        TransferService.call(from_user.id, to_user.id, 50)
      end

      thread2.join
      thread1.join

      expect(from_user.reload.balance).to eq(0)
      expect(to_user.reload.balance).to eq(100)
    end
  end
end
