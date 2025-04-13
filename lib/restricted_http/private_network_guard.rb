require "resolv"

module RestrictedHTTP
  class Violation < StandardError; end

  module PrivateNetworkGuard
    extend self

    LOCAL_IP = IPAddr.new("0.0.0.0/8") # "This" network

    def resolve(hostname)
      Resolv.getaddress(hostname).tap do |ip|
        raise Violation.new("Attempt to access private IP via #{hostname}") if ip && private_ip?(ip)
      end
    end

    def private_ip?(ip)
      IPAddr.new(ip).then do |ipaddr|
        ipaddr.private? || ipaddr.loopback? || LOCAL_IP.include?(ipaddr)
      end
    rescue IPAddr::InvalidAddressError
      true
    end
  end
end
