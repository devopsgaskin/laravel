# laravel deploy

sudo apt update
sudo apt upgrade
sudo apt install php-fpm php-mbstring php-xml php-zip php-json php-curl php-mysql nginx mysql-server composer
mysql -u root -p
CREATE DATABASE database_name;
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost';
FLUSH PRIVILEGES;
EXIT;
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/your-site-name
sudo nano /etc/nginx/sites-available/your-site-name
sudo ln -s /etc/nginx/sites-available/your-site-name /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
cd /var/www
composer create-project --prefer-dist laravel/laravel your-project-name
sudo chown -R www-data:www-data /var/www/your-project-name
cd /var/www/your-project-name
cp .env.example .env
nano .env
php artisan key:generate

# angular deploy

To deploy an Angular application on the same Linux server where you've deployed your Laravel app, you'll need to serve the Angular application through a web server. Here's a step-by-step guide to deploying the latest Angular application on your Linux server:

1. **Build Your Angular Application:**
   Make sure you have the Angular CLI installed on your development machine. If not, you can install it with the following command:

   ```bash
   npm install -g @angular/cli
   ```

   Navigate to your Angular project directory and build the application:

   ```bash
   cd /path/to/your/angular-app
   ng build --prod
   ```

   This will create a `dist` directory in your Angular project with the production-ready build.

2. **Copy Angular Build Files:**
   Copy the contents of the `dist` directory to a directory where your web server can serve the files. You can use the `rsync` command for this purpose:

   ```bash
   rsync -av /path/to/your/angular-app/dist/ /var/www/angular-app
   ```

   Ensure that the destination directory (`/var/www/angular-app` in this example) is accessible by your web server.

3. **Set Up Nginx for Angular:**
   If you're using Nginx to serve your Laravel app, you can configure Nginx to serve the Angular app as well.

   Create an Nginx server block configuration for the Angular app:

   ```bash
   sudo nano /etc/nginx/sites-available/angular-app
   ```

   Inside the configuration file, add the following:

   ```nginx
   server {
       listen 80;
       server_name your-angular-domain.com;

       root /var/www/angular-app;

       location / {
           try_files $uri $uri/ /index.html;
       }
   }
   ```

   Be sure to replace `your-angular-domain.com` with your actual domain name, and adjust the paths to match your setup.

   After creating the configuration, create a symbolic link to enable it:

   ```bash
   sudo ln -s /etc/nginx/sites-available/angular-app /etc/nginx/sites-enabled/
   ```

   Then, test the Nginx configuration and reload Nginx:

   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Test Your Angular App:**
   Visit your Angular app in a web browser by accessing the configured domain. Your Angular app should now be accessible at `http://your-angular-domain.com`.

This setup allows you to serve both your Laravel app and Angular app on the same server using Nginx. Your Laravel app can be accessed at its configured domain (e.g., `http://your-laravel-domain.com`), and your Angular app can be accessed at its domain (e.g., `http://your-angular-domain.com`).

Make sure that both apps don't conflict with each other in terms of routes and URLs. Additionally, consider configuring HTTPS for your Angular app using Let's Encrypt, as previously described, for a secure setup.

# loadbalancer on digitalocean

To host your Laravel app on DigitalOcean with HTTPS traffic and a load balancer, you can follow these additional steps after deploying your Laravel app as mentioned earlier:

1. **Create a DigitalOcean Account:**
   If you don't already have an account, sign up for a DigitalOcean account.

2. **Set Up a Load Balancer:**

   - Log in to your DigitalOcean account.
   - Go to the DigitalOcean control panel.
   - Click on "Load Balancers" in the sidebar.
   - Click the "Create Load Balancer" button.
   - Follow the steps to create a new load balancer.
     - Choose the data center region.
     - Add the droplets (your servers) you want to load balance. These should be the servers where you deployed your Laravel app.
     - Configure your load balancer settings. For HTTPS, you'll need to provide an SSL certificate. You can use Let's Encrypt to obtain a free certificate.
     - Set up forwarding rules to route incoming traffic to the appropriate backend droplets.
     - Choose a name for your load balancer and create it.

3. **Add Domain Name and DNS:**
   Point your domain name to the load balancer's IP address. You can do this by creating DNS records in your domain registrar's control panel.

4. **Configure SSL Certificate:**
   As part of creating the load balancer, you should have set up SSL certificates. If not, you can use Certbot to obtain an SSL certificate for your domain. Install Certbot and run the following commands on your load balancer server:

   ```bash
   sudo apt update
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx
   ```

   Follow the prompts to set up SSL for your domain.

5. **Update Nginx Configuration on Load Balancer:**
   If your load balancer is using Nginx, you need to ensure that the Nginx configuration on the load balancer is correctly set up to handle HTTPS traffic. Make sure it's configured to listen on port 443 and use the SSL certificate you obtained in the previous step.

6. **Test Your Load Balancer:**
   Visit your domain over HTTPS to verify that the load balancer is correctly routing traffic to your Laravel application.

7. **Scaling and Maintenance:**
   You can add more droplets to the load balancer to scale your application as needed. DigitalOcean makes it easy to add or remove droplets from the load balancer as traffic demands change.

By following these steps, you can deploy your Laravel app on DigitalOcean with a load balancer that handles HTTPS traffic. This setup provides load balancing for improved availability and scalability, along with the security benefits of HTTPS encryption.