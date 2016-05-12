fuel-plugin-kubernetes
============

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
fuel deploy-changes --env $ENV
```
