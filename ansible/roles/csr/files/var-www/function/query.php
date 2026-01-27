<?php
// Include the database connection file
include_once("mariadb-config.php");

echo "webserver: " . $_SERVER['SERVER_ADDR'];
echo "<br>";
echo "real IP: " . $_SERVER["HTTP_X_FORWARDED_FOR"];
echo "<br>";
echo "<br>";

// Fetch contacts (in descending order)
$result = mysqli_query($mysqli, "SELECT * FROM users ORDER BY id DESC LIMIT 10;");
while ($row = mysqli_fetch_assoc($result)) {
    echo "id: " . $row["id"]. " - Name: " . $row["username"]. " - Email: ". $row["email"]. " - Created At: ". $row["created_at"]. "<br>";
}
?>
