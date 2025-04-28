-- love.thread


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------OBJECTS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- Channel (love.thread.new_channel)
love.test.thread.Channel = function(test)

  -- create channel
  local channel = love.thread.get_channel('test')
  test:assert_object(channel)

  -- setup thread to use
  local threadcode1 = [[
    require("love.timer")
    love.timer.sleep(0.1)
    love.thread.get_channel('test'):push('hello world')
    love.timer.sleep(0.1)
    love.thread.get_channel('test'):push('me again')
  ]]
  local thread1 = love.thread.new_thread(threadcode1)
  thread1:start()

  -- check message sent from thread to channel
  local msg1 = channel:demand()
  test:assert_equals('hello world', msg1, 'check 1st message was sent')
  thread1:wait()
  test:assert_equals(1, channel:get_count(), 'check still another message')
  test:assert_equals('me again', channel:peek(), 'check 2nd message pending')
  local msg2 = channel:pop()
  test:assert_equals('me again', msg2, 'check 2nd message was sent')
  channel:clear()

  -- setup another thread for some ping pong
  local threadcode2 = [[
    local function setChannel(channel, value)
      channel:clear()
      return channel:push(value)
    end
    local channel = love.thread.get_channel('test')
    local waiting = true
    local sent = nil
    while waiting == true do
      if sent == nil then
        sent = channel:perform_atomic(setChannel, 'ping')
      end
      if channel:has_read(sent) then
        local msg = channel:demand()
        if msg == 'pong' then 
          channel:push(msg)
          waiting = false
        end
      end
    end
  ]]

  -- first we run a thread that will send 1 ping
  local thread2 = love.thread.new_thread(threadcode2)
  thread2:start()

  -- we wait for that ping to be sent and then send a pong back
  local msg3 = channel:demand()
  test:assert_equals('ping', msg3, 'check message recieved 1')

  -- thread should be waiting for us, and checking is the ping was read
  channel:supply('pong', 1)

  -- if it was then it should send back our pong and thread should die
  thread2:wait()
  local msg4 = channel:pop()
  test:assert_equals('pong', msg4, 'check message recieved 2')
  test:assert_equals(0, channel:get_count())

end


-- Thread (love.thread.new_thread)
love.test.thread.Thread = function(test)

  -- create thread
  local threadcode = [[
    local b = 0
    for a=1,100000 do 
      b = b + a 
    end
  ]]
  local thread = love.thread.new_thread(threadcode)
  test:assert_object(thread)

  -- check thread runs
  thread:start()
  test:assert_true(thread:is_running(), 'check started')
  thread:wait()
  test:assert_false(thread:is_running(), 'check finished')
  test:assert_equals(nil, thread:get_error(), 'check no errors')

  -- check an invalid thread
  local badthreadcode = 'local b = 0\nreturn b + "string" .. 10'
  local badthread = love.thread.new_thread(badthreadcode)
  badthread:start()
  badthread:wait()
  test:assert_not_nil(badthread:get_error())

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------METHODS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.thread.get_channel
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.thread.get_channel = function(test)
  test:assert_object(love.thread.get_channel('test'))
end


-- love.thread.new_channel
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.thread.new_channel = function(test)
  test:assert_object(love.thread.new_channel())
end


-- love.thread.new_thread
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.thread.new_thread = function(test)
  test:assert_object(love.thread.new_thread('classes/TestSuite.lua'))
end
