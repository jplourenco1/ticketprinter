#!/usr/bin/env ruby

require 'yaml'
require 'optimist'
require 'erb'
require 'net/http'
require 'json'

def show_yml_example_and_exit
  puts <<eot
eot
  exit
  
end

def show_template_example_and_exit
  puts File.read(template_path)
  exit
end

def template_path
  File.join(File.dirname(__FILE__), 'ticket_template')
end


def read_yml(opts)
  if opts[:stdin]
    data = StringIO.new
    data << STDIN.read until STDIN.eof?
    yaml = data.string
  else
    yaml = File.read(opts[:yml])
  end
  YAML.safe_load(yaml).inject(opts) do |memo, item|
    memo[item[0].to_sym] = item[1]
    memo
  end
  fail('Items not in the right format, something is missing.') unless opts[:cases].is_a?(Array)

  opts
rescue Errno::ENOENT
  raise "YML file #{opts[:yml]} not found or can't be read."
end

def read_params
  Optimist.options do
    opt :user,                   'User to access JIRA.', :type => :string
    opt :password,               'Password to access JIRA.', :type => :string
    opt :hostname,               'Hostname of the JIRA server.', :type => :string
    opt 'dry-run',               'Only show the JSON data to be submitted to JIRA'
    opt 'show-yml-example',      'Show an example of a YML file that can be used by this script.'
    opt 'show-template-example', 'Show an example of a ticket template.'
    opt :stdin,                  'Read YML file from STDIN.'
    opt :yml,                    'YML file with values for parameters not given into command line.', :default => 'cases.yml'
  end
end

$json_template = { 
                  "fields" => {
                    "project"     => {"key" => "DEV"},
                    "summary"     => "",
                    "description" => "",
                    "issuetype"   => {"name" => "Test"},
                    "components"  => [{"name" => "openvpn"}],
                    "labels"      => ["DEVOPS"]
                  }
                }

def get_template
  File.read(template_path)
end

def generate_description(use_case, commands)
  description = get_template.gsub("%use_case%", use_case.to_s).gsub("%commands%", commands.join('\n'))
end

def generate_tickets(opts, json_template)
  tickets = opts[:cases].inject('') do |ticket, use_case|
    description = generate_description(use_case, opts[:commands])
    title       = opts[:title].gsub("%use_case%", use_case.to_s)
    json_template["fields"]["description"] = description
    json_template["fields"]["summary"] = title
    raw_ticket = json_template.to_json
    ticket + raw_ticket
  end
end

def dry_run(tickets)
  puts tickets
  exit
end

def send_tickets(opts, tickets)
  uri = URI("https://#{opts[:hostname]}/rest/api/2")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  req.basic_auth opts[:user],  opts[:password]
  req.body = tickets
  res = http.request(req)
  puts "response #{res.body}"
rescue => e
  puts "failed #{e}"
end

def main
  opts = read_params
  show_yml_example_and_exit if opts['show-yml-example_given']
  show_template_example_and_exit if opts['show-template-example_given']

  read_yml(opts)
  tickets = generate_tickets(opts, $json_template)
  dry_run(tickets) if opts['dry-run']
  send_tickets(opts, tickets) 
  
rescue Errno::ENOENT => e
  abort e.message
rescue RuntimeError => e
  abort e.message
end

main if $PROGRAM_NAME == __FILE__