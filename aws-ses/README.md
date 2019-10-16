# aws-ses

This tute will test sending email through SES SMTP.


1. You can follow instruction from [Using the Amazon SES SMTP Interface to Send Email](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp.html) to setup through Console. But the terraform script is pretty much automated about this part of setup. So.

    ```
    cd aws-ses
    cp terraform.tfvars.sample terraform.tfvars
    terraform init
    terraform plan
    terraform apply
    terraform output
    ```

2. Next, we need to verify an email address for SES identity purpose. Because, by default, SES account is in [Sandbox mode](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html). It goes like this.

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
