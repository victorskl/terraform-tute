# aws-ses

> [As of 30 Oct 2019, SES is also available in Sydney region!](https://forums.aws.amazon.com/thread.jspa?threadID=286092)

This tute will test sending email through SES SMTP.


1. You can follow instruction from [Using the Amazon SES SMTP Interface to Send Email](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp.html) to setup through Console. But the terraform script is pretty much automated about this part of setup. Basically, it needs an IAM user with `ses:SendRawEmail` permission. So.

    ```
    cd aws-ses
    cp terraform.tfvars.sample terraform.tfvars
    terraform init
    terraform plan
    terraform apply
    terraform output
    ```

2. Next, we need to [verify an email address for SES identity](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses-procedure.html) purpose. Because, by default, SES account is in [Sandbox mode](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html). It goes like this.

    ```
    aws iam list-users
    aws iam list-access-keys --user-name ses-smtp-test-user
    aws ses verify-email-identity help
    aws ses verify-email-identity --region us-east-1 --email-address someone.tech@gmail.com
    aws ses list-identities --region us-east-1
    ``` 
   After executing `verify-email-identity` command, go to your GMail account and verify it. You should receive email subject like this from `Amazon Web Services <no-reply-aws@amazon.com>`.
   > Amazon Web Services – Email Address Verification Request in region US East (N. Virginia)

3. Then, we can perform [Testing Email Sending Using the Command Line](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp-client-command-line.html). Like follows.

    ```
    echo -n "<email_user>" | openssl enc -base64
    {{stdout_base64_encoded_email_user}}
    
    echo -n "<email_password>" | openssl enc -base64
    {{stdout_base64_encoded_email_password}}
    
    cp input.txt.sample input.txt
    (Replace all {{ xxx }} fields in input.txt)
    
    openssl s_client -crlf -quiet -starttls smtp -connect email-smtp.us-east-1.amazonaws.com:587
    
    openssl s_client -crlf -quiet -starttls smtp -connect email-smtp.us-east-1.amazonaws.com:587 < input.txt
    ```

4. Now verify that you receive the email that just sent from CLI in your GMail. Do check **Spam** folder as well!

5. Clean up

    ```
    aws ses list-identities --region us-east-1
    aws ses delete-identity help
    aws ses delete-identity --region us-east-1 --identity someone.tech@gmail.com
    aws iam list-users
    terraform destroy
    ```

## GSuite, DMARC, SPF and DKIM

Assume you use GSuite GMail for your domain email solution. From above quick tute, it should have worked out. However. In most production setup, we will need to tackle SES SMTP to work well with GSuite GMail [Spam settings](https://support.google.com/a/topic/2683828).

Typical GSuite GMail production setup probably have turned on DMARC, SPF and DKIM as part of best practices. The followings are resources for how to set this up, if not yet done so. In a nutshell, it has to add a couple of TXT DNS records into your domain.
- [DMARC Overview](https://dmarc.org/overview/)
- GSuite [GMail DMARC](https://support.google.com/a/answer/2466580)
- [Set up DKIM to prevent email spoofing](https://support.google.com/a/answer/174124)
- [Help prevent email spoofing with SPF records](https://support.google.com/a/answer/33786)
- [GMail Postmaster tool](https://gmail.com/postmaster/)

So. 

Assume you already have added TXT records for SPF, DKIM and have turned on DMARC. You can use `dig` to explore these DNS resource records.
```
dig -t mx mydomain.com
dig -t txt mydomain.com
dig -t txt _dmarc.mydomain.com
```

Observe that, you find TXT records like the followings. It basically means your domain email policy is in **strict** email authentication mode. At DMARC TXT record, the part `p=reject; aspf=s; adkim=s` says that both SPF and DKIM are in **strict** checking and reject email otherwise.
```
"v=DKIM1; k=rsa;" ... 
"v=spf1 include:_spf.google.com  ... -all"
"v=DMARC1; p=reject; aspf=s; adkim=s"
```

In SES side, the following guideline describe how to setup SES email authentication.

- [Authenticating Your Email in Amazon SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/authentication.html)
    - [Authenticating Email with SPF in Amazon SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/spf.html)
    - [Authenticating Email with DKIM in Amazon SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/dkim.html)
    - [Complying with DMARC Using Amazon SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/dmarc.html)

Note one caveat that, the [Complying with DMARC Using Amazon SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/dmarc.html) guide suggest to remove strict mode `aspf=s; adkim=s` tag. However. You do not need to. You can still keep DMARC in strict mode if you like. Just make sure to setup DKIM and SPF properly.

### TL;DR

Especially, pay attention to SPF and DKIM TXT records. Most of the time, if you want GSuite hosted GMail to work well with email sending from SES SMTP, you should [verify your domain as an identity in SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domain-procedure.html) and, generate DKIM and [populate DKIM TXT records](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/easy-dkim-setup-domain.html) accordingly.

And your SPF TXT record should something like:

```
"v=spf1 include:_spf.google.com  include:amazonses.com -all"
```

#### Custom MAIL FROM

Iff, for some reason, having `include:amazonses.com` SPF TXT record is an issue in your root domain, then you probably need to do  [Setting Up a Custom MAIL FROM Domain](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/mail-from.html). Normally, this is the case for scenarios like:
- when you have to setup sub-zone for your domain, and deploy your application there 
- a host (hostname or subdomain) requires to send out emails

Even then, this is totally optional. Do as you see fit for your purpose.
