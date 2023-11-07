# Set up key pair
resource "aws_key_pair" "test_key_pair" {
  key_name   = "${terraform.workspace}_bean_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_elastic_beanstalk_application" "test_beanstalk" {
  name = var.APP_NAME
}

resource "aws_elastic_beanstalk_environment" "test_beanstalk_env" {
  name                = "${terraform.workspace}-beanstalk-env"
  application         = aws_elastic_beanstalk_application.test_beanstalk.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.0 running ECS" //"64bit Amazon Linux 2023 v4.1.0 running Docker"

  // Set up launch instance
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "ImageId"
    value     = data.aws_ami.aws_linux.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.test_key_pair.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = join(",", [aws_security_group.test_bean_sg.id])
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "service-role/aws-elasticbeanstalk-service-role"
  }

  // Set up autoscaling
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Minsize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Maxsize"
    value     = terraform.workspace == "staging" ? 3 : 1
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [aws_subnet.test_public_1.id, aws_subnet.test_public_2.id])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.test_vpc.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     =  "aws-elasticbeanstalk-ec2-role"
  }

  #Cloud watchaws:elasticbeanstalk:cloudwatch:logs:health
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     =  "true"
  }
  
  # Set up loadbalancer and target group
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = join(",", [aws_security_group.test_bean_sg.id])
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = aws_security_group.test_bean_sg.id
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [aws_subnet.test_lb_1.id, aws_subnet.test_lb_2.id])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "InstancePort"
    value     = "80"
  }

  # Database set up
  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name = "DBEngine"
  #   value = "postgres"
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name = "DBInstanceClass"
  #   value = "db.t3.micro"
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name      = "DBEngineVersion"
  #   value     = "14.5"
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name      = "DBAllocatedStorage"
  #   value     = "10"
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name      = "DBDeletionPolicy"
  #   value     = "Delete"
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name      = "HasCoupledDatabase"
  #   value     = "true"
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name = "DBPassword"
  #   value = var.DB_PASSWORD
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name = "DBUser"
  #   value = var.DB_USERNAME
  # }

  # setting {
  #   namespace = "aws:rds:dbinstance"
  #   name      = "MultiAZDatabase"
  #   value     = "true"
  # }

  // Set up environment variable
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RAILS_ENV"
    value = "production"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "REDIS_SERVER"
    value = var.REDIS_SERVER
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POSTGRES_HOST"
    value = var.DB_NAME
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POSTGRES_PASSWORD"
    value = var.DB_PASSWORD
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POSTGRES_DATABASE"
    value = var.DB_NAME
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "POSTGRES_USERNAME"
    value = var.DB_USERNAME
  }
}