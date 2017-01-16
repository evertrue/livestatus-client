require 'livestatus-client/version'
require 'trollop'
require 'yaml'
require 'socket'
require 'json'

class LivestatusClient
  def run
    if opts[:query]
      if opts[:list]
        display_columns
      else
        puts JSON.pretty_generate query opts[:query]
      end
    elsif opts[:command]
      command
    end
  end

  def display_columns
    printf "%-30s %-9s %s\n", 'column', '(type)', 'description'
    120.times { print '-' }
    puts
    query('columns').select { |col| col[2] == opts[:query] }.each do |col|
      printf "%-30s %-9s %s\n", col[1], "(#{col[3]})", col[0]
    end
  end

  def command
    args = [opts[:command]] + opts[:arguments].split(',')
    cmd_string = "COMMAND [#{Time.now.to_i}] #{args.join(';')}\n" \
      "ResponseHeader: fixed16\n" \
      "OutputFormat: json\n"

    socket.write cmd_string + "\n"
    response = read
    socket.close
    puts response
  end

  def key
    key_map = {
      'downtimes' => 'id',
      'services' => 'description',
      'servicesbygroup' => 'description',
      'servicesbyhostgroup' => 'description',
      'comments' => 'service_description'
    }

    key_map[opts[:query]] || 'name'
  end

  def query(keyword)
    query_string = "GET #{keyword}\n" \
      "ResponseHeader: fixed16\n" \
      "OutputFormat: json\n"
    query_string += "Columns: #{columns.join ' '}\n" unless opts[:list]

    socket.write query_string + "\n"
    response = read
    socket.close
    return response unless opts[:columns]
    parse response
  end

  def parse(data)
    # Outputs a somewhat more useful data structure that looks like this:
    #
    # {
    #   "item1": {
    #     "column1": [
    #       "value1",
    #       "value2"
    #     ],
    #     "column2": [
    #       "value1",
    #       "value2"
    #     ]
    #   },
    #   "item2": {
    #     "column1": [
    #     ],
    #     "column2": [
    #       "value1"
    #     ]
    #   }
    # }

    data.each_with_object({}) do |item, memo|
      item_name = item.shift
      # columns[1..-1] because we assume the first value is a name or id tag
      memo[item_name] = columns[1..-1].each_with_object({}) do |col, cols_memo|
        cols_memo[col] = item.shift
      end
    end
  end

  def read
    header = socket.read 16

    response = {
      code: header[0..2].to_i,
      length: header[4..14].chomp.to_i
    }

    fail "Received error response #{response[:code]}" unless response[:code] == 200

    JSON.parse socket.read response[:length]
  end

  def socket
    return @socket unless !@socket || @socket.closed?
    @socket = TCPSocket.open opts[:host], opts[:port]
  end

  # def conf
  #   @conf ||= begin
  #     return {} unless File.exist? '/etc/livestatus-client.yaml'
  #     YAML.load_file '/etc/livestatus-client.yaml'
  #   end
  # end

  def columns
    return [key] unless opts[:columns]
    [key] + opts[:columns].split(',')
  end

  def opts
    @opts ||= begin
      opts = Trollop.options do
        version "livestatus-client #{LivestatusClient::VERSION} (c) 2017 Evertrue"
        opt :host, 'Livestatus host', short: 'h', type: String
        opt :port, 'Livestatus port', short: 'p', type: String
        opt :query, 'The query string', short: 'q', type: String
        opt :columns, 'Which columns to display (comma separated)', short: 'l', type: String
        opt :list, 'List available columns'
        opt :command, 'Command to send', short: 'c', type: String
        opt :arguments, 'Command argumenets (comma separated)', short: 'a', type: String
      end

      fail 'Either a query or a command must be specified' unless opts[:query] || opts[:command]

      opts
    end
  end
end
