require_relative 'api_client.rb'

class SlackClient
  include ApiClient

  ENDPOINT = "#{ENV.fetch('SLACK_ENDPOINT')}".freeze
  

  def initialize(gmud_hash)
    @gmud_hash = gmud_hash
  end

  def call
    return unless gmud_hash

    post_notification(
      'https://hooks.slack.com/services/',
      ENDPOINT,
      { 'text': slack_message }.to_json
    )
  end

  private

  attr_reader :gmud_hash

  def slack_message
    if gmud_hash[:changes].empty? || gmud_hash[:riskiness].empty?
      raw_template
    else
      full_template
    end
  end

  def raw_template
    <<-SLACK_MESSAGE
    
    
<#{gmud_hash[:link]}|*GMUD @ #{gmud_hash[:repository]} # #{gmud_hash[:number]}*> :verified-blue:


:check-verde: *O que mudou* 

#{gmud_hash[:raw_description]}
    SLACK_MESSAGE
  end

  def full_template
    <<-SLACK_MESSAGE
    
<#{gmud_hash[:link]}|*GMUD @ #{gmud_hash[:repository]} # #{gmud_hash[:number]}*> :verified-blue:


:check-verde: *O que mudou*
#{gmud_hash[:changes]}

:warning-sync: *Riscos* 
#{gmud_hash[:riskiness]}
    SLACK_MESSAGE
  end
end
