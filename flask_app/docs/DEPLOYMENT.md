# Ping Deployment Instructions
Andoni M. Garcia
13 March 2015

## Preface

Below are specific deployment instructions for an Amazon Linux EC2 instance. To configure the instance itself, ensure that both:

  - SSH access is allowed from your computer's IP address.
  - HTTP access is allowed on all ports.

Typically, if you run through the AWS 'Getting Started' tutorial, it will help you ensure the proper security settings. I might come back later to update this section with the actual instance set-up, but it is pretty straightforward.

## SSH/Connecting

I am not here to instruct you on how to SSH into your instance. There are fabulous guides out there, both from and not from Amazon Web Services, that can teach you best practices for SSH and how to actually connect to your instance. Please resume this deployment tutorial once you are connected to your Amazon Linux box.

## First Steps

First, some initial installations to set-up a LAMP stack.

```
[ec2-user@<ipaddr> ~]$ sudo yum update -y
[ec2-user@<ipaddr> ~]$ sudo yum groupinstall -y "Web Server" "MySQL Database"
[ec2-user@<ipaddr> ~]$ sudo yum install -y php-mysql
```

This provides everything you need for a bare bones LAMP stack. The last statement isn't needed for our Flask server, but is good practice to maintain a full LAMP stack incase PHP is one day needed or integrated into our system.

Next, we will start up our Apache server, set it so that it turns-on on boot, and then create a `www` user in order to interact with our Apache files.

```
[ec2-user@<ipaddr> ~]$ sudo service httpd start
[ec2-user@<ipaddr> ~]$ sudo chkconfig httpd on
[ec2-user@<ipaddr> ~]$ sudo groupadd www
[ec2-user@<ipaddr> ~]$ sudo usermod -a -G www ec2-user
[ec2-user@<ipaddr> ~]$ exit
```

You must exit in order for the user information to update. Namely, we are adding `ec2-user` to `www`, and this needs a fresh login to update. Upon SSH'ing back in, let's finish out the group settings.

```
[ec2-user@<ipaddr> ~]$ sudo chown -R root:www /var/www
[ec2-user@<ipaddr> ~]$ sudo chmod 2775 /var/www
[ec2-user@<ipaddr> ~]$ find /var/www -type d -exec sudo chmod 2775 {} +
[ec2-user@<ipaddr> ~]$ find /var/www -type f -exec sudo chmod 0664 {} +
```

This should create all files in `/var/www` under control of `www`.

## MySQL Initialization

First, fire up MySQL and start its secure install.

```
[ec2-user@<ipaddr> ~]$ sudo service mysqld start
[ec2-user@<ipaddr> ~]$ sudo mysql_secure_installation
```

You can go through this installation wizard on your own, or just quickly tap the following keys to instantiate the recommended secure install.

1. `enter` because no password has been set yet.
2. `Y` to setup a root password
3. <YOUR_PASS>
4. <YOUR_PASS> - reenter for confirmation
5. `Y` to remove anonymous users
6. `Y` to remove the test db
7. `Y` to reload table privileges.

```
[ec2-user@<ipaddr> ~]$ sudo service mysqld restart
[ec2-user@<ipaddr> ~]$ sudo chkconfig mysqld on
```

Now, we will actually setup a MySQL user so you don't have to login as root.

```
[ec2-user@<ipaddr> ~]$ mysql -u root -p
Enter password:
...
mysql> CREATE USER '<username>'@'localhost' IDENTIFIED BY '<password>';
mysql> CREATE DATABASE `<db_name>`;
mysql> GRANT ALL PRIVILEGES ON `<db_name>`.* TO '<username>'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> exit
[ec2-user@<ipaddr> ~]$ sudo service mysqld restart
```

## Installing Flask Sever

First, we need to install some critical modules. Then, we need to download our source code. Finally, we need to virtualenv everything and get dependencies.

```
[ec2-user@<ipaddr> ~]$ sudo yum install -y python-devel python-virtualenv httpd-devel mysql-devel git gcc mod_fcgid
[ec2-user@<ipaddr> ~]$ git clone https://github.com/andonigarcia/Ping.git
[ec2-user@<ipaddr> ~]$ cd Ping/flask_app
[ec2-user@<ipaddr> flask_app]$ mv * /var/www/html
[ec2-user@<ipaddr> flask_app]$ sudo chmod -R g+w /var/www/html/tmp
[ec2-user@<ipaddr> flask_app]$ cd ~
[ec2-user@<ipaddr> ~]$ rm Ping -r
```

Now that we have all of our server info sent to the `www` controlled `/var/www/html` directory (the most common directory for single server instances), we need to adjust the ownership to include `apache`.

```
[ec2-user@<ipaddr> ~]$ sudo service httpd stop
[ec2-user@<ipaddr> ~]$ sudo usermod -a -G www apache
[ec2-user@<ipaddr> ~]$ sudo chown -R apache /var/www
[ec2-user@<ipaddr> ~]$ sudo chgrp -R www /var/www
[ec2-user@<ipaddr> ~]$ sudo chmod 2775 /var/www
[ec2-user@<ipaddr> ~]$ find /var/www -type d -exec sudo chmod 2775 {} +
[ec2-user@<ipaddr> ~]$ find /var/www -type f -exec sudo chmod 0664 {} +
[ec2-user@<ipaddr> ~]$ sudo service httpd start
```

After all this logistics, we finally get to do some real deployment!

```
[ec2-user@<ipaddr> ~]$ sudo curl https://bootstrap.pypa.io/get-pip.py | sudo python
[ec2-user@<ipaddr> ~]$ cd /var/www/html
[ec2-user@<ipaddr> html]$ sudo chmod a+x setupSudo.sh
[ec2-user@<ipaddr> html]$ ./setupSudo.sh
[ec2-user@<ipaddr> html]$ sudo chmod a+x db_create.py
[ec2-user@<ipaddr> html]$ sudo DATABASE_URL=mysql://<username>:<password>@localhost/<db_name> ./db_create.py
[ec2-user@<ipaddr> html]$ sudo service mysqld restart
```

Now everything should be good to go in your environment. If ownership problems arise later in regards to mod_wsgi, look into how to include an `activate_this` segment in your run script. Otherwise, all should be good at this point.

## Apache Alterations

First, we need to edit our FastCGI script in order to be production ready. Go into `run-mysql.fcgi` with your favorite editor (`vim` and `nano` both work) and fix the `DATABASE_URL` value to your proper mysql uri. Further, uncomment and input any of the following environment variables in order to add robustness to your production script.

Finally, we need to add a virtualhost and mess around with some apache configs. Let's start by adding this to the **BOTTOM** of the config file.

```
[ec2-user@<ipaddr> html]$ sudo chmod a+x run-mysql.fcgi
[ec2-user@<ipaddr> html]$ sudo nano /etc/httpd/conf/httpd.conf
...
# ADD EVERYTHING BELOW THIS LINE TO THE BOTTOM OF THE FILE
FcgidIPCDir /tmp
AddHandler fcgid-script .fcgi
<VirtualHost *:80>
    ServerName <WWW.WEBSITE.COM>

    DocumentRoot /var/www/html/app/static
    Alias /static /var/www/html/app/static
    ScriptAlias / /var/www/html/run-mysql.fcgi/
    WSGIPassAuthorization On
    FcgidPassHeader Authorization
    FcgidAuthorizerAuthoritative Off
    FcgidAuthenticatorAuthoritative Off

    <Directory "/var/www/html">
        Options FollowSymLinks MultiViews Includes ExecCGI
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>

</VirtualHost>

<VirtualHost *:80>
    ServerName <WEBSITE.COM>
    ServerAlias *.<WEBSITE.COM>
    Redirect permanent / http://www.<WEBSITE.COM>
</VirtualHost>
# `ctrl-X`, `shft-Y`, `enter` To Save
...
[ec2-user@<ipaddr> html]$ sudo service httpd restart
```

Now you should be able to navigate to <WWW.WEBSITE.COM> in your browser and see the application.

[Email me](mailto:garcia_andoni@yahoo.com) if you need help troubleshooting or debugging any errors. Linux deployment is particularly tricky, so it may very well be the case that your browser wont render on first try.

### Linking An EBS Instance

In order to allow for growth and expanded storage (unless you only plan to stay within the EC2 instance's intial storage -- typically around 8 GiB), you should probably link up an external Elastic Block Storage instance.

In your AWS EC2 Dashboard, click on 'Elastic Block Store >Volumes'. Here you can click 'Create Volume' to add a new volume to your EC2 instance.

Next, SSH into your EC2 instance.  
Run `lsblk` to see which name your newly added storage is directed under (If you can't tell by disc size, look at 'MOUNTPOINT'. It will be the directory without an entry in this column).  This will be the input below for `<new_ecb_directory>`.

```
[ec2-user@<ipaddr> ~]$ sudo mkfs -t ext4 /dev/<new_ecb_directory>`.
[ec2-user@<ipaddr> ~]$ sudo mkdir /mnt/my-data
[ec2-user@<ipaddr> ~]$ sudo mount /dev/<new_ecb_directory> /mnt/my-data
```