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

NOTE: You *must* correctly setup the kubernetes network group using the network
template or it will use the *management* network for the service addresses (and
br-mgmt) which may lead to other environment issues. See the k8s_network.yaml
for an example network template.

To disable the controller requirement within a fuel environment:
```
export RELEASE=2
fuel role --rel $RELEASE --role controller --file controller.yaml
sed -i 's/min: 1/min: 0/' controller.yaml
fuel role --rel $RELEASE --role controller --update --file controller.yaml
```

Upload network template
```
export ENV=2
ln -s k8s_network.yaml network_template_${ENV}.yaml
fuel --env $ENV network-template --upload --dir ./
```


Testing did it work?
--------------------

```
kubectl run nginx --image=nginx --port=80
kubectl expose deployment nginx --port=80
# wait for nginx deployment to become ready
kubectl get deployments
# query nginx
ip=$(kubectl get svc nginx --template={{.spec.clusterIP}})
curl $ip
```


Misc notes
----------

```
export ENV=1 ; \
export RELEASE=2 ; \
fuel role --rel $RELEASE --role controller --file controller.yaml; \
sed -i 's/min: 1/min: 0/' controller.yaml; \
fuel role --rel $RELEASE --role controller --update --file controller.yaml; \
fuel network-group --create --node-group 1 --name kubernetes --release $RELEASE --vlan 800 --cidr 10.244.0.0/16; \
ln -s k8s_network.yaml network_template_${ENV}.yaml; \
fuel --env $ENV network-template --upload --dir ./; \
fuel plugins --install fuel-plugin-kubernetes-1.0-1.0.0-1.noarch.rpm; \
fuel settings --env $ENV --download; \
vi settings_${ENV}.yaml; \
fuel settings --env $ENV --upload; \
fuel --env $ENV node set --node 1,2,3 --role kubernetes-controller; \
fuel --env $ENV node set --node 4,5 --role kubernetes-node; \
fuel deploy-changes --env $ENV
```
