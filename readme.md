docker build -t nginx-php .

docker run --name NAMEME --link mysql:mysql -p 80:80 -t -i -v /development/FOLDER:/var/www -d nginx-php
