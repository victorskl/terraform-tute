# aws-route53

- https://www.terraform.io/docs/providers/aws/d/route53_zone.html
- https://www.terraform.io/docs/providers/aws/r/route53_zone.html
- https://www.terraform.io/docs/providers/aws/r/route53_record.html
- ...
- https://stackoverflow.com/questions/48919317/how-can-i-create-a-route53-record-to-an-alb


### Hosted Zone

- https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html
    - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html
    - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-private.html

- https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/GetInfoAboutHostedZone.html
- https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/creating-migrating.html
    - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingNewSubdomain.html
    - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingSubdomain.html
    - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html

- https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html

- https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html

- https://aws.amazon.com/route53/pricing/

- https://hodovi.ch/posts/securing-a-site-with-letsencrypt-aws-and-terraform/

### ALB

- https://www.terraform.io/docs/providers/aws/r/lb_listener.html
- https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

### ACM

- https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html
- https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-dns.html
- https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html
- ...
- https://www.terraform.io/docs/providers/aws/r/acm_certificate.html
- https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html

### Note

- Generally, Route53, ACM and ALB - 3 services work in tandem to achieve DNS setup with SSL certificate and auto-renewal, there of.
- Just like LetEncrypt and Certbot toolchain, ACM is Amazon version of free SSL cert with auto-renewal facility through DNS or Email.
- And; ACM free SSL certificate auto-renewal is a breeze if it makes use of Route53 Public Hosted Zone. But; also possible elsewhere with the loose of automated CNAME creation for Cert validation purpose.
- Normally, procedure is:
    1. prepare a domain or sub-domain name; could be fresh new domain registration or add sub-zone to an existing one; e.g. `demo.example.com`
    2. [create Hosted Zone](02-create-hosted-zone) in Route53 Console; e.g. Domain Name: `demo.example.com`, Type: `Public Hosted Zone`
    3. then; it will give NS records that need to add at `example.com` parent DNS zone, e.g.
        ```
        NS      demo        ns-271.awsdns-33.com.
        NS      demo        ns-604.awsdns-11.net.
        NS      demo        ns-1753.awsdns-27.co.uk.
        NS      demo        ns-1433.awsdns-51.org.
        ```
    4. finally; for example, run to [orchestrate to all 3 services to complete the setup](04-finish-setup) 
    
If parent zone i.e. root domain (e.g. `example.com`) is registered through Route53, then it is possible to automate all 4-steps. But; if the parent zone DNS registerer is elsewhere and managed by elsewhere, then step #1 and #3 will have to perform manually, for one time.

```
Register a Domain

cd 02-create-hosted-zone
terraform init
terraform plan
terraform apply

Update NS record in a Domain

cd ../04-finish-setup
terraform init
terraform plan
terraform apply
```
