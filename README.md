# Magento2 Docker Image

This is a Docker build context to build a Docker image for Magento2 CE 2.1.3 which contains Apache2, PHP7.0, MySQL, Redis.

## What the Docker Image contains

1. Ubuntu 16.04 (as base image).
2. Apache2
3. PHP7.0
4. Redis
5. MySQL
6. Magento2 CE 2.1.3

Note: 
To download the Magento2 package from [Magento Marketplace](https://magento.com/tech-resources/download) need to login, here we push the package to github repository, and the Dockerfile are using the URL of the repository to get the Magento2 package, if you need to use the package from your URL please change the ENV 'PACKAGE_URL' to yours in the Dockerfile.

## How To Build The Image

At the same directory level with Dockerfile, run the command:

```
$sudo docker build -t [image name] .
```

## How To Run The Image On Your Host

run the command:

```
$sudo docker run -t -p 80:80 -e BASE_URL=http://<your host name>/ [--name <the Docker container name>] <image name>
```
Environment variables and their default value:

ADMIN_FIRSTNAME     firstname
ADMIN_LASTNAME      lastname
ADMIN_EMAIL         sample@example.com
ADMIN_USER          root
ADMIN_PASSWORD      password1234
DB_NAME             magento
DB_PASSWORD         password1234
BACKEND_FRONTNAME   admin

Note:
1. The variable BASE_URL must be set the same with your host name to avoid issues on accessing the Magento Admin Panel, see the introduction for the parameter 'base-url' in [Mangento2 command line installation instruction](http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html).  
2. If the environment variables listed above hasn't been set, the default values will be used, however, it's recommended to use different values for security reasons.
3. It's not recommended to simply use 'admin' as the value of BACKEND_FRONTNAME, see the introduction for the parameter 'backend-frontname' in [Mangento2 command line installation instruction](http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html).

## How To Apply The Docker Image On Azure Web App For Linux

### Deploy Azure Web App With Docker Image Aotumatically

1. Push the image to the Docker Hub after you build it.
2. Change the value of the parameter 'dockerRegistryImageName' to the name of your image.
3. Press this button.
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

### Deploy Azure Web App With Docker Image Manually

1. Create the resource Azure web app on Linux (Preview).
2. Add these application settings:

DOCKER_CUSTOM_IMAGE_NAME     <Docker image name>                  <Required>
ADMIN_FIRSTNAME              <firstname>
ADMIN_LASTNAME               <lastname>
ADMIN_EMAIL                  <email>
ADMIN_USER                   <admin username>
ADMIN_PASSWORD               <admin password>
DB_NAME                      <database name>
DB_PASSWORD                  <database password>
BACKEND_FRONTNAME            <backend frontname>
BASE_URL                     <site base url>                       <Required>

3. Your Docker image will be pulled and run at the first requests reach the server, so the cold start process will be quite long.

## How To Make Optimization Of The Site

#### Enable The Cache

Go to the admin panel, STORES -> Configuration -> CATALOG -> Catalog -> Use Flat Catalog Category  and put “Yes” .

#### Merge CSS and JS Files
 
For JS:
1. Go to the admin panel,  STORES -> Configuration -> ADVANCED -> Developer -> JavaScript Settings
2. Merge JavaScript Files -> Yes
3. Minify JavaScript Files -> Yes

For CSS:
1. Go to the admin panel,  STORES -> Configuration -> ADVANCED -> Developer -> CSS Settings
2. Merge CSS Files -> Yes
3. Minify CSS Files -> Yes

#### Enable the Caching

Go to admin portal, SYSTEM -> Cache Management 

#### Content Delivery Network

Content Delivery Network (CDN) is a special system that can connect all cache servers. In addition to supported geographical proximity, CDN will take over the delivering web content and fasten the page loading.

Go to admin portal, Stores -> Configuration > General > Web > Base URLs (Secure)

