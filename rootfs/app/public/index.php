<?php

header('Content-Type: text/plain; charset=utf-8', true);

$get = $_SERVER['REQUEST_URI'].' '.$_SERVER['SERVER_PROTOCOL'];
$dnt = (int) $_SERVER['HTTP_DNT'] ?? 0;
$uis = (int) $_SERVER['HTTP_UPGRADE_INSECURE_REQUESTS'] ?? 0;

echo <<<RESPONSE
Hostname: {$_SERVER['SERVER_NAME']}
IP: {$_SERVER['SERVER_ADDR']}
GET {$get}
Host: {$_SERVER['HTTP_HOST']}
User-Agent: {$_SERVER['HTTP_USER_AGENT']}
Accept: {$_SERVER['HTTP_ACCEPT']}
Accept-Encoding: {$_SERVER['HTTP_ACCEPT_ENCODING']}
Accept-Language: {$_SERVER['HTTP_ACCEPT_LANGUAGE']}
Dnt: {$dnt}
Upgrade-Insecure-Requests: {$uis}
RESPONSE;
