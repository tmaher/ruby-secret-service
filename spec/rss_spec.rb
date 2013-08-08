require 'spec_helper'

describe SecretService do

  it "aborts when there's no env" do
    session_bus_env = ENV['DBUS_SESSION_BUS_ADDRESS']
    ENV['DBUS_SESSION_BUS_ADDRESS'] = nil
    expect {SecretService.new}.to raise_error(DBus::Connection::NameRequestError)
    ENV['DBUS_SESSION_BUS_ADDRESS'] = session_bus_env
  end
  
  it "can create a session" do
    SecretService.new.class.should_not be nil
  end

  it "has a default collection" do
    SecretService.new.collection.should_not be nil
  end

  it "can create and read back objects" do
    #name = SecureRandom.hex(8).to_s
    #secret = SecureRandom.hex(8).to_s
    #ss = SecretService.new
    #ss.collection.create_item("rspec_test_#{name}", secret).should_not be nil
    #ss.collection.get_secret("rspec_test_#{name}").should eq secret
  end
  
  it "can create locked objects" do
    true
  end

  it "can find objects" do
    ss = SecretService.new
    unlocked, locked = ss.search_items
    unlocked.kind_of?(Array).should eq true
    locked.kind_of?(Array).should eq true
    (locked + unlocked).each do |item|
      item.match(/^\/org\/freedesktop\/secrets\/collection/).nil?.should eq false
    end
  end

  it "can unlock objects" do
    ss = SecretService.new
    item_paths, prompt = ss.unlock(ss.search_items[1])
  end

  it "can raise a prompt" do
    ss = SecretService.new
    item_paths, prompt = ss.unlock(ss.search_items[1])
    ss.prompt!(prompt)
    new_items, new_prompt = ss.unlock(ss.search_items[1])
    new_prompt.should be_nil
    puts "new_items: #{new_items}"
  end
  
end