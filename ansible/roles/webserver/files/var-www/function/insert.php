<?php
// Include the database connection file
include_once("mariadb-config.php");

echo "webserver: " . $_SERVER['SERVER_ADDR'];
echo "<br>";
echo "real IP: " . $_SERVER["HTTP_X_FORWARDED_FOR"];
echo "<br>";
echo "<br>";

// INSERT data section

$random = uniqid();
$username = 'user_'.$random;
$email = 'user_'.$random.'@gmail.com';
$hash = password_hash('1234', PASSWORD_DEFAULT);

$sql = "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)";

try {

        $query = $mysqli->prepare($sql);
        $query->bind_param("sss", $username, $email, $hash);
        if (!$query->execute()) {
                echo "Insert data failed! " . $query->error;
                error_log($query->error);
        } else {
                echo "Insert data with " . $sql . " successfully! <br>";
        }

}
catch (mysqli_sql_exception $e) {

        if (str_contains($e->getMessage(), 'read-only')) {
                echo "This DB is READ-ONLY (slave) <br>";
                echo $e->getMessage() . "<br>";
        } else {
                echo "DB Error: " . $e->getMessage() . "<br>";
        }

        error_log($e->getMessage());

}

$result = mysqli_query($mysqli, "SELECT * FROM users ORDER BY id DESC LIMIT 5;");
while ($row = mysqli_fetch_assoc($result)) {
        echo "id: " . $row["id"]. " - Name: " . $row["username"]. " - Email: ". $row["email"]. " - Created At: ". $row["created_at"]. "<br>";
}
?>
