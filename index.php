<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>Bear Cal Example</title>
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width">

    <link rel="stylesheet" href="css/normalize.css">
    <link rel="stylesheet" href="css/main.css">
    <script src="js/vendor/modernizr-2.6.1.min.js"></script>
  </head>
  <body>

    <h2>Full Calendar</h2>
    <div class="bearcal">
    </div>

    <h2>Single Month Calendar (tracking disabled)</h2>
    <div class="minibearcal">
    </div>

    <h2>Input Calendar with date space disabled</h2>
    <div class="input-example">
      <input type="text" name="startdate" class="inputbearcal" autocomplete="off">
      <input type="text" name="enddate" class="inputbearcal-horizontal" autocomplete="off">
    </div>

    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.8.0.min.js"><\/script>')</script>
    <script src="js/vendor/jquery-ui-1.8.23.custom.min.js"></script>
    <script src="js/plugins.js"></script>
    <script src="js/bearcal.js"></script>
    <script src="js/main.js"></script>
  </body>
</html>
