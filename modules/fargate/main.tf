resource "aws_ecr_repository" "order_service" {
    name = "order_service"
    image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "fulfilment_service" {
    name = "fulfilment_service"
    image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "inventory_service" {
    name = "inventory_service"
    image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "delivery_service" {
    name = "delivery_service"
    image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "inventory_layout_service" {
    name = "inventory_layout_service"
    image_tag_mutability = "MUTABLE"
}

# ECS cluster
resource "aws_ecs_cluster" "is458-wms" {
    name = "is458-wms" 
    capacity_providers = ["FARGATE_SPOT", "FARGATE"]

    default_capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
    }
}

# ----------------------------------------- Fargate Task Definition ---------------------------------------
# Order Service
resource "aws_ecs_task_definition" "order-service" {
    family                   = "order-service" 
    container_definitions    = <<DEFINITION
    [
        {
        "name": "order-service",
        "image": "${aws_ecr_repository.order_service.repository_url}",
        "essential": true,
        "portMappings": [
            {
            "containerPort": 5000,
            "hostPort": 5000
            }
        ],
        "memory": 512,
        "cpu": 256
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
    network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
    memory                   = 512         # Specifying the memory our container requires
    cpu                      = 256         # Specifying the CPU our container requires
    execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

# Inventory Service
resource "aws_ecs_task_definition" "inventory-service" {
    family                   = "inventory-service" 
    container_definitions    = <<DEFINITION
    [
        {
        "name": "inventory-service",
        "image": "${aws_ecr_repository.inventory_service.repository_url}",
        "essential": true,
        "portMappings": [
            {
            "containerPort": 5003,
            "hostPort": 5003
            }
        ],
        "memory": 512,
        "cpu": 256
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
    network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
    memory                   = 512         # Specifying the memory our container requires
    cpu                      = 256         # Specifying the CPU our container requires
    execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}


# Inventory layout service
resource "aws_ecs_task_definition" "inventory-layout-service" {
    family                   = "inventory-layout-service" 
    container_definitions    = <<DEFINITION
    [
        {
        "name": "inventory-layout-service",
        "image": "${aws_ecr_repository.inventory_layout_service.repository_url}",
        "essential": true,
        "portMappings": [
            {
            "containerPort": 5002,
            "hostPort": 5002
            }
        ],
        "memory": 512,
        "cpu": 256
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
    network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
    memory                   = 512         # Specifying the memory our container requires
    cpu                      = 256         # Specifying the CPU our container requires
    execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

# fulfulment service
resource "aws_ecs_task_definition" "fulfilment-service" {
    family                   = "fulfilment-service" 
    container_definitions    = <<DEFINITION
    [
        {
        "name": "fulfilment-service",
        "image": "${aws_ecr_repository.fulfilment_service.repository_url}",
        "essential": true,
        "portMappings": [
            {
            "containerPort": 5005,
            "hostPort": 5005
            }
        ],
        "memory": 512,
        "cpu": 256
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
    network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
    memory                   = 512         # Specifying the memory our container requires
    cpu                      = 256         # Specifying the CPU our container requires
    execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

# delivery service
resource "aws_ecs_task_definition" "delivery-service" {
    family                   = "delivery-service" 
    container_definitions    = <<DEFINITION
    [
        {
        "name": "delivery-service",
        "image": "${aws_ecr_repository.delivery_service.repository_url}",
        "essential": true,
        "portMappings": [
            {
            "containerPort": 5004,
            "hostPort": 5004
            }
        ],
        "memory": 512,
        "cpu": 256
        }
    ]
    DEFINITION
    requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
    network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
    memory                   = 512         # Specifying the memory our container requires
    cpu                      = 256         # Specifying the CPU our container requires
    execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}


# ------------------------------ IAM Permission for the service to assume the role -------------------------------
# IAM definition
resource "aws_iam_role" "ecsTaskExecutionRole" {
    name               = "ecsTaskExecutionRole"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

    principals {
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
    role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -------------------------------------- Load Balancer Setting -----------------------------------
# Create load balancer
resource "aws_alb" "application_load_balancer" {
    name               = "lb-WMS" # Naming our load balancer
    load_balancer_type = "application"
    subnets = "${var.public_subnet}"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}


# Creating security group
resource "aws_security_group" "load_balancer_security_group" {
    vpc_id      = "${var.vpc_id}"
    ingress {
        from_port   = 80 # Allowing traffic in from port 80
        to_port     = 80
        protocol    = "tcp" # All
        cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
    }

    egress {
        from_port   = 0 # Allowing any incoming port
        to_port     = 0 # Allowing any outgoing port
        protocol    = "-1" # Allowing any outgoing protocol 
        cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
    }
}

# ----------------------------------------- Load Balancer Target Group ---------------------------------------
resource "aws_lb_target_group" "order_target_group" {
    name        = "order-target-group"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = "${var.vpc_id}" # Referencing the default VPC
    health_check {
        matcher = "200,301,302"
        path = "/order/healthcheck"
    }
}

resource "aws_lb_target_group" "inventory_target_group" {
    name        = "inventory-target-group"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = "${var.vpc_id}" # Referencing the default VPC
    health_check {
        matcher = "200,301,302"
        path = "/inventory/healthcheck"
    }
}

resource "aws_lb_target_group" "inventory_layout_target_group" {
    name        = "inventory-layout-target-group"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = "${var.vpc_id}" # Referencing the default VPC
    health_check {
        matcher = "200,301,302"
        path = "/inventory_layout/healthcheck"
    }
}

resource "aws_lb_target_group" "fulfilment_target_group" {
    name        = "fulfilment-target-group"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = "${var.vpc_id}" # Referencing the default VPC
    health_check {
        matcher = "200,301,302"
        path = "/fulfilment/healthcheck"
    }
}

resource "aws_lb_target_group" "delivery_target_group" {
    name        = "delivery-target-group"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = "${var.vpc_id}" # Referencing the default VPC
    health_check {
        matcher = "200,301,302"
        path = "/delivery/healthcheck"
    }
}

# ----------------------------------------- Load Balancer Lister ---------------------------------------
resource "aws_lb_listener" "listener" {
    load_balancer_arn = "${aws_alb.application_load_balancer.arn}" # Referencing our load balancer
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = "${aws_lb_target_group.order_target_group.arn}" 
    }
}

resource "aws_lb_listener_rule" "redirect_based_on_path_order" {
    listener_arn = aws_lb_listener.listener.arn

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.order_target_group.arn
    }

    condition {
        path_pattern {
        values = ["/order/*"]
        }
    }
}

resource "aws_lb_listener_rule" "redirect_based_on_path_inventory" {
    listener_arn = aws_lb_listener.listener.arn

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.inventory_target_group.arn
    }

    condition {
        path_pattern {
        values = ["/inventory/*"]
        }
    }
}

resource "aws_lb_listener_rule" "redirect_based_on_path_inventory_layout" {
    listener_arn = aws_lb_listener.listener.arn

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.inventory_layout_target_group.arn
    }

    condition {
        path_pattern {
        values = ["/inventory_layout/*"]
        }
    }
}

resource "aws_lb_listener_rule" "redirect_based_on_path_fufilment" {
    listener_arn = aws_lb_listener.listener.arn

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.fulfilment_target_group.arn
    }

    condition {
        path_pattern {
        values = ["/fulfilment/*"]
        }
    }
}

resource "aws_lb_listener_rule" "redirect_based_on_path_delivery" {
    listener_arn = aws_lb_listener.listener.arn

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.delivery_target_group.arn
    }

    condition {
        path_pattern {
        values = ["/delivery/*"]
        }
    }
}



# ----------------------------------------- Fargate Backend Services ---------------------------------------
# Order Service
resource "aws_ecs_service" "order-service" {
    name            = "order-service"                             # Naming our first service
    cluster         = "${aws_ecs_cluster.is458-wms.id}"             # Referencing our created Cluster
    task_definition = "${aws_ecs_task_definition.order-service.arn}" # Referencing the task our service will spin up
    launch_type     = "FARGATE"
    desired_count   = 1 # Setting the number of containers we want deployed to 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.order_target_group.arn}" # Referencing our target group
        container_name   = "${aws_ecs_task_definition.order-service.family}"
        container_port   = 5000 # Specifying the container port
    }

    network_configuration {
        subnets          = "${var.public_subnet}"
        assign_public_ip = true # Providing our containers with public IPs
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }
}

# Inventory Service
resource "aws_ecs_service" "inventory-service" {
    name            = "inventory-service"                             # Naming our first service
    cluster         = "${aws_ecs_cluster.is458-wms.id}"             # Referencing our created Cluster
    task_definition = "${aws_ecs_task_definition.inventory-service.arn}" # Referencing the task our service will spin up
    launch_type     = "FARGATE"
    desired_count   = 1 # Setting the number of containers we want deployed to 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.inventory_target_group.arn}" # Referencing our target group
        container_name   = "${aws_ecs_task_definition.inventory-service.family}"
        container_port   = 5003 # Specifying the container port
    }

    network_configuration {
        subnets          = "${var.public_subnet}"
        assign_public_ip = true # Providing our containers with public IPs
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }
}

# Inventory_layout Service
resource "aws_ecs_service" "inventory-layout-service" {
    name            = "inventory-layout-service"                             # Naming our first service
    cluster         = "${aws_ecs_cluster.is458-wms.id}"             # Referencing our created Cluster
    task_definition = "${aws_ecs_task_definition.inventory-layout-service.arn}" # Referencing the task our service will spin up
    launch_type     = "FARGATE"
    desired_count   = 1 # Setting the number of containers we want deployed to 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.inventory_layout_target_group.arn}" # Referencing our target group
        container_name   = "${aws_ecs_task_definition.inventory-layout-service.family}"
        container_port   = 5002 # Specifying the container port
    }

    network_configuration {
        subnets          = "${var.public_subnet}"
        assign_public_ip = true # Providing our containers with public IPs
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }
}

# Fulfilment Service
resource "aws_ecs_service" "fulfilment-service" {
    name            = "fulfilment-service"                             # Naming our first service
    cluster         = "${aws_ecs_cluster.is458-wms.id}"             # Referencing our created Cluster
    task_definition = "${aws_ecs_task_definition.fulfilment-service.arn}" # Referencing the task our service will spin up
    launch_type     = "FARGATE"
    desired_count   = 1 # Setting the number of containers we want deployed to 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.fulfilment_target_group.arn}" # Referencing our target group
        container_name   = "${aws_ecs_task_definition.fulfilment-service.family}"
        container_port   = 5005 # Specifying the container port
    }

    network_configuration {
        subnets          = "${var.public_subnet}"
        assign_public_ip = true # Providing our containers with public IPs
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }
}

# Fulfilment Service
resource "aws_ecs_service" "delivery-service" {
    name            = "delivery-service"                             # Naming our first service
    cluster         = "${aws_ecs_cluster.is458-wms.id}"             # Referencing our created Cluster
    task_definition = "${aws_ecs_task_definition.delivery-service.arn}" # Referencing the task our service will spin up
    launch_type     = "FARGATE"
    desired_count   = 1 # Setting the number of containers we want deployed to 3

    load_balancer {
        target_group_arn = "${aws_lb_target_group.delivery_target_group.arn}" # Referencing our target group
        container_name   = "${aws_ecs_task_definition.delivery-service.family}"
        container_port   = 5004 # Specifying the container port
    }

    network_configuration {
        subnets          = "${var.public_subnet}"
        assign_public_ip = true # Providing our containers with public IPs
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }
}


# --------------------------------- Security Group for all fargate services ------------------------
resource "aws_security_group" "service_security_group" {
    vpc_id      = "${var.vpc_id}"
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        # Only allowing traffic in from the load balancer security group
        security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


# ------------------------------- Auto Scaling Group -------------------------------------------
# Order Service
resource "aws_appautoscaling_target" "dev_to_target_order" {
    max_capacity = 3
    min_capacity = 1
    resource_id = "service/${aws_ecs_cluster.is458-wms.name}/${aws_ecs_service.order-service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory_order" {
    name               = "dev-to-memory-order"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dev_to_target_order.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_order.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dev_to_target_order.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        target_value       = 80
    }
}

resource "aws_appautoscaling_policy" "dev_to_cpu_order" {
    name = "dev-to-cpu-order"
    policy_type = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.dev_to_target_order.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_order.scalable_dimension
    service_namespace = aws_appautoscaling_target.dev_to_target_order.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }

        target_value = 60
    }
}

# Inventory
resource "aws_appautoscaling_target" "dev_to_target_inventory" {
    max_capacity = 3
    min_capacity = 1
    resource_id = "service/${aws_ecs_cluster.is458-wms.name}/${aws_ecs_service.inventory-service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory_inventory" {
    name               = "dev-to-memory-inventory"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dev_to_target_inventory.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_inventory.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dev_to_target_inventory.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        target_value       = 80
    }
}

resource "aws_appautoscaling_policy" "dev_to_cpu_inventory" {
    name = "dev-to-cpu-inventory"
    policy_type = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.dev_to_target_inventory.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_inventory.scalable_dimension
    service_namespace = aws_appautoscaling_target.dev_to_target_inventory.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }

        target_value = 60
    }
}

# Inventory_Layout
resource "aws_appautoscaling_target" "dev_to_target_inventory_layout" {
    max_capacity = 3
    min_capacity = 1
    resource_id = "service/${aws_ecs_cluster.is458-wms.name}/${aws_ecs_service.inventory-layout-service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory_inventory_layout" {
    name               = "dev-to-memory-inventory-layout"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dev_to_target_inventory_layout.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_inventory_layout.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dev_to_target_inventory_layout.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        target_value       = 80
    }
}

resource "aws_appautoscaling_policy" "dev_to_cpu_inventory_layout" {
    name = "dev-to-cpu-inventory-layout"
    policy_type = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.dev_to_target_inventory_layout.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_inventory_layout.scalable_dimension
    service_namespace = aws_appautoscaling_target.dev_to_target_inventory_layout.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }

        target_value = 60
    }
}

# Fulfilment 
resource "aws_appautoscaling_target" "dev_to_target_fulfilment" {
    max_capacity = 3
    min_capacity = 1
    resource_id = "service/${aws_ecs_cluster.is458-wms.name}/${aws_ecs_service.fulfilment-service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory_fulfilment" {
    name               = "dev-to-memory-fulfilment"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dev_to_target_fulfilment.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_fulfilment.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dev_to_target_fulfilment.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        target_value       = 80
    }
}

resource "aws_appautoscaling_policy" "dev_to_cpu_fulfilment" {
    name = "dev-to-cpu-fulfilment"
    policy_type = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.dev_to_target_fulfilment.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_fulfilment.scalable_dimension
    service_namespace = aws_appautoscaling_target.dev_to_target_fulfilment.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }

        target_value = 60
    }
}

# Delivery
resource "aws_appautoscaling_target" "dev_to_target_delivery" {
    max_capacity = 3
    min_capacity = 1
    resource_id = "service/${aws_ecs_cluster.is458-wms.name}/${aws_ecs_service.delivery-service.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory_delivery" {
    name               = "dev-to-memory-delivery"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_appautoscaling_target.dev_to_target_delivery.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_delivery.scalable_dimension
    service_namespace  = aws_appautoscaling_target.dev_to_target_delivery.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
        target_value       = 80
    }
}

resource "aws_appautoscaling_policy" "dev_to_cpu_delivery" {
    name = "dev-to-cpu-delivery"
    policy_type = "TargetTrackingScaling"
    resource_id = aws_appautoscaling_target.dev_to_target_delivery.resource_id
    scalable_dimension = aws_appautoscaling_target.dev_to_target_delivery.scalable_dimension
    service_namespace = aws_appautoscaling_target.dev_to_target_delivery.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }

        target_value = 60
    }
}
