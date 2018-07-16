FROM node:10

WORKDIR /usr/src/app

COPY dialogflow-telephony-bridge-testsuite/package*.json ./

RUN npm install

COPY dialogflow-telephony-bridge-testsuite/ ./
COPY launchTest.sh .

CMD ["/bin/bash", "launchTest.sh"]
