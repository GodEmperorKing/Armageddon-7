### 1) Cache policy for static content (aggressive)
resource "aws_cloudfront_cache_policy" "chewbacca_cache_static01" {
  name        = "chewbacca-cache-static01"
  comment     = "Aggressive caching for /static/*"
  default_ttl = 86400    # 1 day
  max_ttl     = 31536000 # 1 year
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config { cookie_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
    headers_config { header_behavior = "none" }
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

### 2) Cache policy for API (safe default: caching disabled)
resource "aws_cloudfront_cache_policy" "chewbacca_cache_api_disabled01" {
  name        = "chewbacca-cache-api-disabled01"
  comment     = "Disable caching for /api/* by default"
  default_ttl = 0
  max_ttl     = 0
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config { cookie_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
    headers_config { header_behavior = "none" } # Fixed: Must be none if TTL is 0
    enable_accept_encoding_gzip   = false
    enable_accept_encoding_brotli = false
  }
}

### 3) Origin request policy for API (forward what origin needs)
resource "aws_cloudfront_origin_request_policy" "chewbacca_orp_api01" {
  name    = "chewbacca-orp-api01"
  comment = "Forward necessary values for API calls"

  cookies_config { cookie_behavior = "all" }
  query_strings_config { query_string_behavior = "all" }
  headers_config {
    header_behavior = "whitelist"
    # Fixed: AWS forbids 'Authorization' in this specific list
    headers { items = ["Content-Type", "Origin", "Host"] }
  }
}

### 4) Origin request policy for static (minimal)
resource "aws_cloudfront_origin_request_policy" "chewbacca_orp_static01" {
  name    = "chewbacca-orp-static01"
  comment = "Minimal forwarding for static assets"

  cookies_config { cookie_behavior = "none" }
  query_strings_config { query_string_behavior = "none" }
  headers_config { header_behavior = "none" }
}

### 5) Response headers policy (We are doing the Be A Man challenge!)
resource "aws_cloudfront_response_headers_policy" "chewbacca_rsp_static01" {
  name    = "chewbacca-rsp-static01"
  comment = "Add explicit Cache-Control for static content"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = true
      value    = "public, max-age=86400, immutable"
    }
  }
}