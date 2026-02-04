<?php
require_once 'hlpr_whiteref.php';
require_once 'jsilveiraRcon.php';
use Thedudeguy\Rcon;

$referralsfile = getenv('SRVDIR') . 'referrals.json';
$referralspoolqty = 3;
$whitelistfile = getenv('SRVDIR') . 'whitelist.json';
$minecraftapi = 'https://api.minecraftservices.com/minecraft/profile/lookup/name/';
$rconhost = '127.0.0.1';
$rconport = 25575;
$rconpassword = trim(@file_get_contents('/secrets/manual_rcon_password') ?: 'fallbackpassword');
$rcontimeout = 1;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $referral = $_POST['referral'] ?? '';
    $profilename = $_POST['profilename'] ?? '';

    try { $referrals = readFileJson($referralsfile);
    } catch (Exception | JsonException) {exit(join('<br>', updateReferrals('',$referralsfile,$referralspoolqty)));}

    if ( in_array($referral, $referrals, true) ) {
        $uuid = getUuidMinecraft($profilename,$minecraftapi);

        if ($uuid) {
            whiteListAdd(
                $profilename,
                $uuid,
                new Rcon($rconhost, $rconport, $rconpassword, $rcontimeout),
                $whitelistfile
            );
            $updatedreferrals = updateReferrals($referral, $referralsfile);
            exit(showInHtmlBody(joinInHtmlDivs([
                "You're whitelisted!",
                "Share this NEW referral...",
                join('<br>',$updatedreferrals)
            ])));
        }
    }
}

print showInHtmlBody(aHtmlForm());

function showInHtmlBody($content = "") {
    return <<<HTML
    <body style="display:grid; place-content:center; min-height:100vh; text-align:center; gap:10px;">
        $content
    </body>
    HTML;
}

function aHtmlForm() {
    return <<<HTML
    <form method="POST" style="display:flex;flex-direction:column;gap:10px;">
        <input name="referral" placeholder="Referral" required>
        <input name="profilename" placeholder="Profilename" required>
        <button>Submit</button>
    </form>
    HTML;
}

function joinInHtmlDivs(array $elements) {
    return $row = "<div>" . join("</div><div>",$elements) . "</div>";
}
?>
