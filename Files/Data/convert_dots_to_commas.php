<?php

$constants = [
    'COMMON_STAT'        => 'with-common-stat',
    'MSE'                => 'with-mse',
    'RESULTS'            => 'with-results',
    'RIGHT_ANSWERS_STAT' => 'with-right-answers-stat',
    'ALL'                => 'convert-all',
];
foreach ($constants as $name => $value) {
    defined($name) or define($name, $value);
}


$allowedFilePaths = [
    MSE                 => __DIR__ . '/Neuro_MSE.csv',
    RESULTS             => __DIR__ . '/Neuro_Results.csv',
    COMMON_STAT         => __DIR__ . '/Neuro_CommonStats.csv',
    RIGHT_ANSWERS_STAT  => __DIR__ . '/Neuro_RightAnswersStats.csv',
];
$filePaths = [];


$opts = getopt('', [
    COMMON_STAT,
    MSE,
    RESULTS,
    RIGHT_ANSWERS_STAT,
    ALL,
]);

if (array_key_exists(ALL, $opts)) {
    $filePaths = [];
    $cloned = new ArrayObject($allowedFilePaths);
    $filePaths = $cloned->getArrayCopy();
} else {
    foreach ($opts as $argumentName => $argumentValue) {
        $filePaths[] = $allowedFilePaths[$argumentName];
    }
}

foreach ($filePaths as $filePath) {
    if (!is_readable($filePath)) {
        exit("File '$filePath' is not readable.");
    }
    $file = file_get_contents($filePath, 'r');
    if (false === $file) {
        exit("Could not get contents of file '$filePath'.");
    }
    
    $file = str_replace('.', ',', $file);

    $putResult = file_put_contents($filePath, $file);
    if (false === $putResult) {
        exit("Could not put contents to file '$filePath'.");
    }
}

echo 'OK' . PHP_EOL;
exit(0);
