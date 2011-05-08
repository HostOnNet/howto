#!/usr/bin/php
<?php

/*
Usage :
php video2image.php <VIDEONAME_HERE>
It will create thumbnails from video, store it in folder out.
Thumbails are creted very minute, that is 1 hour video will generate 60 images
Author: admin@hostonnet.com
*/

$video = $argv[1];

$interval = 30; // create thumbnail every X seconds


if (! file_exists($video))
{
    die('ERROR: Source video not found' . "\n\n");
}

$cmd = "/usr/bin/ffmpeg -i $video";
@exec("$cmd 2>&1", $output);
$output_all = implode("\n", $output);

if (@preg_match('/Duration: ([0-9][0-9]:[0-9][0-9]:[0-9\.]+), .*/', $output_all, $regs))
{
    $sec = $regs[1];
    $duration_array = split(":", $sec);
    $sec = ($duration_array[0] * 3600) + ($duration_array[1] * 60) + $duration_array[2];
    $sec = (int) $sec;
}
else
{
    die('Failed to find vide duration');
}

echo 'Video Duration in Seconds: ' . $sec . "\n";
$frames = $sec / $interval;
echo 'Video Frames: ' . $frames . "\n";

$pathInfo = pathinfo($video);
$folderName = strtolower($pathInfo['filename']);

if (is_dir($folderName))
{
   // die("Directory already exists, please dlete diretory and try again\n\n rm -rf $folderName\n\n");
}
else
{
    echo 'Creating Directory';
    mkdir($folderName);
}

for ($i = 1; $i <= $frames; $i ++)
{
    $seconds = $i * $interval;
    $time = sec2hms($seconds);
    $cmd = "mplayer $video -ss $time -nosound -vo jpeg:outdir=$folderName -frames 2";
    @exec($cmd);
    $imageName = str_replace(':', '', $time);
    rename("$folderName/00000001.jpg", "$folderName/$imageName.jpeg");
    $img = "<img src=$imageName.jpeg> $time <hr />";
    error_log("$img", 3, "$folderName/all.html");
    echo "#";
    
/*    if (($video == '20.avi') && ($i > 20))
    {
        exit();
    }*/
}

echo "\n" . 'Finished Creating Thumbnails in folder : ' . "$folderName\n";

function sec2hms($sec, $useColon = true)
{
    $hms = '';
    $hours = intval(intval($sec) / 3600);
    
    if ($hours > 0)
    {
        $hms .= str_pad($hours, 2, '0', STR_PAD_LEFT) . ':';
    }
    else
    {
        $hms .= '00:';
    }
    
    $minutes = intval(($sec / 60) % 60);
    
    if ($minutes > 0)
    {
        $hms .= str_pad($minutes, 2, '0', STR_PAD_LEFT) . ':';
    }
    else
    {
        $hms .= '00:';
    }
    
    if ($sec > 59)
    {
        $seconds = intval($sec % 60);
    }
    else
    {
        $sec_tmp = round($sec, 2);
        $seconds = $sec_tmp;
    }
    
    $hms .= str_pad($seconds, 2, '0', STR_PAD_LEFT);
    return $hms;
}