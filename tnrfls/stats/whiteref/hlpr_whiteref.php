<?php
use Thedudeguy\Rcon;

function readFileJson($path) {
    return ( $contents = @file_get_contents($path) )
    ? json_decode($contents, true, 512, JSON_THROW_ON_ERROR)
    : throw new Exception("[X] file_get_ {$path}");
}

function writeFileJson($path, $data) {
    file_put_contents($path, json_encode($data, JSON_PRETTY_PRINT));
}

function getUuidMinecraft(
    string $profilename,
    string $url = "https://api.minecraftservices.com/minecraft/profile/lookup/name/"
) {
    $response = json_decode( @file_get_contents($url . urlencode($profilename)) , true);
    if (!$response) return null;
    return $uuid = vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split($response['id'], 4));
}

function whiteListAdd(
    string $profilename,
    string $uuid,
    Rcon   $rcon,
    string $whitelistfile = ''
) {
    if ($rcon->connect()) {
        $rcon->sendCommand("whitelist add $profilename");
        $rcon->disconnect();
        return;
    }
    else {
        $whitelist = [
            ...readFileJson($whitelistfile),
            ['uuid' => $uuid, 'name' => $profilename]
        ];
        writeFileJson($whitelistfile, $whitelist);
    }
}

function getNewReferrals($count = 1) {
    return $count <1 ? [] : $newreferrals = array_map(
        fn() =>
        vsprintf( '%s-%s-%s-%s', str_split(bin2hex(random_bytes(8)),4) ),
        range(1,$count)
    );
}

function getStreamAndLock(string $path, string $mode = 'c+')
{
    $fp = fopen($path, $mode);
    return ( $fp && flock($fp, LOCK_EX) )
        ? $fp
        : throw new Exception("[X] getStreamAndLock {$path}");
}

function updateReferrals($usedreferral, $referralfile, $newreferralsqty=1) {
    $fp = getStreamAndLock($referralfile);
    $activereferrals = json_decode(stream_get_contents($fp) ?: '[]', true) ?? [];
    $newreferrals = getNewReferrals($newreferralsqty);
    $updatedreferrals = array_merge(array_diff($activereferrals, [$usedreferral]), $newreferrals);

    ftruncate($fp, 0); rewind($fp); fwrite($fp, json_encode($updatedreferrals)); fclose($fp);
    return $newreferrals;
}
