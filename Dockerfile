FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

# Site files at root
COPY site/index.html /usr/share/nginx/html/
COPY site/app.js /usr/share/nginx/html/
COPY site/style.css /usr/share/nginx/html/
COPY site/manifest.json /usr/share/nginx/html/

# Content directory at /content/ (app.js fetches from ../content/ which resolves to /content/)
COPY content/ /usr/share/nginx/html/content/
