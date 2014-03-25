#!/bin/sh

CMD="`dirname $0`/../coffee/dynmod-cli.coffee"

$CMD install anybase anybase@0.1.0
$CMD current anybase sync-exec
$CMD list
$CMD list anybase
$CMD list anybase sync-exec
$CMD remove anybase
