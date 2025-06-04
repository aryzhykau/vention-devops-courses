# Configure AWS Provider
provider "aws" {
  region = "us-west-2"
  alias  = "primary"
}

provider "aws" {
  region = "us-east-1"
  alias  = "secondary"
}

# Random string for unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create main bucket
resource "aws_s3_bucket" "main" {
  provider = aws.primary
  bucket   = "main-bucket-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "MainBucket"
    Environment = "Training"
    Project     = "AWS-Course"
  }
}

# Create replica bucket
resource "aws_s3_bucket" "replica" {
  provider = aws.secondary
  bucket   = "replica-bucket-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "ReplicaBucket"
    Environment = "Training"
    Project     = "AWS-Course"
  }
}

# Block public access for main bucket
resource "aws_s3_bucket_public_access_block" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access for replica bucket
resource "aws_s3_bucket_public_access_block" "replica" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for main bucket
resource "aws_s3_bucket_versioning" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable versioning for replica bucket
resource "aws_s3_bucket_versioning" "replica" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.replica.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Create IAM role for replication
resource "aws_iam_role" "replication" {
  provider = aws.primary
  name     = "s3-bucket-replication-${random_string.bucket_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for replication
resource "aws_iam_role_policy" "replication" {
  provider = aws.primary
  name     = "s3-bucket-replication-policy"
  role     = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.main.arn
        ]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.main.arn}/*"
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.replica.arn}/*"
        ]
      }
    ]
  })
}

# Configure replication
resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.primary
  
  depends_on = [
    aws_s3_bucket_versioning.main
  ]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "replicate_all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica.arn
      storage_class = "STANDARD_IA"
    }
  }
}

# Configure lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  # Rule for documents
  rule {
    id     = "documents"
    status = "Enabled"

    filter {
      prefix = "documents/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  # Rule for archives
  rule {
    id     = "archives"
    status = "Enabled"

    filter {
      prefix = "archives/"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  # Rule for logs
  rule {
    id     = "logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }
  }
}

# Enable encryption for main bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable encryption for replica bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.replica.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable metrics
resource "aws_s3_bucket_metric" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id
  name     = "EntireBucket"
}

# Create folders
resource "aws_s3_object" "documents" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id
  key      = "documents/"
  content  = ""
}

resource "aws_s3_object" "archives" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id
  key      = "archives/"
  content  = ""
}

resource "aws_s3_object" "logs" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id
  key      = "logs/"
  content  = ""
}

# Outputs
output "main_bucket_name" {
  description = "Name of the main bucket"
  value       = aws_s3_bucket.main.id
}

output "replica_bucket_name" {
  description = "Name of the replica bucket"
  value       = aws_s3_bucket.replica.id
}

output "main_bucket_arn" {
  description = "ARN of the main bucket"
  value       = aws_s3_bucket.main.arn
}

output "replica_bucket_arn" {
  description = "ARN of the replica bucket"
  value       = aws_s3_bucket.replica.arn
}

output "replication_role_arn" {
  description = "ARN of the replication IAM role"
  value       = aws_iam_role.replication.arn
} 