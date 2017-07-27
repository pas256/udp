require 'bridge-gre'

class MulticastCommunity
   attr_accessor :community, :ip, :members, :bridge, :bridge_peers

   def initialize(community, ip)
      @community = community
      @ip = ip
      @members = {}
      @bridge_peers = {}
   end

   def self.tag_parse(tags)
      tags.select { |t| t[0] == "multicast" }.map { |t|
         (comm_name, ip) = t[1].split(',')
         MulticastCommunity.new(comm_name, ip)
      }
   end

   def self.this_instance_community(ec2)
      MulticastCommunity.tag_parse(ec2.instances[ThisInstance.instance_id].tags)
   end

   def sync_membership(instances)
      current = @members.keys
      new = instances.keys
      to_add = new - current
      to_remove = current - new
      Syslog.log(Syslog::LOG_NOTICE, "I have #{to_add.size} instances to add and #{to_remove.size} instances to remove")
      to_add.each { |iid|
         bridge_add(instances[iid])
      }
      to_remove.each { |iid|
         bridge_remove(@members[iid])
      }
      @members = instances
   end

   def bridge_name
      "mcbr-#{community}"
   end

   def bridge_create
      @bridge = GreBridge.new(bridge_name, @ip)
      Syslog.log(Syslog::LOG_NOTICE, "Creating bridge #{bridge_name} with IP #{@ip}")
   end

   def bridge_delete
      @bridge.destroy
      @bridge = nil
   end

   def bridge_add(instance)
      bp = GreBridgePeer.new(instance.private_ip_address)
      bp.connect(@bridge)
      @bridge_peers[instance.id] = bp
   end

   def bridge_remove(instance)
      @bridge_peers[instance.id].disconnect(@bridge)
      @bridge_peers[instance.id].destroy
      @bridge_peers.delete(instance.id)
   end
end
