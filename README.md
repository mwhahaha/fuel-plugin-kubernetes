fuel-plugin-kubernetes
======================

This plugin can be used to deploy a kubernetes cluster using Fuel.


Requirements for Building Plugin
--------------------------------

In order to build this plugin, you will need
[librarian-puppet-simple](https://github.com/bodepd/librarian-puppet-simple)
installed as we use that to pull down external puppet module dependencies.

Additionally, the plugin will build deb packages for etcd, flannel, kubernetes
durring the plugin build. You will need to make sure that dh-make is installed
on the host where you plan on building the plugin. If you already have the
packages and do not wish to build them, simply create a skip-debs file in the
.utils directory.

```
touch .utils/skip-debs
```


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


Calico
------

It's possible to use Calico as a network provider for k8s. In order to do so
you need to choose it on the plugin Settings page.
Calico CLI commands example:

```
. /root/calicorc
calicoctl status
calicoctl pool show
calicoctl profile show --detailed
calicoctl profile calico-k8s-network rule show
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
perl -i -0pe 's/enabled: false(\s+label: Kubernetes)/enabled: true$1/' settings_${ENV}.yaml; \
fuel settings --env $ENV --upload; \
fuel --env $ENV node set --node 1,2,3 --role kubernetes-controller; \
fuel --env $ENV node set --node 4,5 --role kubernetes-node; \
fuel deploy-changes --env $ENV
```
