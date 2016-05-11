require 'facter'

flannel_path = '/run/flannel/subnet.env'

# defaults
flannel = {
    :FLANNEL_NETWORK => '172.16.0.0/16',
    :FLANNEL_SUBNET  => '172.16.1.1/24',
    :FLANNEL_MTU     => '1472',
    :FLANNEL_IPMASQ  => 'true'
}

if File.exists?(flannel_path)
  open(flannel_path).each do |l|
    key,val = l.chomp.split('=')
    flannel[key.to_sym] = val
  end
end

flannel.each do |key, val|
  Facter.add(key.to_s.downcase) do
    setcode { val }
  end
end
