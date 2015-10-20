# Projects

Below are the infrastructures we currently have examples for. Go to each project to see what will be provisioned.

- [Complex AWS Infrastructure](terraform/projects/01/README.md)
- [Simple AWS Infrastructure](terraform/projects/02/README.md)

## Getting Started

This repository contains example [projects](#projects) showing how to deploy infrastructures across many different operating sytems and cloud providers. Check out the list of [projects](#projects) we currently have examples for. The example [projects](#projects) will range from small, simple, infrastructures, to very complex, end to end infrastructures.

There are many different Packer & Terraform templates that each project utilizes. You can think of this as a library of Packer templates and Terraform modules that allow you to provision unique infrastructures by referencing the different templates and modules. We've tried to set this repository up in a way that we don't have to duplicate code, allowing templates and modules to be used across many projects.

Each project is a best practices guide for how to use HashiCorp tooling to provision that specific type of infrastructure. Use each as a reference when building your own infrastructure. The best way to get started is to pick a project that resembles an infrastructure you are looking to build, get it up and running, then configure and modify it to meet your specific needs.

No one example will be exactly what you need, but it should provide you with enough examples to get you headed in the right direction. This is all open source, so please contribute as you see fit.

A couple things to keep in mind...

- Each projects README will reference different sections in [General Setup](../setup/general.md) to get your environment properly setup to build the infrastructure at hand.
- Each section will assume you are starting in the base [`infrastructures`]() directory.
- Each project will assume you're using Atlas. If you plan on doing everything locally, there are portions of projects that may not work due to the extra features Atlas provides that we are take advantage of.
- Each projects instructional documentation is running off of the assumption that certain information will be saved as environment variables. If you do not wish to use environment variables, there are different ways to pass this information, but you may have to take extra undocumented steps to get commands to work properly.
- All `packer push` commands must be performed in the base [`infrastructures`]() directory
- All `terraform push` commands must be performed in the appropriate Terraform project directory (e.g. [project 01](terraform/projects/01))
