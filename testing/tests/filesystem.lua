-- love.filesystem


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------OBJECTS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- File (love.filesystem.new_file)
love.test.filesystem.File = function(test)

  -- setup a file to play with
  local file1 = love.filesystem.open_file('data.txt', 'w')
  file1:write('helloworld')
  test:assert_object(file1)
  file1:close()

  -- test read mode
  file1:open('r')
  test:assert_equals('r', file1:get_mode(), 'check read mode')
  local contents, size = file1:read()
  test:assert_equals('helloworld', contents)
  test:assert_equals(10, size, 'check file read')
  test:assert_equals(10, file1:get_size())
  local ok1, err1 = file1:write('hello')
  test:assert_not_equals(nil, err1, 'check cant write in read mode')
  local iterator = file1:lines()
  test:assert_not_equals(nil, iterator, 'check can read lines')
  test:assert_equals('data.txt', file1:get_filename(), 'check filename matches')
  file1:close()

  -- test write mode
  file1:open('w')
  test:assert_equals('w', file1:get_mode(), 'check write mode')
  contents, size = file1:read()
  test:assert_equals(nil, contents, 'check cant read file in write mode')
  test:assert_equals('string', type(size), 'check err message shown')
  local ok2, err2 = file1:write('helloworld')
  test:assert_true(ok2, 'check file write')
  test:assert_equals(nil, err2, 'check no err writing')

  -- test open/closing
  file1:open('r')
  test:assert_true(file1:is_open(), 'check file is open')
  file1:close()
  test:assert_false(file1:is_open(), 'check file gets closed')
  file1:close()

  -- test buffering and flushing
  file1:open('w')
  local ok3, err3 = file1:set_buffer('full', 10000)
  test:assert_true(ok3)
  test:assert_equals('full', file1:get_buffer())
  file1:write('replacedcontent')
  file1:flush()
  file1:close()
  file1:open('r')
  contents, size = file1:read()
  test:assert_equals('replacedcontent', contents, 'check buffered content was written')
  file1:close()

  -- loop through file data with seek/tell until EOF
  file1:open('r')
  local counter = 0
  for i=1,100 do
    file1:seek(i)
    test:assert_equals(i, file1:tell())
    if file1:is_eof() == true then
      counter = i
      break
    end
  end
  test:assert_equals(counter, 15)
  file1:close()

end


-- FileData (love.filesystem.new_file_data)
love.test.filesystem.FileData = function(test)

  -- create new obj
  local fdata = love.filesystem.new_file_data('helloworld', 'test.txt')
  test:assert_object(fdata)
  test:assert_equals('test.txt', fdata:get_filename())
  test:assert_equals('txt', fdata:get_extension())

  -- check properties match expected
  test:assert_equals('helloworld', fdata:get_string(), 'check data string')
  test:assert_equals(10, fdata:get_size(), 'check data size')

  -- check cloning the bytedata
  local clonedfdata = fdata:clone()
  test:assert_object(clonedfdata)
  test:assert_equals('helloworld', clonedfdata:get_string(), 'check cloned data')
  test:assert_equals(10, clonedfdata:get_size(), 'check cloned size')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.filesystem.append
love.test.filesystem.append = function(test)
	-- create a new file to test with
	love.filesystem.write('filesystem.append.txt', 'foo')
	-- try appending text and check new file contents/size matches
	local success, message = love.filesystem.append('filesystem.append.txt', 'bar')
  test:assert_not_equals(false, success, 'check success')
  test:assert_equals(nil, message, 'check no error msg')
	local contents, size = love.filesystem.read('filesystem.append.txt')
	test:assert_equals(contents, 'foobar', 'check file contents')
	test:assert_equals(size, 6, 'check file size')
  -- check appending a specific no. of bytes
  love.filesystem.append('filesystem.append.txt', 'foobarfoobarfoo', 6)
  contents, size = love.filesystem.read('filesystem.append.txt')
  test:assert_equals(contents, 'foobarfoobar', 'check appended contents')
  test:assert_equals(size, 12, 'check appended size')
  -- cleanup
  love.filesystem.remove('filesystem.append.txt')
end


-- love.filesystem.are_symlinks_enabled
-- @NOTE best can do here is just check not nil
love.test.filesystem.are_symlinks_enabled = function(test)
  test:assert_not_nil(love.filesystem.are_symlinks_enabled())
end


-- love.filesystem.create_directory
love.test.filesystem.create_directory = function(test)
  -- try creating a dir + subdir and check both exist
  local success = love.filesystem.create_directory('foo/bar')
  test:assert_not_equals(false, success, 'check success')
  test:assert_not_equals(nil, love.filesystem.get_info('foo', 'directory'), 'check directory created')
  test:assert_not_equals(nil, love.filesystem.get_info('foo/bar', 'directory'), 'check subdirectory created')
  -- cleanup
  love.filesystem.remove('foo/bar')
  love.filesystem.remove('foo')
end


-- love.filesystem.get_appdata_directory
-- @NOTE i think this is too platform dependent to be tested nicely
love.test.filesystem.get_appdata_directory = function(test)
  test:assert_not_nil(love.filesystem.get_appdata_directory())
end


-- love.filesystem.get_c_require_path
love.test.filesystem.get_c_require_path = function(test)
  -- check default value from documentation
  test:assert_equals('??', love.filesystem.get_c_require_path(), 'check default value')
end


-- love.filesystem.get_directory_items
love.test.filesystem.get_directory_items = function(test)
  -- create a dir + subdir with 2 files
  love.filesystem.create_directory('foo/bar')
	love.filesystem.write('foo/file1.txt', 'file1')
  love.filesystem.write('foo/bar/file2.txt', 'file2')
  -- check both the file + subdir exist in the item list
  local files = love.filesystem.get_directory_items('foo')
  local hasfile = false
  local hasdir = false
  for _,v in ipairs(files) do
    local info = love.filesystem.get_info('foo/'..v)
    if v == 'bar' and info.type == 'directory' then hasdir = true end
    if v == 'file1.txt' and info.type == 'file' then hasfile = true end
  end
  test:assert_true(hasfile, 'check file exists')
  test:assert_true(hasdir, 'check directory exists')
  -- cleanup
  love.filesystem.remove('foo/file1.txt')
  love.filesystem.remove('foo/bar/file2.txt')
  love.filesystem.remove('foo/bar')
  love.filesystem.remove('foo')
end


-- love.filesystem.get_full_common_path
love.test.filesystem.get_full_common_path = function(test)
  -- check standard paths
  local appsavedir = love.filesystem.get_full_common_path('appsavedir')
  local appdocuments = love.filesystem.get_full_common_path('appdocuments')
  local userhome = love.filesystem.get_full_common_path('userhome')
  local userappdata = love.filesystem.get_full_common_path('userappdata')
  local userdesktop = love.filesystem.get_full_common_path('userdesktop')
  local userdocuments = love.filesystem.get_full_common_path('userdocuments')
  test:assert_not_nil(appsavedir)
  test:assert_not_nil(appdocuments)
  test:assert_not_nil(userhome)
  test:assert_not_nil(userappdata)
  test:assert_not_nil(userdesktop)
  test:assert_not_nil(userdocuments)
  -- check invalid path
  local ok = pcall(love.filesystem.get_full_common_path, 'fakepath')
  test:assert_false(ok, 'check invalid common path')
end


-- love.filesystem.get_identity
love.test.filesystem.get_identity = function(test)
  -- check setting identity matches
  local original = love.filesystem.get_identity()
  love.filesystem.set_identity('lover')
  test:assert_equals('lover', love.filesystem.get_identity(), 'check identity matches')
  -- put back to original value
  love.filesystem.set_identity(original)
end


-- love.filesystem.get_real_directory
love.test.filesystem.get_real_directory = function(test)
  -- make a test dir + file first
  love.filesystem.create_directory('foo')
  love.filesystem.write('foo/test.txt', 'test')
  -- check save dir matches the real dir we just wrote to
  test:assert_equals(love.filesystem.get_save_directory(),
    love.filesystem.get_real_directory('foo/test.txt'), 'check directory matches')
  -- cleanup
  love.filesystem.remove('foo/test.txt')
  love.filesystem.remove('foo')
end


-- love.filesystem.get_require_path
love.test.filesystem.get_require_path = function(test)
  test:assert_equals('?.lua;?/init.lua',
    love.filesystem.get_require_path(), 'check default value')
end


-- love.filesystem.get_source
-- @NOTE i dont think we can test this cos love calls it first
love.test.filesystem.get_source = function(test)
  test:skip_test('used internally')
end


-- love.filesystem.get_source_base_directory
-- @NOTE i think this is too platform dependent to be tested nicely
love.test.filesystem.get_source_base_directory = function(test)
  test:assert_not_nil(love.filesystem.get_source_base_directory())
end


-- love.filesystem.get_user_directory
-- @NOTE i think this is too platform dependent to be tested nicely
love.test.filesystem.get_user_directory = function(test)
  test:assert_not_nil(love.filesystem.get_user_directory())
end


-- love.filesystem.get_working_directory
-- @NOTE i think this is too platform dependent to be tested nicely
love.test.filesystem.get_working_directory = function(test)
  test:assert_not_nil(love.filesystem.get_working_directory())
end


-- love.filesystem.get_save_directory
-- @NOTE i think this is too platform dependent to be tested nicely
love.test.filesystem.get_save_directory = function(test)
  test:assert_not_nil(love.filesystem.get_save_directory())
end


-- love.filesystem.get_info
love.test.filesystem.get_info = function(test)
  -- create a dir and subdir with a file
  love.filesystem.create_directory('foo/bar')
  love.filesystem.write('foo/bar/file2.txt', 'file2')
  -- check getinfo returns the correct values
  test:assert_equals(nil, love.filesystem.get_info('foo/bar/file2.txt', 'directory'), 'check not directory')
  test:assert_not_equals(nil, love.filesystem.get_info('foo/bar/file2.txt'), 'check info not nil')
  test:assert_equals(love.filesystem.get_info('foo/bar/file2.txt').size, 5, 'check info size match')
  test:assert_false(love.filesystem.get_info('foo/bar/file2.txt').readonly, 'check readonly')
  -- @TODO test modified timestamp from info.modtime?
  -- cleanup
  love.filesystem.remove('foo/bar/file2.txt')
  love.filesystem.remove('foo/bar')
  love.filesystem.remove('foo')
end


-- love.filesystem.is_fused
love.test.filesystem.is_fused = function(test)
  -- kinda assuming you'd run the testsuite in a non-fused game
  test:assert_equals(love.filesystem.is_fused(), false, 'check not fused')
end


-- love.filesystem.lines
love.test.filesystem.lines = function(test)
  -- check lines returns the 3 lines expected
  love.filesystem.write('file.txt', 'line1\nline2\nline3')
  local linenum = 1
  for line in love.filesystem.lines('file.txt') do
    test:assert_equals('line' .. tostring(linenum), line, 'check line matches')
    -- also check it removes newlines like the docs says it does
    test:assert_equals(nil, string.find(line, '\n'), 'check newline removed')
    linenum = linenum + 1
  end
  -- cleanup
  love.filesystem.remove('file.txt')
end


-- love.filesystem.load
love.test.filesystem.load = function(test)
  -- setup some fake lua files
  love.filesystem.write('test1.lua', 'function test()\nreturn 1\nend\nreturn test()')
  love.filesystem.write('test2.lua', 'function test()\nreturn 1')

  if test:is_at_least_lua_version(5.2) or test:is_lua_jit_enabled() then
    -- check file that doesn't exist
    local chunk1, errormsg1 = love.filesystem.load('faker.lua', 'b')
    test:assert_equals(nil, chunk1, 'check file doesnt exist')
    -- check valid lua file (text load)
    local chunk2, errormsg2 = love.filesystem.load('test1.lua', 't')
    test:assert_equals(nil, errormsg2, 'check no error message')
    test:assert_equals(1, chunk2(), 'check lua file runs')
  else
    local _, errormsg3 = love.filesystem.load('test1.lua', 'b')
    test:assert_not_equals(nil, errormsg3, 'check for an error message')

    local _, errormsg4 = love.filesystem.load('test1.lua', 't')
    test:assert_not_equals(nil, errormsg4, 'check for an error message')
  end

  -- check valid lua file (any load)
  local chunk5, errormsg5 = love.filesystem.load('test1.lua', 'bt')
  test:assert_equals(nil, errormsg5, 'check no error message')
  test:assert_equals(1, chunk5(), 'check lua file runs')

  -- check invalid lua file
  local ok, chunk, err = pcall(love.filesystem.load, 'test2.lua')
  test:assert_false(ok, 'check invalid lua file')
  -- cleanup
  love.filesystem.remove('test1.lua')
  love.filesystem.remove('test2.lua')
end


-- love.filesystem.mount
love.test.filesystem.mount = function(test)
  -- write an example zip to savedir to use
  local contents, size = love.filesystem.read('resources/test.zip') -- contains test.txt
  love.filesystem.write('test.zip', contents, size)
  -- check mounting file and check contents are mounted
  local success = love.filesystem.mount('test.zip', 'test')
  test:assert_true(success, 'check success')
  test:assert_not_equals(nil, love.filesystem.get_info('test'), 'check mount not nil')
  test:assert_equals('directory', love.filesystem.get_info('test').type, 'check directory made')
  test:assert_not_equals(nil, love.filesystem.get_info('test/test.txt'), 'check file not nil')
  test:assert_equals('file', love.filesystem.get_info('test/test.txt').type, 'check file type')
  -- cleanup
  love.filesystem.remove('test/test.txt')
  love.filesystem.remove('test')
  love.filesystem.remove('test.zip')
end


-- love.filesystem.mount_full_path
love.test.filesystem.mount_full_path = function(test)
  -- mount something in the working directory
  local mount = love.filesystem.mount_full_path(love.filesystem.get_source() .. '/tests', 'tests', 'read')
  test:assert_true(mount, 'check can mount')
  -- check reading file through mounted path label
  local contents, _ = love.filesystem.read('tests/audio.lua')
  test:assert_not_equals(nil, contents)
  local unmount = love.filesystem.unmount_full_path(love.filesystem.get_source() .. '/tests')
  test:assert_true(unmount, 'reset mount')
end


-- love.filesystem.unmount_full_path
love.test.filesystem.unmount_full_path = function(test)
  -- try unmounting something we never mounted
  local unmount1 = love.filesystem.unmount_full_path(love.filesystem.get_source() .. '/faker')
  test:assert_false(unmount1, 'check not mounted to start with')
  -- mount something to unmount after
  love.filesystem.mount_full_path(love.filesystem.get_source() .. '/tests', 'tests', 'read')
  local unmount2 = love.filesystem.unmount_full_path(love.filesystem.get_source() .. '/tests')
  test:assert_true(unmount2, 'check unmounted')
end


-- love.filesystem.mount_common_path
love.test.filesystem.mount_common_path = function(test)
  -- check if we can mount all the expected paths
  local mount1 = love.filesystem.mount_common_path('appsavedir', 'appsavedir', 'readwrite')
  local mount2 = love.filesystem.mount_common_path('appdocuments', 'appdocuments', 'readwrite')
  local mount3 = love.filesystem.mount_common_path('userhome', 'userhome', 'readwrite')
  local mount4 = love.filesystem.mount_common_path('userappdata', 'userappdata', 'readwrite')
  -- userdesktop isnt valid on linux
  if not test:is_os('Linux') then
    local mount5 = love.filesystem.mount_common_path('userdesktop', 'userdesktop', 'readwrite')
    test:assert_true(mount5, 'check mount userdesktop')
  end
  local mount6 = love.filesystem.mount_common_path('userdocuments', 'userdocuments', 'readwrite')
  local ok = pcall(love.filesystem.mount_common_path, 'fakepath', 'fake', 'readwrite')
  test:assert_false(mount1, 'check mount appsavedir') -- This is already mounted, we can't do it again.
  test:assert_true(mount2, 'check mount appdocuments')
  test:assert_true(mount3, 'check mount userhome')
  test:assert_true(mount4, 'check mount userappdata')
  test:assert_true(mount6, 'check mount userdocuments')
  test:assert_false(ok, 'check mount invalid common path fails')
end


-- love.filesystem.unmount_common_path
--love.test.filesystem.unmount_common_path = function(test)
--  -- check unmounting invalid
--  local ok = pcall(love.filesystem.unmount_common_path, 'fakepath')
--  test:assert_false(ok, 'check unmount invalid common path')
--  -- check mounting valid paths
--  love.filesystem.mount_common_path('appsavedir', 'appsavedir', 'read')
--  love.filesystem.mount_common_path('appdocuments', 'appdocuments', 'read')
--  love.filesystem.mount_common_path('userhome', 'userhome', 'read')
--  love.filesystem.mount_common_path('userappdata', 'userappdata', 'read')
--  love.filesystem.mount_common_path('userdesktop', 'userdesktop', 'read')
--  love.filesystem.mount_common_path('userdocuments', 'userdocuments', 'read')
--  local unmount1 = love.filesystem.unmount_common_path('appsavedir')
--  local unmount2 = love.filesystem.unmount_common_path('appdocuments')
--  local unmount3 = love.filesystem.unmount_common_path('userhome')
--  local unmount4 = love.filesystem.unmount_common_path('userappdata')
--  local unmount5 = love.filesystem.unmount_common_path('userdesktop')
--  local unmount6 = love.filesystem.unmount_common_path('userdocuments')
--  test:assert_true(unmount1, 'check unmount appsavedir')
--  test:assert_true(unmount2, 'check unmount appdocuments')
--  test:assert_true(unmount3, 'check unmount userhome')
--  test:assert_true(unmount4, 'check unmount userappdata')
--  test:assert_true(unmount5, 'check unmount userdesktop')
--  test:assert_true(unmount6, 'check unmount userdocuments')
--  -- remount or future tests fail
--  love.filesystem.mount_common_path('appsavedir', 'appsavedir', 'readwrite')
--  love.filesystem.mount_common_path('appdocuments', 'appdocuments', 'readwrite')
--  love.filesystem.mount_common_path('userhome', 'userhome', 'readwrite')
--  love.filesystem.mount_common_path('userappdata', 'userappdata', 'readwrite')
--  love.filesystem.mount_common_path('userdesktop', 'userdesktop', 'readwrite')
--  love.filesystem.mount_common_path('userdocuments', 'userdocuments', 'readwrite')
--end


-- love.filesystem.open_file
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.filesystem.open_file = function(test)
  test:assert_not_nil(love.filesystem.open_file('file2.txt', 'w'))
  test:assert_not_nil(love.filesystem.open_file('file2.txt', 'r'))
  test:assert_not_nil(love.filesystem.open_file('file2.txt', 'a'))
  test:assert_not_nil(love.filesystem.open_file('file2.txt', 'c'))
  love.filesystem.remove('file2.txt')
end


-- love.filesystem.new_file_data
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.filesystem.new_file_data = function(test)
  test:assert_not_nil(love.filesystem.new_file_data('helloworld', 'file1'))
end


-- love.filesystem.read
love.test.filesystem.read = function(test)
  -- check reading a full file
  local content, size = love.filesystem.read('resources/test.txt')
  test:assert_not_equals(nil, content, 'check not nil')
  test:assert_equals('helloworld', content, 'check content match')
  test:assert_equals(10, size, 'check size match')
  -- check reading partial file
  content, size = love.filesystem.read('resources/test.txt', 5)
  test:assert_not_equals(nil, content, 'check not nil')
  test:assert_equals('hello', content, 'check content match')
  test:assert_equals(5, size, 'check size match')
end


-- love.filesystem.remove
love.test.filesystem.remove = function(test)
  -- create a dir + subdir with a file
  love.filesystem.create_directory('foo/bar')
  love.filesystem.write('foo/bar/file2.txt', 'helloworld')
  -- check removing files + dirs (should fail to remove dir if file inside)
  test:assert_false(love.filesystem.remove('foo'), 'check fail when file inside')
  test:assert_false(love.filesystem.remove('foo/bar'), 'check fail when file inside')
  test:assert_true(love.filesystem.remove('foo/bar/file2.txt'), 'check file removed')
  test:assert_true(love.filesystem.remove('foo/bar'), 'check subdirectory removed')
  test:assert_true(love.filesystem.remove('foo'), 'check directory removed')
  -- cleanup not needed here hopefully...
end


-- love.filesystem.set_c_require_path
love.test.filesystem.set_c_require_path = function(test)
  -- check setting path val is returned
  love.filesystem.set_c_require_path('/??')
  test:assert_equals('/??', love.filesystem.get_c_require_path(), 'check crequirepath value')
  love.filesystem.set_c_require_path('??')
end


-- love.filesystem.set_identity
love.test.filesystem.set_identity = function(test)
  -- check setting identity val is returned
  local original = love.filesystem.get_identity()
  love.filesystem.set_identity('lover')
  test:assert_equals('lover', love.filesystem.get_identity(), 'check indentity value')
  -- return value to original
  love.filesystem.set_identity(original)
end


-- love.filesystem.set_require_path
love.test.filesystem.set_require_path = function(test)
  -- check setting path val is returned
  love.filesystem.set_require_path('?.lua;?/start.lua')
  test:assert_equals('?.lua;?/start.lua', love.filesystem.get_require_path(), 'check require path')
  -- reset to default
  love.filesystem.set_require_path('?.lua;?/init.lua')
end


-- love.filesystem.set_source
love.test.filesystem.set_source = function(test)
  test:skip_test('used internally')
end


-- love.filesystem.unmount
love.test.filesystem.unmount = function(test)
  -- create a zip file mounted to use
  local contents, size = love.filesystem.read('resources/test.zip') -- contains test.txt
  love.filesystem.write('test.zip', contents, size)
  love.filesystem.mount('test.zip', 'test')
  -- check mounted, unmount, then check its unmounted
  test:assert_not_equals(nil, love.filesystem.get_info('test/test.txt'), 'check mount exists')
  love.filesystem.unmount('test.zip')
  test:assert_equals(nil, love.filesystem.get_info('test/test.txt'), 'check unmounted')
  -- cleanup
  love.filesystem.remove('test/test.txt')
  love.filesystem.remove('test')
  love.filesystem.remove('test.zip')
end


-- love.filesystem.write
love.test.filesystem.write = function(test)
  -- check writing a bunch of files matches whats read back
  love.filesystem.write('test1.txt', 'helloworld')
  love.filesystem.write('test2.txt', 'helloworld', 10)
  love.filesystem.write('test3.txt', 'helloworld', 5)
  test:assert_equals('helloworld', love.filesystem.read('test1.txt'), 'check read file')
  test:assert_equals('helloworld', love.filesystem.read('test2.txt'), 'check read all')
  test:assert_equals('hello', love.filesystem.read('test3.txt'), 'check read partial')
  -- cleanup
  love.filesystem.remove('test1.txt')
  love.filesystem.remove('test2.txt')
  love.filesystem.remove('test3.txt')
end
