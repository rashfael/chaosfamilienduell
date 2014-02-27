# Chaosfamilienduell

## Used Tech

node.js brunch mongodb chaplin socket.io bootstrap jquery backbone lodash

## Install

* Install nodejs and mongodb
* `(sudo) nmp -g install coffee-script brunch bower`
* `npm install`
* `bower install`

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