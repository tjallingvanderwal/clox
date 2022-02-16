require 'open3'

When('running clox with {string}') do |commandline|
    lox_executable = ENV['LOX_EXECUTABLE']
    @stdout, @stderr, @status = Open3.capture3("#{lox_executable} #{commandline}")
end

When('evaluating {string}') do |expression|
    lox_executable = ENV['LOX_EXECUTABLE']
    raise "Use single quotes" if expression.include?('"')
    @stdout, @stderr, @status = Open3.capture3("#{lox_executable} --eval \"#{expression}\"")
end

When('compiling {string}') do |expression|
    lox_executable = ENV['LOX_EXECUTABLE']
    raise "Use only single quotes" if expression.include?('"')
    @stdout, @stderr, @status = Open3.capture3("#{lox_executable} --bytecode --eval \"#{expression}\"")
end

