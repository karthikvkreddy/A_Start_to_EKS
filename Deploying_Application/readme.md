# Deploying Application on kubenetes

Let deploy simple ngnxi server on kubernetes
### step 1:creating a yaml file for application Deployment 
   Lets us undestand Deployment.yaml file
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev_app_name
spec:
  selector:
    matchLabels:
      run: dev_app_name
  replicas: 2
  template:
    metadata:
      labels:
        name: dev_app_name
    spec:
      containers:
      - name: dev_app_name
        image: <IMAGE-URL>
        ports:
        - containerPort: 80

```
In the above file contains **Kind: Deployment** . 

**replicas: 2**  This means at any point of time thier are 2 pods running. we can scale up by specifying more replicas.

under **spec**, we need to give details of docker images, where container will run on kubernetes along with port number specified.


### step 2:creating a yaml file for application Servive 
```
apiVersion: v1
kind: Service
metadata:
  name:  sev_app_name
spec:
  selector:
    app: dev_app_name
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 80
```
In the above file contains **Kind: Service** .This allow us to interact with the application from browser. 

under **spec**, specifying **type: LoadBalancer** allows kubenetes to assign loadbalancer to our application, where it 
generates DNS address.

ports are set to 80 where it is listening to the container application. 


### step 3:applying both deployment and service application onto kubenetes
    $kubectl apply -f ./Deployment.yaml
    $kubectl apply -f ./service.yaml
    
### step 4:list all the pods running
    $kubectl get pods
    
