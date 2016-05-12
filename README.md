fuel-plugin-kubernetes
======================

This plugin can be used to deploy a kubernetes cluster using Fuel.


Requirements for Building Plugin
--------------------------------

In order to build this plugin, you will need
[librarian-puppet-simple](https://github.com/bodepd/librarian-puppet-simple)
installed as we use that to pull down external puppet module dependencies.


Notes on preparing the environment
----------------------------------

For an environment with tunneling:
```
export ENV="2"
export CONTROLLER_NODE="6"
export POD_NODES="7,8,9"
fuel network-group --create --node-group $ENV --name kubernetes --release 1 --vlan 1000 --cidr 10.244.0.0/16; \
fuel role --rel $ENV --role controller --file test.yaml; \
vi test.yaml; \
fuel role --rel $ENV --role controller --update --file test.yaml; \
fuel plugins --install fuel-plugin-kubernetes-1.0-1.0.0-1.noarch.rpm; \
fuel settings --env $ENV --download; \
vi settings_$ENV.yaml; \
fuel settings --env $ENV --upload; \
fuel --env $ENV node set --node $CONTROLLER_NODE --role kubernetes-controller; \
fuel --env $ENV node set --node $POD_NODES --role kubernetes-pod; \
ln -s k8s_network.yaml network_template_${ENV}.yaml; \
fuel --env $ENV network-template --upload --dir ./ ; \
fuel deploy-changes --env $ENV
```


Testing did it work?
-------------------

```
kubectl run nginx --image=nginx --port=80
kubectl expose deployment nginx --port=80
# wait for nginx deployment to become ready
kubectl get deployments
# query nginx
ip=$(kubectl get svc nginx --template={{.spec.clusterIP}})
curl $ip
```
