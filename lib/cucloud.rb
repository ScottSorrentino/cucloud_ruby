require 'aws-sdk'

module Cucloud
  require 'cucloud/version'
  require 'cucloud/ec2_utils'

  DEFAULT_REGION = 'us-east-1'

  Aws.config = {region: DEFAULT_REGION}

  def region
    @region
  end
  
  def region=(region)
    @region = region
    Aws.config = {region: @region}
  end

  module_function :region, :region=
end