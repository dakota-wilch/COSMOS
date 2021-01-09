# encoding: ascii-8bit

# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder

require 'spec_helper'
require 'tempfile'
require 'cosmos'
require 'cosmos/tools/cmd_tlm_server/commanding'
require 'cosmos/tools/cmd_tlm_server/cmd_tlm_server_config'

module Cosmos

  describe Commanding do
    before(:all) do
      system_path = File.join(__dir__, '..', '..', 'install', 'config', 'system', 'system.txt')
      @sc = Cosmos::SystemConfig.new(system_path)
    end

    describe "send_command_to_target" do
      it "complains about unknown targets" do
        tf = Tempfile.new('unittest')
        tf.close
        cmd = Commanding.new(CmdTlmServerConfig.new(tf.path, @sc))
        expect { cmd.send_command_to_target('BLAH', Packet.new('TGT','PKT')) }.to raise_error("Unknown target: BLAH")
        tf.unlink
      end

      it "identifies and command to the interface" do
        tf = Tempfile.new('unittest')
        tf.puts 'INTERFACE MY_INT interface.rb'
        tf.close
        config = CmdTlmServerConfig.new(tf.path, @sc)
        cmd = Commanding.new(config)
        interfaces = Interfaces.new(config)
        interfaces.map_target("SYSTEM","MY_INT")
        expect(interfaces.all["MY_INT"]).to receive(:write)
        expect(interfaces.all["MY_INT"].packet_log_writer_pairs[0].cmd_log_writer).to receive(:write)

        # Grab an existing packet
        pkt = System.commands.packet('SYSTEM','STARTLOGGING')
        # Restore defaults so it can be identified
        pkt.restore_defaults
        # Set the target_name to nil to make it "unidentified"
        pkt.target_name = nil

        count = System.targets['SYSTEM'].cmd_cnt
        cmd.send_command_to_target('SYSTEM', pkt)
        # Verify the SYSTEM STARTLOGGING packet has been updated
        expect(System.commands.packet("SYSTEM","STARTLOGGING").buffer).to eql pkt.buffer
        # Verify the target count didn't get updated
        expect(System.targets['SYSTEM'].cmd_cnt).to eq count
        # Restore target name
        pkt.target_name = 'SYSTEM'
        tf.unlink
      end

      it "sends already identified commands" do
        tf = Tempfile.new('unittest')
        tf.puts 'INTERFACE MY_INT interface.rb'
        tf.close
        config = CmdTlmServerConfig.new(tf.path, @sc)
        cmd = Commanding.new(config)
        interfaces = Interfaces.new(config)
        interfaces.map_target("SYSTEM","MY_INT")
        expect(interfaces.all["MY_INT"]).to receive(:write)
        expect(interfaces.all["MY_INT"].packet_log_writer_pairs[0].cmd_log_writer).to receive(:write)

        # Grab an existing packet
        pkt = System.commands.packet('SYSTEM','STARTLOGGING').clone

        count = System.targets['SYSTEM'].cmd_cnt
        cmd.send_command_to_target('SYSTEM', pkt)
        # Verify the SYSTEM STARTLOGGING packet has been updated
        expect(System.commands.packet("SYSTEM","STARTLOGGING").buffer).to eql pkt.buffer
        expect(System.targets['SYSTEM'].cmd_cnt).to eq count + 1
        tf.unlink
      end

      it "sends already identified stored commands" do
        tf = Tempfile.new('unittest')
        tf.puts 'PACKET_LOG_WRITER MY_WRITER packet_log_writer.rb'
        tf.puts 'INTERFACE MY_INT interface.rb'
        tf.puts '  LOG_STORED MY_WRITER'
        tf.close
        config = CmdTlmServerConfig.new(tf.path, @sc)
        cmd = Commanding.new(config)
        interfaces = Interfaces.new(config)
        interfaces.map_target("SYSTEM","MY_INT")
        expect(interfaces.all["MY_INT"]).to receive(:write)
        expect(interfaces.all["MY_INT"].stored_packet_log_writer_pairs[0].cmd_log_writer).to receive(:write)

        # Grab an existing packet
        pkt = System.commands.packet('SYSTEM','STARTLOGGING').clone
        pkt.stored = true

        count = System.targets['SYSTEM'].cmd_cnt
        cmd.send_command_to_target('SYSTEM', pkt)
        # Verify the SYSTEM STARTLOGGING packet has been updated
        expect(System.commands.packet("SYSTEM","STARTLOGGING").buffer).to eql pkt.buffer
        expect(System.targets['SYSTEM'].cmd_cnt).to eq count + 1
        tf.unlink
      end

      it "logs unknown commands" do
        Logger.level = Logger::DEBUG
        stdout = StringIO.new('', 'r+')
        $stdout = stdout

        tf = Tempfile.new('unittest')
        tf.puts 'INTERFACE MY_INT interface.rb'
        tf.close
        config = CmdTlmServerConfig.new(tf.path, @sc)
        cmd = Commanding.new(config)
        interfaces = Interfaces.new(config)
        interfaces.map_target("SYSTEM","MY_INT")
        expect(interfaces.all["MY_INT"]).to receive(:write)
        expect(interfaces.all["MY_INT"].packet_log_writer_pairs[0].cmd_log_writer).to receive(:write)

        # Grab an existing packet
        pkt = System.commands.packet('SYSTEM','STARTLOGGING')
        # Mess up the opcode so it won't be identifyable
        pkt.write('OPCODE',100)
        # Set the target_name to nil to make it "unidentified"
        pkt.target_name = nil

        cmd.send_command_to_target('SYSTEM', pkt)
        # Verify the unknown packet has been updated
        expect(System.commands.packet("UNKNOWN","UNKNOWN").buffer).to eql pkt.buffer
        tf.unlink

        expect(stdout.string).to match("Unidentified packet")
        Logger.level = Logger::FATAL
        $stdout = STDOUT
      end
    end

    describe "send_raw" do
      it "complains about unknown interfaces" do
        tf = Tempfile.new('unittest')
        tf.close
        cmd = Commanding.new(CmdTlmServerConfig.new(tf.path, @sc))
        expect { cmd.send_raw('BLAH', Packet.new('TGT','PKT')) }.to raise_error("Unknown interface: BLAH")
        tf.unlink
      end

      it "logs writes" do
        Logger.level = Logger::DEBUG
        stdout = StringIO.new('', 'r+')
        $stdout = stdout

        tf = Tempfile.new('unittest')
        tf.puts 'INTERFACE MY_INT interface.rb'
        tf.close
        config = CmdTlmServerConfig.new(tf.path, @sc)
        cmd = Commanding.new(config)
        interfaces = Interfaces.new(config)
        expect(interfaces.all["MY_INT"]).to receive(:write_raw)

        cmd.send_raw('MY_INT', "\x00\x01")
        tf.unlink

        expect(stdout.string).to match("Unlogged raw data of 2 bytes being sent to interface MY_INT")
        Logger.level = Logger::FATAL
        $stdout = STDOUT
      end
    end

  end
end
