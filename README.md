# Magento2 Docker Image

This is a Docker build context to build the Docker image for Magento2 CE 2.1.3 which contains all the running prerequisite ( Apache2, PHP7.0, MySQL, Redis).  
  

## What the Docker Image Contains

1. Ubuntu 16.04 (as base image)
2. Apache2
3. PHP7.0
4. Redis
5. MySQL
6. Magento2 CE 2.1.3

#### Note:  
1. Here we've downloaded the Magento2 CE 2.1.3 package from [Magento Tech Resource](https://magento.com/tech-resources/download) and put it to our [github repository](https://raw.githubusercontent.com/Sharpeli/Packages/master/Magento-CE-2_1_3_tar_gz-2016-12-13-09-08-39.tar.gz) which was referenced by our Dockerfile.  
2. If you want use the package from your own location, just put this argument in your docker build command: `--build-arg PACKAGE_URL=<your package location>`.  
   And please note that:  
   1. Please ensure that the package you download is from [Magento Tech Resource](https://magento.com/tech-resources/download) and the format of the package is Magento Community Edition 2.1.3.tar.gz.  
   2. You need to login with your account to download the Magento2 CE 2.1.3 package from [Magento Tech Resource](https://magento.com/tech-resources/download).  

## How to Build the Image

At the same directory level with Dockerfile, run the command:

```
$sudo docker build [--build-arg PACKAGE_URL=<your package location>] -t [image name] .
```

## How to Run the Image on Your Host

run the command:  

```
$sudo docker run -t -p 80:80 -e BASE_URL=http://<your host name>/ [-e ADMIN_USER=<your admin user> ...] [--name <the Docker container name>] <image name>
```
You may need to set environment variables to run the image, here are all the environment variables and their default values:  

```
ADMIN_FIRSTNAME     firstname             <admin first name>
ADMIN_LASTNAME      lastname              <admin last name>
ADMIN_EMAIL         sample@example.com    <admin email>
ADMIN_USER          root                  <admin user>
ADMIN_PASSWORD      password1234          <admin password>
DB_NAME             magento               <database name>
DB_PASSWORD         password1234          <database password>
BACKEND_FRONTNAME   admin                 <backend frontname>
BASE_URL            http://127.0.0.1/     <site base url>
PRODUCTION_MODE     false                 <whether to set the site to production mode>
```

####Note:  
1. The variable BASE_URL must be set the same with your host name to avoid issues on accessing the Magento2 Admin Panel, for more details, please see the introduction of the parameter 'base-url' in [Magento2 command line installation instruction](http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html).  
2. If the environment variables listed above haven't been set, the default values will be used, however, it's recommended to use different values for security reasons.  
3. It's not recommended to simply use 'admin' as the value of BACKEND_FRONTNAME, for more details, see the introduction of the parameter 'backend-frontname' in [Magento2 command line installation instruction](http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html).  
4. By default, the Magento2 site will be deployed with default mode, you can choose to make it deployed with production mode by set the PRODUCTION_MODE to true, for more details of Magento2 mode, plase see [here](http://devdocs.magento.com/guides/v2.0/config-guide/bootstrap/magento-modes.html).  

## How to Apply the Docker Image on Azure Web App for Linux

#### Deploy Azure Web App with Docker Image Automatically

1. Push the image to the Docker Hub after you build it.  
2. Change the value of the parameter 'dockerRegistryImageName' (located at azuredeploy.json file) to the name of your pushed image (or change it during the deployment).  
3. Press this button.  
  
  [![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)  

#### Deploy Azure Web App with Docker Image Manually

1. Create the resource Azure web app on Linux (Preview).  
2. Add these application settings:  

```
DOCKER_CUSTOM_IMAGE_NAME     <Docker image name>                           <Required>  
ADMIN_FIRSTNAME              <firstname>  
ADMIN_LASTNAME               <lastname>  
ADMIN_EMAIL                  <email>  
ADMIN_USER                   <admin username>  
ADMIN_PASSWORD               <admin password>  
DB_NAME                      <database name>  
DB_PASSWORD                  <database password>  
BACKEND_FRONTNAME            <backend frontname>  
BASE_URL                     <site base url>                               <Required>  
PRODUCTION_MODE              <whether to set the site to production mode>  
```
Your Docker image will be pulled and run while the first request reach the server, so the cold start process will be quite long.  

## How To Make Optimization of your Site

#### Enable Flat Categories and Products

Go to the admin panel, STORES -> Configuration -> CATALOG -> Catalog -> Use Flat Catalog Category  and put “Yes” .  
![alt text](https://raw.githubusercontent.com/Sharpeli/Packages/master/magento-optimization-images/magento-optimization-catalog.png)

#### Merge CSS and JS Files
 
For JS:  
1. Go to the admin panel,  STORES -> Configuration -> ADVANCED -> Developer -> JavaScript Settings  
2. Merge JavaScript Files -> Yes  
3. Minify JavaScript Files -> Yes  
![alt text](https://raw.githubusercontent.com/Sharpeli/Packages/master/magento-optimization-images/magento-optimization-js.png)  
  
For CSS:  
1. Go to the admin panel,  STORES -> Configuration -> ADVANCED -> Developer -> CSS Settings  
2. Merge CSS Files -> Yes  
3. Minify CSS Files -> Yes  
![alt text](https://raw.githubusercontent.com/Sharpeli/Packages/master/magento-optimization-images/magento-optimization-css.png)  

#### Enable Caching

Go to admin portal, SYSTEM -> Cache Management  
![alt text](https://raw.githubusercontent.com/Sharpeli/Packages/master/magento-optimization-images/magento-optimization-caching.png)  

#### Content Delivery Network

Content Delivery Network (CDN) is a special system that can connect all cache servers. In addition to supported geographical proximity, CDN will take over the delivering web content and fasten the page loading.  

Go to admin portal, Stores -> Configuration > General > Web > Base URLs (Secure)  
![alt text](https://github.com/Sharpeli/Packages/blob/master/magento-optimization-images/magento-optimization-cdn.png)  