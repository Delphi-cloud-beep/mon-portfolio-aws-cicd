# ==========================================
# CONFIGURATION DES PROVIDERS (INDISPENSABLE)
# ==========================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider par défaut pour la France (Paris)
provider "aws" {
  region = "eu-west-3"
}

# Provider spécifique pour le certificat SSL (Obligatoire en us-east-1 pour CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# ==========================================
# 1. ACM & DNS (Certificat SSL)
# ==========================================

resource "aws_acm_certificate" "frontend_cert" {
  provider          = aws.us_east_1
  domain_name       = "www.delphine.cloud"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# ==========================================
# 2. DYNAMODB (Stockage des messages)
# ==========================================

resource "aws_dynamodb_table" "contact_messages" {
  name         = "PortfolioContacts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "MessageId"

  attribute {
    name = "MessageId"
    type = "S"
  }
}

# ==========================================
# 3. IAM (Sécurité et Permissions)
# ==========================================

resource "aws_iam_role" "lambda_role" {
  name = "portfolio_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "dynamo_policy" {
  name = "lambda_dynamo_write_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["dynamodb:PutItem"],
      Effect   = "Allow",
      Resource = aws_dynamodb_table.contact_messages.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ==========================================
# 4. LAMBDA (Traitement du formulaire)
# ==========================================

resource "aws_lambda_function" "contact_handler" {
  filename         = "lambda_function.zip"
  function_name    = "PortfolioContactHandler"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.contact_messages.name
    }
  }
}

resource "aws_lambda_function_url" "contact_lambda_url" {
  function_name      = aws_lambda_function.contact_handler.function_name
  authorization_type = "NONE"

  cors {
    allow_origins     = ["*"] # Elargi temporairement pour le test
    allow_methods     = ["*"]
    allow_headers     = ["content-type"]
    max_age           = 86400
  }
}

resource "aws_lambda_permission" "allow_public_url" {
  statement_id           = "AllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.contact_handler.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# ==========================================
# 5. S3 & CLOUDFRONT (Hébergement Web)
# ==========================================

resource "aws_s3_bucket" "frontend_bucket" {
  bucket        = "mon-portfolio-frontend-2026"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudFrontServicePrincipalReadOnly"
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      Condition = {
        StringEquals = { "AWS:SourceArn" = aws_cloudfront_distribution.frontend_cdn.arn }
      }
    }]
  })
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3_oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend_cdn" {
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "S3-Frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  default_root_object = "index.html"
  
  # On commente l'alias pour éviter le conflit CNAME d'OVH
  # aliases             = ["www.delphine.cloud"] 

  default_cache_behavior {
    target_origin_id       = "S3-Frontend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    # On utilise le certificat par défaut temporairement[cite: 2]
    cloudfront_default_certificate = true
    
    # On commente les lignes du certificat personnalisé[cite: 2]
    # acm_certificate_arn      = aws_acm_certificate.frontend_cert.arn
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"
  }
}

# ==========================================
# 6. OUTPUTS (Résultats du déploiement)
# ==========================================

output "form_action_url" {
  value = aws_lambda_function_url.contact_lambda_url.function_url
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}