provider "aws" {
  region = var.region
}

# ----------------------------
# S3 bucket for static website
# ----------------------------
resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name
}

# Ownership control (ACLs disabled, owner enforced)
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.app_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public access block (keep bucket private)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.app_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ----------------------------
# Website hosting (for index.html)
# ----------------------------
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.app_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

# ----------------------------
# CloudFront distribution
# ----------------------------
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.app_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ----------------------------
# Bucket policy: allow only CloudFront
# ----------------------------
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.app_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

