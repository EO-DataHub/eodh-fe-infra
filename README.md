eodh-fe-infra

Overview
This repository contains Terraform modules and configurations for the EODH project, facilitating the creation of environments and managing infrastructure using Terraform Cloud.

Directory Structure
modules/: Contains reusable Terraform modules specific to the EODH project.
tests/: Contains Terraform configurations to create DEV, QA, and STAGING environments.

Infrastructure Creation Process
Terraform Cloud is utilized for the CI/CD part of the infrastructure creation process. The connection between Terraform Cloud and AWS has been established using OIDC (OpenID Connect).

Tags and Management
All resources created through Terraform are tagged with ManagedByTerraform=YES to distinguish them from manually managed resources.

Usage
To use this repository:

Clone the repository to your local environment.
Navigate to the desired environment configuration under tests/.
Adjust variables and configurations as needed for your specific environment.
Deploy using Terraform commands integrated with Terraform Cloud.

Contributing
Contributions to this repository are welcome. If you find any issues or errors, please contact the repository owner for assistance or submit a pull request to propose changes.
If you have suggestions for improvements or new features, feel free to open an issue to discuss them.
