# Chaosfamilienduell

## Used Tech

node.js brunch mongodb chaplin socket.io bootstrap jquery backbone lodash

## Install

* Install nodejs and mongodb
* `(sudo) npm -g install coffee-script brunch bower`
* `cake install`
* ``

## Run

`cake watch`

watches and reloads server and client, point browser to http://localhost:9000

## Architecture

Actors:

* 1 Moderator:
* 2 player groups:
* 2 active players:
* N jury members:

Rules:

Two teams, four rounds

Round:

question = [ answers]

1. Face-Off (decides which team controls)
	1. Question is asked, buzz time!
	2. Buzzer answers
	3. Non-Buzzer answers
	4. More popular answer gets to decide which team plays (if equally popular, buzzer first. if both answers wrong

## Docker

To run the docker container, donwload the image, and use:

You'll need a data directory where the questions and savegames are persisted with the following layout:

- /your/data/dir
	- questions/
		- questions_3.json
		- questions_4.json
		- questions_5.json
		- questions_6.json
		- questions_7.json

	- savegames/ (folder has to exist)

```docker run -v /your/data/dir:/data -t -i $IMAGE```

If you want to load an old savegame:

```docker run -v /your/data/dir:/data -t -i $IMAGE cake -s $SAVEGAME run```

($SAVEGAME from savegames/)
