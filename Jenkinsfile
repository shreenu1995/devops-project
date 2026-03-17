pipeline {
    agent any

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
        K8S_DIR = "k8s"
    }

    stages {

        // Stage 1
        stage('Git Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/shreenu1995/devops-project.git'
            }
        }

        // Stage 2
        stage('Terraform Init & Apply') {
            steps {
                sh '''
                cd $TF_DIR
                terraform init
                terraform apply -auto-approve
                terraform output -json > ../ips.json
                '''
            }
        }

        // Stage 3
        stage('Setup Ansible Inventory') {
            steps {
                sh '''
                cd $ANSIBLE_DIR
                echo "[k8s-master]" > inventory
                jq -r '.public_ips.value[0]' ../ips.json >> inventory

                echo "[k8s-workers]" >> inventory
                jq -r '.public_ips.value[1]' ../ips.json >> inventory
                jq -r '.public_ips.value[2]' ../ips.json >> inventory
                '''
            }
        }

        // Stage 4
        stage('Deploy Kubernetes Cluster') {
            steps {
                sh '''
                cd $ANSIBLE_DIR
                ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook install-k8s.yml
                '''
            }
        }

        // Stage 5
        stage('Test Cluster') {
            steps {
                sh '''
                cd ansible
                ansible k8s_master -a "kubectl get nodes" -b
                '''
            }
        }

        // Stage 6
        stage('Deploy Application') {
            steps {
                sh '''
                cd ansible

        	# Copy YAML files to master node
        	ansible k8s_master -m copy -a "src=../k8s/redis.yml dest=/home/ubuntu/redis.yml"
     		ansible k8s_master -m copy -a "src=../k8s/python.yml dest=/home/ubuntu/python.yml"

        	# Deploy on Kubernetes master
        	ansible k8s_master -a "kubectl apply -f /home/ubuntu/redis.yml" -b
        	ansible k8s_master -a "kubectl apply -f /home/ubuntu/python.yml" -b   
                '''
            }
        }

        // Stage 7
        stage('Manual Approval') {
            steps {
                input "Approve to continue?"
            }
        }

        // Stage 8
        stage('Store Outputs') {
            steps {
                sh 'cp ips.json output.txt'
                archiveArtifacts artifacts: 'output.txt'
            }
        }

        // Stage 9
        stage('Destroy Infra') {
            steps {
                sh '''
                cd terraform
                terraform destroy -auto-approve
                '''
            }
        }
    }
}
