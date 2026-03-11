<p align="center">
  <a href="https://github.com/new?template_name=boilerplate-odoo-enterprise&template_owner=adomi-io&visibility=private">
    <img
      src="https://img.shields.io/badge/Use%20this%20template-2ea44f?style=for-the-badge&logo=github&logoColor=white"
      alt="Use this template"
      width="400"
    />
  </a>
</p>

# Adomi - Odoo Enterprise Boilerplate

> [!TIP]
> **Want to lower your license costs?**
> 
> Try our [odoo-community-base](https://github.com/adomi-io/odoo-community-base) image
> which includes some helpful OCA packages and additional addons to make the Odoo Community edition 
> more closely aligned with Odoo Enterprise, but without the license cost.
> 
> We recommend giving this a try before making new Odoo Enterprise commitments. Take a copy of our [Odoo boilerplate](https://github.com/adomi-io/boilerplate-odoo), 
> and set the `ODOO_BASE_IMAGE` arg to:
> ```md
> ghcr.io/adomi-io/odoo-community-base:latest
> ```

Odoo is an open-source ERP platform that bundles common business apps (CRM, Sales, Inventory, Accounting, HR, Manufacturing, and more) into a single system.

This repository will build your team a private Odoo Enterprise Docker image. 


> [!NOTE]
> Upstream image source code
> 
> - [adomi-io/odoo](https://github.com/adomi-io/odoo)
> - [adomi-io/boilerplate-odoo](https://github.com/adomi-io/boilerplate-odoo)


# Getting started

## Setup this repository

- Click the ["Use this template"]() button above.
- Ensure the `Visibility` is set to `Private`, and click `Create repository`.
- The first GitHub action run will fail because it does not have access to the Odoo Enterprise repo.
- Once the repository is created, go to the repository's `Settings` page. 
- Click `Secrets and variables` in the left sidebar, and select `Actions`.
- Using a GitHub account which has access to a repository with Odoo Enterprise, generate a new PAT token with the `repo` scope.
- Create a repository or organization secret named `ODOO_ENTERPRISE_GITHUB_TOKEN` and paste the token value.
- Re-run the failed workflow.

> [!TIP]
> If you have GitHub's CLI installed, and you are a developer with access to Odoo Enterprise,
> you can run `gh auth token` and use that as the value for `ODOO_ENTERPRISE_GITHUB_TOKEN`.

> [!TIP]
> If you have a GitHub organization, you can set the `ODOO_ENTERPRISE_GITHUB_TOKEN` secret in the organization's settings.
> which will allow all repositories in the organization to use the token, and skip the initial workflow run failure.

> [!TIP]
> You can go into the package settings and change the `Visibility` to `Internal` and everyone on 
> your team will be able to use the package.

## Using the resulting image

- Once the GitHub action completes, you should have a package in your repository's Packages tab.
- Copy the image URL from the Packages tab
- Use the [boilerplate-odoo](https://github.com/adomi/boilerplate-odoo) template
- Change the `ODOO_BASE_IMAGE` arg to the image URL you copied, and the `latest` tag, eg: `ghcr.io/your-company/odoo-enterprise:latest`
- Run `docker-compose up --build`

> [!TIP]
> If you use the `boilerplate-odoo`, and update the `ODOO_BASE_IMAGE`, then in the repository settings,
> mark it as a "Template repository," you will have an internal one-button way to create Odoo Enterprise repositories
> for your team and clients.

# Project layout

* `addons/`
  Your custom Odoo addons live here.

* `config/`
  Odoo config files you want to mount into the container.

* `hooks/`
  Startup/setup scripts (auto-install modules, bootstrap config, etc).

* `extra_addons/` (optional)
  Extra addons you want to bake into a downstream image or mount separately from `addons/`.

# Changing the base image

This repo lets you use any base image you want. This lets you extend any part of our stack,
and quickly swap out the base image for your own image, or one of our pre-configured images.

This allows you to have a custom pre-built version of Odoo with all your custom addons which you can
quickly take a copy of, or to swap a user's underlying image to Enterprise quickly and easily. 

You can change the base image via a build arg in the `docker-compose.yml`, or by editing the `Dockerfile`.

## Dockerfile
If you would like to change the default base image for your project, after taking a copy of this template,
change the first line of the `Dockerfile` to your desired base image url:

```dockerfile
ARG ODOO_BASE_IMAGE=ghcr.io/adomi-io/odoo:19.0
```

## Build args

You can override the build args on a per-deployment basis. This is helpful if you wish to offer both a community and enterprise version of Odoo.
If you have a pre-configured image with Enterprise, you can override the base image in the `docker-compose.yml`

```yaml
services:
  app_odoo:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        ODOO_BASE_IMAGE: ghcr.io/your-company/odoo-enterprise:latest
```

The following build arguments are available:

| Argument | Description | Default |
| --- | --- | --- |
| `ODOO_BASE_IMAGE` | The base image to use for the build. | `ghcr.io/adomi-io/odoo:19.0` |
| `ODOO_ENTERPRISE_REPOSITORY` | The Odoo Enterprise repository URL. | `https://github.com/odoo/enterprise` |
| `ODOO_ENTERPRISE_BRANCH` | The branch of the Odoo Enterprise repository to clone. | `19.0` |
| `SPECIFIC_DATE` | Clone the repository as it was on this date (e.g., `2024-01-01`). | `""` |
| `SPECIFIC_HASH` | Clone the repository at a specific git hash. | `""` |
| `GIT_AUTH_FORMAT` | The format for git authentication. | `'https://x-access-token:%s@github.com\n'` |

# Making your own base image

To make your own base image, simply take a copy of this repo, and add your custom addons to the `extra_addons` folder,
and push your code to GitHub. GitHub Actions will build and push your image to GitHub Container Registry. Copy the image URL
from the Packages tab, and use it as the base image.

See our [Odoo Community Base image](https://github.com/adomi-io/odoo-community-base) for an example

## Debugging

If you’re using the Adomi Odoo image as your runtime, you can also use it as a development environment.
See the main image repo for IDE and breakpoint setup patterns:

* **[adomi-io/odoo](https://github.com/adomi-io/odoo)**

# Adomi
Adomi is an Odoo partner and consulting company. We try to make developing Odoo apps and business
utilities as easy as possible. This boilerplate will get you started with Odoo quickly and allow you to run
your odoo instance anywhere.

Check out some of our other projects:
* **[adomi-io on GitHub](https://github.com/adomi-io)**