<!DOCTYPE html>

<html>

<head>
    <meta charset="utf-8">
    <title>NGINX Server</title>

    <style>
        html, body {
            height: 100%;
            padding: 1em;
            font-family: sans-serif;
            font-weight: 200;
        }
    </style>
</head>


<body>

    <h1>NGINX Server</h1>
    <hr />

    <ul>
        <li>
            <h4>NGINX web server</h4>
        </li>
        <li>
            <h4>MongoDB</h4>
            <p>MongoDB Shell:
                <?php
                    $v = `mongo --version`;
                    echo $v;
                ?>
            </p>
            <p>
                <?php
                    // connect to mongodb
                    $db_manager = new MongoDB\Driver\Manager();
                    echo "Connection to database successfully.<br />";

                    // select a database
                    $db = $db_manager->serverdb;
                    echo "Database serverdb selected.<br />";
                ?>
            </p>
        </li>
        <li>
            <h4>PHP 7</h4>
            <?php echo phpversion(); ?>
        </li>
    </ul>

    <hr />

    <?php echo phpinfo(); ?>

</body>

</html>
