FROM frappe/bench:latest

USER root

WORKDIR /home/frappe

COPY init.sh /home/frappe/init.sh
RUN chmod +x /home/frappe/init.sh

CMD ["bash", "/home/frappe/init.sh"]