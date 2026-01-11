FROM oven/bun:1

#installation de curl
RUN apt-get -y update;

WORKDIR /app

COPY package.json bun.lock ./

RUN bun install

COPY ./src ./src

#pour la production
#CMD ["bun", "run", "start"] 

# pour le développement
#CMD ["bun", "run", "dev"]