require 'dotenv/load'

AfterStep do
    if @stdin_stream
        puts 'closing streams'
        @stdin_stream.close
        @stdout_stream.close
        @stderr_stream.close
    end
end