
# Python Base 2.7

**Docker** image with **uWSGI** and **Nginx** for **Python 2.7** applications (as **Flask**) in a single container.

## Technical details

One of the best ways to deploy a Python web application is with uWSGI and Nginx, as seen in the [benchmarks](http://nichol.as/benchmark-of-python-web-servers).

Roughly:

* **Nginx** is a web server, it takes care of the HTTP connections and also can serve static files directly and more efficiently.

* **uWSGI** is an application server, that's what runs your Python code and it talks with Nginx.

* **Your Python code** has the actual web application, and is run by uWSGI.

This image takes advantage of already slim and optimized existing Docker images (based on Debian as [recommended by Docker](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)) and implements Docker best practices.

It uses the official Python Docker image, installs uWSGI and on top of that, with the least amount of modifications, adds the official Nginx image (as of 2016-02-14).

And it controls all these processes with Supervisord.

---

There's the rule of thumb that you should have "one process per container".

That helps, for example, isolating an app and its database in different containers.

But if you want to have a "micro-services" approach you may want to [have more than one process in one container](https://valdhaus.co/writings/docker-misconceptions/) if they are all related to the same "service", and you may want to include your Flask code, uWSGI and Nginx in the same container (and maybe run another container with your database).

That's the approach taken in this image.

---

This image has a default sample "Hello World" app in the container's `/app` directory using the example in the [uWSGI documentation](http://uwsgi-docs.readthedocs.org/en/latest/WSGIquickstart.html).

You probably want to override it or delete it in your project.

It is there in case you run this image by itself and not as a base image for your own `Dockerfile`, so that you get a sample app without errors.
