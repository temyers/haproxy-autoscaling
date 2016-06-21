require 'spec_helper'

describe "haproxy-autoscaling" do

  haproxy_dir="target/haproxy"
  haproxy_autoscale_dir="#{haproxy_dir}/autoscale"
  haproxy_cfg_file="#{haproxy_dir}/haproxy.cfg"
  examples_dir="spec/localhost/examples"


  before :context do
    if(!Dir.exists? "#{haproxy_autoscale_dir}")
      FileUtils.mkdir_p("#{haproxy_autoscale_dir}")
    end
  end

  before :example do
    `cp -r #{examples_dir}/* #{haproxy_dir}`
    `cp -r files/etc/haproxy/autoscale #{haproxy_dir}/`
  end


  describe "scaleup.sh" do

    describe file("#{haproxy_autoscale_dir}/scaleup.sh") do
      it { should exist }
      it { should be_executable }
    end

    describe command("#{haproxy_autoscale_dir}/scaleup.sh i-12345 127.0.0.1") do
      its(:stdout){ should match /#{Regexp.escape("Successfully added server i-12345 127.0.0.1")}/ }
      its(:stdout){ should match /Successfully restarted HAProxy/ }
      # Useful for debugging test failures
      # its(:stderr){ should eq "" }

      it "should add the server to haproxy config file" do
        # Have to re-run the command, since the command is evaluated before the context is set up
        # http://www.rubydoc.info/gems/rspec-core/frames#Basic_Structure
        `#{haproxy_autoscale_dir}/scaleup.sh i-12345 127.0.0.1 2> /dev/null`

        haproxy_cfg_contents = File.open(haproxy_cfg_file) { |file| file.read }
        # puts haproxy_cfg_contents
        expect(haproxy_cfg_contents).to match /#{Regexp.escape("server i-12345 127.0.0.1:80 cookie i-12345 check")}/
      end

      it "should only add a server once" do
        `#{haproxy_autoscale_dir}/scaleup.sh i-12345 127.0.0.1 2> /dev/null`
        `#{haproxy_autoscale_dir}/scaleup.sh i-12345 127.0.0.1 2> /dev/null`

        expect(`grep i-12345 #{haproxy_cfg_file} | wc -l`).to match /^1$/
      end

    end


  end

  describe "scaledown.sh" do

    describe command("#{haproxy_autoscale_dir}/scaledown.sh i-11111") do
      its(:stdout){ should match /#{Regexp.escape("Successfully removed server i-11111")}/ }
      its(:stdout){ should match /Successfully restarted HAProxy/ }

      it "should remove the server from haproxy config file" do
        # Have to re-run the command, since the command is evaluated before the context is set up
        # http://www.rubydoc.info/gems/rspec-core/frames#Basic_Structure
        `#{haproxy_autoscale_dir}/scaledown.sh i-11111 2> /dev/null`

        expect(`grep i-11111 #{haproxy_cfg_file}`).to eq ""
      end
    end


  end

end