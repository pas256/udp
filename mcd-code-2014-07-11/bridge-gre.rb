class GreBridge
   attr_accessor :name, :ip

   def initialize(name, ip)
      @name = name
      @ip = ip
      create_bridge
   end

   def create_bridge
      `brctl addbr #{name}`
      `ebtables -P FORWARD DROP`
      `ip addr add #{ip} dev #{name}`
      `ip link set #{name} up`
   end

   def destroy
      `ip link set #{name} down`
      `brctl delbr #{name}`
   end

   def status
      res = `ip link show #{name}`
      (res =~ /state UP/ ? 'up' : 'down')
   end
end

class GreBridgePeer
   attr_accessor :remote_ip, :interface

   def initialize(remote_ip)
      @remote_ip = remote_ip
      @interface = "gretap#{@remote_ip.gsub(/\./, '-').gsub(/^\d+\-\d+/, '')}"
      create
   end

   def local_ip() ThisInstance.main_private_ip end

   def create
      Syslog.log(Syslog::LOG_NOTICE, "Creating #{interface} local #{local_ip} remote #{remote_ip}")
      `ip link add #{interface} type gretap local #{local_ip} remote #{remote_ip}`
      `ip link set dev #{interface} up`
   end

   def destroy
      Syslog.log(Syslog::LOG_NOTICE, "Destroying #{interface}, peer #{remote_ip}")
      `ip link delete #{interface}`
   end

   def connect(bridge)
      Syslog.log(Syslog::LOG_NOTICE, "Connecting #{interface} to #{bridge.name}")
      `brctl addif #{bridge.name} #{interface}`
   end

   def disconnect(bridge)
      Syslog.log(Syslog::LOG_NOTICE, "Discnnecting #{interface} from #{bridge.name}")
      `brctl delif #{bridge.name} #{interface}`
   end
end
