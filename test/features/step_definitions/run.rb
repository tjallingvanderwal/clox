require 'open3'

When('compiling {string}') do |expression|
    lox_executable = ENV['LOX_EXECUTABLE']
    @stdout, @stderr, @status = Open3.capture3("#{lox_executable} --bytecode \"#{expression}\"")
end

When('evaluating {string}') do |expression|
    lox_executable = ENV['LOX_EXECUTABLE']
    @stdout, @stderr, @status = Open3.capture3("#{lox_executable} --eval \"#{expression}\"")
end

