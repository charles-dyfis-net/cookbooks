# stop yum-updatesd before anything else
s = service "yum-updatesd" do
  action :nothing
end
s.run_action(:stop)
s.run_action(:disable)
