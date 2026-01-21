<?php
$use_auth = false;
$auth_users = array();
$readonly_users = array();
$show_hidden_files = true;

$root_path = '/share';
$root_url = '/files/';

$is_https =
    (isset($_SERVER['HTTPS'])
        && (strtolower($_SERVER['HTTPS']) == 'on' || $_SERVER['HTTPS'] == 1))
    || (isset($_SERVER['HTTP_X_FORWARDED_PROTO'])
        && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https');

define('FM_SELF_URL', ($is_https ? 'https' : 'http') . '://' . $http_host . '/files/');
#http_host is ok undefined because this file is imported into a script namespace where it is defined
?>
