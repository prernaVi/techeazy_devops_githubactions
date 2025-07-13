Techeazy DevOps Automation
Overview

This repository contains automated infrastructure provisioning and deployment pipelines using Terraform and GitHub Actions for Techeazy DevOps Assignments 1, 2, and 3.

It provisions:

    AWS EC2 instances

    IAM roles and instance profiles

    Private S3 buckets

    Automated deployment of a Spring Boot application

while ensuring clean automation, CI/CD pipelines, and environment-specific configuration.
Objectives Covered
Assignment 1: Automate EC2 Deployment

    Spin up AWS EC2 instance with specified type.

    Install Java 19/21.

    Clone app repo and deploy Spring Boot app.

    Test app accessibility on port 80.

    Stop instance after validation (manual for cost saving).

    No secrets in repo; environment variables handle AWS credentials.

Assignment 2: Extend Automation

    Create IAM roles:

        Read-only on S3.

        Full S3 access for uploads.

    Attach IAM role to EC2 instance.

    Create private S3 bucket.

    Upload EC2 logs after shutdown for archival.

    Upload app deployment logs to S3 (/app/logs).

    Add S3 lifecycle rule for 7-day cleanup.

    Verify logs using read-only role.

Assignment 3: CI/CD Enhancements

    Infrastructure provisioning using Terraform with GitHub Actions.

    GitHub Actions triggers on push to main.

    Deploy app automatically post-provisioning.

    Health check to confirm EC2 app is reachable on port 80 post-deployment.

    Upload logs to S3 bucket for monitoring.

Tech Stack

    AWS (EC2, S3, IAM)

    Terraform

    GitHub Actions

    Spring Boot

    Bash scripting
