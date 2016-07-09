require 'spec_helper'

describe Cucloud::AsgUtils do
  let(:asg_client) do
    Aws::AutoScaling::Client.new(stub_responses: true)
  end

  let(:asg_util) do
    Cucloud::AsgUtils.new asg_client
  end

  it '.new default optional should be successful' do
    expect(Cucloud::AsgUtils.new).to be_a_kind_of(Cucloud::AsgUtils)
  end

  it 'dependency injection asg_client should be successful' do
    expect(Cucloud::AsgUtils.new(asg_client)).to be_a_kind_of(Cucloud::AsgUtils)
  end

  context 'while asg is stubbed out with matching search result' do
    before do
      asg_client.stub_responses(
        :describe_auto_scaling_groups,
        next_token: nil,
        auto_scaling_groups: [{
          auto_scaling_group_name: 'test-group',
          auto_scaling_group_arn: 'arn:test-group',
          launch_configuration_name: 'test-launch-config',
          min_size: 0,
          max_size: 10,
          desired_capacity: 5,
          default_cooldown: 300,
          availability_zones: ['us-east-1a'],
          health_check_type: 'test',
          created_time: Time.new(2016, 7, 9, 13, 30, 0)
        }]
      )
    end

    it "'get_asg_by_name' should return without an error" do
      expect { asg_util.get_asg_by_name('test-group') }.not_to raise_error
    end

    it "'get_asg_by_name' should return first result" do
      expect(asg_util.get_asg_by_name('test-group').auto_scaling_group_name.to_s).to eq 'test-group'
    end

    it "'get_asg_by_name' should return type Aws::AutoScaling::Types::AutoScalingGroup" do
      expect(asg_util.get_asg_by_name('test-group').class.to_s).to eq 'Aws::AutoScaling::Types::AutoScalingGroup'
    end
  end

  context 'while asg is stubbed out with no search result (not found)' do
    before do
      asg_client.stub_responses(
        :describe_auto_scaling_groups,
        next_token: nil,
        auto_scaling_groups: []
      )
    end

    it "'get_asg_by_name' should return without an error" do
      expect { asg_util.get_asg_by_name('test-group') }.not_to raise_error
    end

    it "'get_asg_by_name' should return nil" do
      expect(asg_util.get_asg_by_name('test-group').nil?).to eq true
    end
  end

  context 'while launch configuration is stubbed out with matching search result' do
    before do
      asg_client.stub_responses(
        :describe_launch_configurations,
        next_token: nil,
        launch_configurations: [{
          launch_configuration_name: 'test-lc',
          launch_configuration_arn: 'arn:test-lc',
          image_id: 'i-testami',
          key_name: 'test-key',
          security_groups: ['test-sg-1', 'test-sg-2'],
          classic_link_vpc_id: 'vpc-id',
          classic_link_vpc_security_groups: ['classic-link-sg-1', 'classic-link-sg-2'],
          user_data: 'blob of user data text',
          instance_type: 't2.micro',
          kernel_id: 'test-kernel-id',
          ramdisk_id: 'test-ramdisk-id',
          block_device_mappings: [
            {
              virtual_name: 'block-device-vn-1',
              device_name: 'device-name-1',
              ebs: {
                snapshot_id: 'ebs-snapshot-1',
                volume_size: 1000,
                volume_type: 'ebs-volume-type',
                delete_on_termination: true,
                iops: 1000,
                encrypted: true
              },
              no_device: false
            }
          ],
          instance_monitoring: { enabled: true },
          spot_price: 'spot price',
          iam_instance_profile: 'iam profile',
          created_time: Time.new(2016, 7, 9, 13, 30, 0),
          ebs_optimized: true,
          associate_public_ip_address: false,
          placement_tenancy: 'placement tenancy'
        }]
      )
    end

    it "'get_launch_config_by_name' should return without an error" do
      expect { asg_util.get_launch_config_by_name('test-lc') }.not_to raise_error
    end

    it "'get_launch_config_by_name' should return first result" do
      expect(asg_util.get_launch_config_by_name('test-lc').launch_configuration_name.to_s).to eq 'test-lc'
    end

    it "'get_launch_config_by_name' should return type Aws::AutoScaling::Types::LaunchConfiguration" do
      expect(asg_util.get_launch_config_by_name('test-lc').class.to_s)
        .to eq 'Aws::AutoScaling::Types::LaunchConfiguration'
    end
  end

  context 'while launch configuration is stubbed without matching result' do
    before do
      asg_client.stub_responses(
        :describe_launch_configurations,
        next_token: nil,
        launch_configurations: []
      )
    end

    it "'get_launch_config_by_name' should return without an error" do
      expect { asg_util.get_launch_config_by_name('test-lc') }.not_to raise_error
    end

    it "'get_launch_config_by_name' should return nil" do
      expect(asg_util.get_launch_config_by_name('test-lc').nil?).to eq true
    end
  end
end
