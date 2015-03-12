# Ping Deployment Instructions
Andoni M. Garcia
12 March 2015

## Preface

Below are specific deployment instructions for an Amazon Linux EC2 instance. To configure the instance itself, ensure that both:

  - SSH access is allowed from your computer's IP address.
  - HTTP access is allowed on all ports.

Typically, if you run through the AWS 'Getting Started' tutorial, it will help you ensure the proper security settings.

## First Steps

First, some initial installations

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

You must exit in order for the user information to update. Namely, we are adding `ec2-user` to `www`, and this needs a fresh login to update. Upon loggin back in, let's finish out the group settings.

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

To go through this installation wizard:

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
[ec2-user@<ipaddr> ~]$ sudo yum install -y python-devel python-virtualenv mysql-devel git gcc mod_fcgid
[ec2-user@<ipaddr> ~]$ git clone https://github.com/andonigarcia/Ping.git
[ec2-user@<ipaddr> ~]$ cd Ping/flask_app
[ec2-user@<ipaddr> flask_app]$ mv * /var/www/html
[ec2-user@<ipaddr> flask_app]$ cd ~
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
[ec2-user@<ipaddr> html]$ sudo DATABASE_URL=mysql://<username>:<password>@localhost/<db_name> ./db_create.pt
[ec2-user@<ipaddr> html]$ sudo service mysqld restart
```

Now everything should be good to go in your environemtn.

## Apache Alterations

First, we need to add a virtualhost and mess around with some apache configs. Let's start by adding this to the BOTTOM of the config file.

```
[ec2-user@<ipaddr> html]$ sudo chmod a+x run-mysql.fcgi
[ec2-user@<ipaddr> html]$ sudo nano /etc/httpd/conf/httpd.conf
...
# ADD EVERYTHING BELOW THIS LINE TO THE BOTTOM OF THE FILE
FcgidIPCDir /tmp
AddHandler fcgid-script .fcgi
<VirtualHost *:80>
    WSGIPassAuthorization On
    DocumentRoot /var/www/html/app/static
    Alias /static /var/www/html/app/static
    ScriptAlias / /var/www/html/run-mysql.fcgi/
</VirtualHost>
# ctrl-X, shft-Y, enter to save
...
[ec2-user@<ipaddr> html]$ sudo service httpd restart
```

Now you should be able to navigate to your IP Address in your browser and see the application.

## Linking An EBS Instance

In order to allow for growth and expanded storage (unless you only plan to stay within the EC2 instance's intial storage -- typically around 8 GiB), you should probably link up an external Elastic Block Storage instance.

In your AWS EC2 Dashboard, click on 'Elastic Block Store >Volumes'. Here you can click 'Create Volume' to add a new volume to your EC2 instance.

Next, SSH into your EC2 instance.  
Run `lsblk` to see which name your newly added storage is directed under (If you can't tell by disc size, look at 'MOUNTPOINT'. It will be the directory without an entry in this column).  This will be the input below for `<new_ecb_directory>`.

```
[ec2-user@<ipaddr> ~]$ sudo mkfs -t ext4 /dev/<new_ecb_directory>`.
[ec2-user@<ipaddr> ~]$ sudo mkdir /mnt/my-data
[ec2-user@<ipaddr> ~]$ sudo mount /dev/<new_ecb_directory> /mnt/my-data
```