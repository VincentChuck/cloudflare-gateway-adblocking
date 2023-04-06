# Serverless Ad Blocking with Cloudflare Gateway

This repository is a fork of the [Original Repository](https://github.com/marco-lancini/utils/tree/main/terraform/cloudflare-gateway-adblocking). The setup guide was shared [here](https://blog.marcolancini.it/2022/blog-serverless-ad-blocking-with-cloudflare-gateway/).

This is my experiment to implement a cross-platform ad-blocker with a customizable block-list.

It is a terraform module that configures Cloudflare Gateway to block ads by creating:

    - A set of Cloudflare Lists which contain the list of domains to block
    - A Cloudflare Gateway Policy which blocks access (at the DNS level) to those domains
