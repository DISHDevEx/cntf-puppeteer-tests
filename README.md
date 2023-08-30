# CNTF - Pupeteer Tests

## Purpose
This source code repository stores the configurations to peform normal user activities (e.g. watching a YouTube video) via a UE connected to the 5G network.

## Project structure
```
├── open5gs
|   ├── infrastructure                 contains infrastructure-as-code and helm configurations for open5gs & ueransim
|      	├── eks
|           └── fluentd-override.yaml  configures fluentd daemonset within the cluster
|           └── otel-override.yaml     configures opentelemtry daemonset within the cluster
|           └── provider.tf
|           └── main.tf                    
|           └── variables.tf                
|           └── outputs.tf 
|           └── versions.tf
|
└── .gitlab-ci.yml                     contains configurations to run CI/CD pipeline
|
|
└── README.md  
|
|
└── open5gs_values.yml                 these values files contain configurations to customize resources defined in the open5gs & ueransim helm charts
└── openverso_ueransim_gnb_values.yml                 
└── openverso_ueransim_ues_values.yml 
|
|
└── youtube-network-requests.txt       stores general data for youtube video running over 5g network locally
└── youtube-pupeteer-load-time.txt     stores download time for youtube video running over 5g network locally
└── youtube-pupeteer-screenshot.png    stores screenshot of youtube video running over 5g network locally
|
|
└── s3_test_results_coralogix.py       converts local files into s3 objects 
|  
|
└── update_test_results.sh             updates test result data from custom pupeteer youtube search pod both locally and in aws                                           
```

