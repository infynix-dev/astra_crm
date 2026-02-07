FROM frappe/bench:latest

USER root

WORKDIR /home/frappe

COPY init.sh /home/frappe/init.sh

RUN chown frappe:frappe /home/frappe/init.sh

USER frappe

CMD ["bash", "/home/frappe/init.sh"]
