# # VPC Module
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr              = "10.1.0.0/16"
  ResourcePrefix        = "Dev"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  instance_tenancy      = "default"
  public_subnet_cidr    = ["10.1.1.0/24", "10.1.2.0/24"] 
  private_subnet_cidr   = ["10.1.3.0/24", "10.1.4.0/24"] 
  availability_zones    = ["us-east-1a", "us-east-1b"]
  public_ip_on_launch   = true
  PublicRT_cidr         = "0.0.0.0/0"
  PrivateRT_cidr        = "0.0.0.0/0"
  eip_associate_with_private_ip = false
}


# Security Groups Module
module "security_group" {
  source      = "../modules/security"
  vpc_id      = module.vpc.vpc_id
  ResourcePrefix = "Dev"
  public_sg_description = "Security group for public instances"

  public_sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH from anywhere"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from anywhere"
    },
    
  ]

  public_sg_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all egress"
    }
  ]

  private_sg_description = "Security group for private instances"
  private_sg_ingress_rules = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_ids = [module.security_group.public_sg_id]
      description              = "SSH from public SG"
    }
  ]

  private_sg_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]
  
  
}


# Existing Iam Instance profile
data "aws_iam_instance_profile" "admin" {
  name = "your-admin-instance-profile-name"  # Replace with your actual instance profile name
}


# # EC2 Module
module "ec2" {
  source = "../modules/ec2"

  ResourcePrefix             = "Dev"
  ami_ids                    = ["ami-068c0051b15cdb816", "ami-02a53b0d62d37a757", "ami-02e3d076cbd5c28fa", "ami-0dfc569a8686b9320", "ami-04b4f1a9cf54c11d0"]
  ami_names                  = ["AL2023", "AL2", "Windows", "RedHat", "ubuntu"]
  instance_types             = ["t2.micro", "t2.micro", "t2.micro", "t3.large", "t2.micro"]
  key_name                   = "your-key-pair-name"  # Replace with your actual key pair name
  volume_size                = 8
  volume_type                = "gp3"

  # Pass the instance profile name from data source
  admin_profile_name         = data.aws_iam_instance_profile.admin.name

  public_instance_count      = [1, 0, 0, 0, 0]
  private_instance_count     = [0, 0, 0, 0, 0]

  # Userdata
  private_user_data = file("${path.module}/../scripts/private_userdata.sh") # Update the user_data script as needed
  public_user_data = file("${path.module}/../scripts/public_userdata.sh") # Update the user_data script as needed

   
  # Tags 
  tag_value_public_instances = [
    [
      {
        role        = "users"
        Environment = "Dev"
      },
    ],
    [], [], [], []
  ]

  tag_value_private_instances = [
    [],
    [
      {
        Name = "db1"
        Tier = "Database"
      }
    ],
    [], [], []
  ]

  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.vpc_public_subnets
  private_subnet_ids         = module.vpc.vpc_private_subnets
  public_sg_id               = module.security_group.public_sg_id
  private_sg_id              = module.security_group.private_sg_id
 
}








