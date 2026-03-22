FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

# Site files at root
COPY site/index.html /usr/share/nginx/html/
COPY site/app.js /usr/share/nginx/html/
COPY site/style.css /usr/share/nginx/html/
COPY site/manifest.json /usr/share/nginx/html/

# Cache-bust: stamp asset URLs with build timestamp so browsers fetch fresh files
RUN STAMP=$(date +%s) && \
    sed -i "s|style.css|style.css?v=$STAMP|g" /usr/share/nginx/html/index.html && \
    sed -i "s|app.js|app.js?v=$STAMP|g" /usr/share/nginx/html/index.html

# Content directory at /content/ (app.js fetches from ../content/ which resolves to /content/)
COPY content/ /usr/share/nginx/html/content/
