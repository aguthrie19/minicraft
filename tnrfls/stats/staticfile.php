<?php
$zipfile = getenv('SRVDIR') . '/world/resourcepacks/staticfilestaticfile.zip';

if (!is_file($zipfile)) {
    http_response_code(404);
    exit;
}

if (ob_get_level()) {
    ob_end_clean();
}

header('Content-Type: application/zip');
header('Content-Length: ' . filesize($zipfile));
header('Content-Disposition: attachment;');
header('Cache-Control: public, max-age=31536000');
header('ETag: "' . md5_file($file) . '"');
header_remove('X-Powered-By');
readfile($zipfile);
exit;
?>
