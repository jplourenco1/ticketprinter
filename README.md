# TicketPrinter
Ruby script to generate JIRA tickets based on a template

## Installation
It is a standalone script so you just need to install the dependencies with `bundle install`

```bash
johnny@johnny:~/python/ticketprinter$ bundle install
Fetching gem metadata from https://rubygems.org/..
Resolving dependencies...
Using bundler 2.1.4
Installing cgi 0.3.1
Fetching erb 2.2.3
Installing erb 2.2.3
Fetching json 2.6.1
Installing json 2.6.1 with native extensions
Fetching optimist 3.0.1
Installing optimist 3.0.1
Fetching yaml 0.2.0
Installing yaml 0.2.0
Bundle complete! 4 Gemfile dependencies, 6 gems now installed.
Use ``bundle info [gemname]`` to see where a bundled gem is installed.
```

## Usage
The script will generate as much tickets as `cases` contained on the cases.yml file. To each case, it will set the command list taken from the `commands` list. The template should be written according to your needs, having the `%use_case%` token replaced by the current case and the `%commands%` token replaced by the list of commands set. 

```bash
johnny@johnny:~/python/ticketprinter$ ruby ticketprinter.rb --dry-run | json_pp
{
   "fields" : {
      "components" : [
         {
            "name" : "openvpn"
         }
      ],
      "description" : "*DESCRIPTION*\n This test case aims to check if a possible regression was introduced on case1 option of Openvpn module by the tested branch\n\n*PRE-REQUIREMENTS*\n OpenVPN server and client\n\n*STEPS*\n # Set proper data on client YAML (server name and IP)\n ## No client configuration options should be set\n # Set case1 option on server hash property (CCD exclusive: true)\n # Execute the following commands: cmd1\\ncmd2\\ncmd3\n # Considering success on the previous step, execute puppet on agent\n\n*EXPECTED RESULTS*",
      "issuetype" : {
         "name" : "Test"
      },
      "labels" : [
         "DEVOPS"
      ],
      "project" : {
         "key" : "DEV"
      },
      "summary" : "This is the title of case1 case."
   }
}

```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)