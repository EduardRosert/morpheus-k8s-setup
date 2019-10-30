# morpheus-k8s-setup
Set up a Kubernetes Cluster on Morpheus with CentOS 7.5

## set up controller

1. In Morpheus UI in ``Provisioning > Automation > Tasks`` add a new Task of type ``Remote Shell Script``called ``Install Kubernetes`` with the following content:
```bash
#!/bin/bash

git clone https://github.com/EduardRosert/morpheus-k8s-setup.git
cd morpheus-k8s-setup
make
```

2. In Morpheus UI in ``Provisioning > Automation > Workflows`` add a new Workflow with the name ``Install Kubernetes Controller``:
    - Platform: Linux
    - Post Provision Tasks:
        1. Install Kubernetes

3. Make sure you have python3 and pip installed, then install pymorpheus package:
```bash
pip install pymorpheus==0.1.5
```

4. Create the Kubernetes controller:
```bash
python create.py
```