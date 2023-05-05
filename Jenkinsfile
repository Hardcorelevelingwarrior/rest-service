podTemplate(yaml: '''
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: maven
        image: maven:3.8.5-openjdk-17
        command:
        - sleep
        args:
        - 99d
        volumeMounts:
        - mountPath: "/etc/ssl"
          name: "ssl"
      volumes:
      - name: ssl
        secret:
          secretName: job-certs

      restartPolicy: Never

''') {
  node(POD_LABEL) {
    stage('Get the project') {
      git url: 'https://github.com/Hardcorelevelingwarrior/rest-service.git', branch: 'master'
      
      container('maven') {
        stage('Build and test the project') {
          sh '''
          mvn -B -DskipTests clean package
          mvn test
          ''' }
        stage('Publish test result'){
          junit 'target/surefire-reports/*.xml'}
            stage('Dependency check and publish result'){
            sh 'mvn dependency-check:check'
            dependencyCheckPublisher pattern: ''}
        stage('SAST test and publish result'){
            sh 'mvn pmd:pmd pmd:cpd spotbugs:spotbugs'
            recordIssues enabledForFailure: true, tool: spotBugs()
            recordIssues enabledForFailure: true, tool: cpd(pattern: '**/target/cpd.xml')
            recordIssues enabledForFailure: true, tool: pmdParser(pattern: '**/target/pmd.xml')
          }

        }  
        
        }
      
      
     
    stage("Image to container"){
        container('maven'){

            stage('Create and push container') {
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {                  
                        sh "mvn jib:build"
                }
            }
        }
    }
     stage('Anchore analyse') {  
     writeFile file: 'anchore_images', text: 'docker.io/conmeobeou1253/mavendemo'  
     anchore bailOnFail: false, bailOnPluginFail: false, name: 'anchore_images' 
     
     }    
    
        stage('Deploy to K8s') {
          container('maven'){
        withKubeConfig([credentialsId:'kubernetes-config']) {
          httpRequest ignoreSslErrors: true, outputFile: './kubectl', responseHandle: 'NONE', url: 'https://storage.googleapis.com/kubernetes-release/release/v1.25.3/bin/linux/amd64/kubectl', wrapAsMultipart: false
          sh 'chmod u+x ./kubectl'
          sh './kubectl apply -f k8s.yaml'
        
      } 
    }
        }
    
  }
}
  
  
  

